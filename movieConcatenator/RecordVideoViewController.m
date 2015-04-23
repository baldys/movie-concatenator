//
//  RecordVideoViewController.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-21.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "RecordVideoViewController.h"
#import "RecordVideoView.h"
#import "Take.h"
#import "VideoController.h"

/*
//// check the orientation of the device
 if it is in portrait mode, disable buttons and show a label that tells user to rotate device
 ///
*/
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface RecordVideoViewController () <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, weak) IBOutlet RecordVideoView *recordVideoView;
@property (nonatomic, weak) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraPosition;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;


- (IBAction)toggleRecording:(id)sender;
- (IBAction)toggleCameraPosition:(id)sender;
- (IBAction)toggleFlash:(id)sender;

@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureDevice *videoDevice;
// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;
@property (nonatomic) UILabel *incorrectOrientationLabel;
@end



@implementation RecordVideoViewController


- (void)deviceOrientationDidChange:(NSNotification *)notification

{
    
    //Obtaining the current device orientation
    
    /* Where self.m_CurrentOrientation is member variable in my class of type UIDeviceOrientation */
    
    self.currentOrientation = [[UIDevice currentDevice] orientation];
    
    // Do your Code using the current Orienation
    
}

- (BOOL)isSessionRunningAndDeviceAuthorized
{
    return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
    return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

- (void) checkOrientation:(UIInterfaceOrientation)orientation
{
    if (orientation == UIInterfaceOrientationPortrait)
    {
        [self hideButtons];
        [self showLabel];
        NSLog(@"orientation incorrect, should hide buttons and show the label");
        
    }
    else if (orientation == UIInterfaceOrientationLandscapeLeft || orientation ==UIInterfaceOrientationLandscapeRight)
    {
        [self showButtons];
        [self hideLabel];
        NSLog(@"orientation correct, should unhide buttons and hide the label");
    }
   
}

- (void) showLabel
{
    if (!self.incorrectOrientationLabel)
    {
        self.incorrectOrientationLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 100, 20)];
        [self.incorrectOrientationLabel setText:@"please rotate device for best results"];
        [self.incorrectOrientationLabel setTextColor:[UIColor whiteColor]];
        [self.view addSubview:self.incorrectOrientationLabel];
    }
    else
    {
        [self.incorrectOrientationLabel setHidden:NO];
    }
}

- (void) hideLabel
{
    [self.incorrectOrientationLabel setHidden:YES];
}

- (void)hideButtons
{
    [[self cameraPosition] setEnabled:NO];
    [[self cameraPosition] setHidden:YES];
    [[self recordButton] setEnabled:NO];
    [[self recordButton] setHidden:YES];
    [[self flashButton] setHidden:YES];
}
- (void)showButtons
{
    [[self cameraPosition] setEnabled:YES];
    [[self cameraPosition] setHidden:NO];
    [[self recordButton] setEnabled:YES];
    [[self recordButton] setHidden:NO];
    [[self flashButton] setHidden:NO];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    

    [self.saveButton setEnabled:NO];
    // Keep track of changes to the device orientation so we can update the capture pipeline
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    [self checkOrientation:orientation];
        
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.recordButton.layer.cornerRadius = self.flashButton.layer.cornerRadius = self.cameraPosition.layer.cornerRadius = 4;
    
    self.recordButton.clipsToBounds = self.flashButton.clipsToBounds = self.cameraPosition.clipsToBounds = YES;
    // Create the AVCaptureSession
    AVCaptureSession *session = [[AVCaptureSession alloc] init];

    [self setSession:session];
    // Setup the preview view
    
   [[self recordVideoView] setSession:session];
    
    // Check for device authorization
    [self checkDeviceAuthorizationStatus];
    
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
    
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];
    
    dispatch_async(sessionQueue, ^{
        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
        
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [RecordVideoViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error)
        {
            NSLog(@"%@", error);
        }
        [[self session] beginConfiguration];
        if ([session canAddInput:videoDeviceInput])
        {
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
            [self setVideoDevice:videoDeviceInput.device];
            dispatch_async(dispatch_get_main_queue(), ^{
                // Why are we dispatching this to the main queue?
                // Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
                // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                [[(AVCaptureVideoPreviewLayer *)[[self recordVideoView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
            });
        }
        
        AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        
        if (error)
        {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:audioDeviceInput])
        {
            [session addInput:audioDeviceInput];
        }
        
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ([session canAddOutput:movieFileOutput])
        {
            [session addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([connection isVideoStabilizationSupported])
                [connection setPreferredVideoStabilizationMode:YES];
            [self setMovieFileOutput:movieFileOutput];
        }
        

        [[self session] commitConfiguration];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    dispatch_async([self sessionQueue], ^{
        [self addObservers];
        
        [[self session] startRunning];
    });
  
}

-(void) addObservers
{
   [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
        [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
        [self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        
        __weak RecordVideoViewController *weakSelf = self;
        [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
            RecordVideoViewController*strongSelf = weakSelf;
            dispatch_async([strongSelf sessionQueue], ^{
                // Manually restarting the session since it must have been stopped due to an error.
                [[strongSelf session] startRunning];
                [[strongSelf recordButton] setTitle:NSLocalizedString(@"Record", @"Recording button record title") forState:UIControlStateNormal];
            });
        }]];
       

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    dispatch_async([self sessionQueue], ^{
        [[self session] stopRunning];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
        
        [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
        //[self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
        [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
        
    });
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    

  
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return UIInterfaceOrientationLandscapeLeft;
//}
- (BOOL)shouldAutorotate
{
    // Disable autorotation of the interface when recording is in progress.
    return ![self lockInterfaceRotation];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return //UIInterfaceOrientationMaskLandscapeLeft;
    UIInterfaceOrientationMaskLandscapeLeft;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"changed orientation");
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
        NSLog(@" /n INVALID ORIENTATION"); 
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        self.currentOrientation = UIInterfaceOrientationLandscapeRight;
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        self.currentOrientation = UIInterfaceOrientationLandscapeLeft;
    }
    [self checkOrientation:toInterfaceOrientation];
    
    [[(AVCaptureVideoPreviewLayer *)[[self recordVideoView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//    if (context == CapturingStillImageContext)
//    {
//        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
//        
//        if (isCapturingStillImage)
//        {
//            [self runStillImageCaptureAnimation];
//        }
//    }
    if (context == RecordingContext)
    {
        BOOL isRecording = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRecording)
            {
                //[[self cameraButton] setEnabled:NO];
                
                [[self cameraPosition] setEnabled:NO];
                [[self flashButton] setEnabled:NO];
                [[self recordButton] setTitle:NSLocalizedString(@"Stop", @"Recording button stop title") forState:UIControlStateNormal];
                [[self recordButton] setEnabled:YES];
            }
            else
            {
                [[self cameraPosition] setEnabled:YES];
                [[self flashButton] setEnabled:YES];
                
                [[self recordButton] setTitle:NSLocalizedString(@"Record", @"Recording button record title") forState:UIControlStateNormal];
                [[self recordButton] setEnabled:YES];
            }
        });
    }
    else if (context == SessionRunningAndDeviceAuthorizedContext)
    {
        BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRunning)
            {
                [[self cameraPosition] setEnabled:YES];
                [[self recordButton] setEnabled:YES];
                [[self flashButton] setEnabled:YES];
            }
            else
            {
                [[self cameraPosition] setEnabled:NO];
                [[self recordButton] setEnabled:NO];
                [[self flashButton] setEnabled:NO];
            }
        });
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}



- (IBAction)toggleRecording:(id)sender
{
    [[self recordButton] setEnabled:NO];
    if (self.navigationController.navigationBarHidden)
    {
        [self.navigationController setNavigationBarHidden:NO];
    }
    else{
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
    }
    
    dispatch_async([self sessionQueue], ^{
        if (![[self movieFileOutput] isRecording])
        {
        
            [self setLockInterfaceRotation:YES];

            
            if ([[UIDevice currentDevice] isMultitaskingSupported])
            {
                // Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after the recorded file has been saved.
                /////
                [self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]];
            }
            
            // Update the orientation on the movie file output video connection before starting recording.
            [[[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self recordVideoView] layer] connection] videoOrientation]];
            
            // Turning OFF flash for video recording
            [RecordVideoViewController setFlashMode:AVCaptureFlashModeOn forDevice:[[self videoDeviceInput] device]];
            
            // Start recording to a temporary file.
            NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"take" stringByAppendingPathExtension:@"mov"]];
            
            [[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
            ///////////
            ///////////
            ///////////
            //self.outputFileURL = [NSURL fileURLWithPath:outputFilePath];
            
        }
        else
        {
            //[self.navigationController setNavigationBarHidden:NO];
            [[self movieFileOutput] stopRecording];
            
        }
    });
}

- (IBAction)toggleCameraPosition:(id)sender
{
    [[self cameraPosition] setEnabled:NO];
    [[self recordButton] setEnabled:YES];
    [[self flashButton] setEnabled:YES];
    
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
        
        switch (currentPosition)
        {
            case AVCaptureDevicePositionUnspecified:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
        }
        
        AVCaptureDevice *videoDevice = [RecordVideoViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
        
        [[self session] beginConfiguration];
        
        [[self session] removeInput:[self videoDeviceInput]];
        if ([[self session] canAddInput:videoDeviceInput])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
            
            [RecordVideoViewController setFlashMode:AVCaptureFlashModeAuto forDevice:videoDevice];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
            
            [[self session] addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
        }
        else
        {
            [[self session] addInput:[self videoDeviceInput]];
        }
        
        [[self session] commitConfiguration];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self cameraPosition] setEnabled:YES];
            [[self recordButton] setEnabled:YES];
            [[self flashButton] setEnabled:YES];
        });
    });
}

- (IBAction)toggleFlash:(id)sender
{
    dispatch_async([self sessionQueue], ^{
        // Update the orientation on the still image output video connection before capturing.
        //[[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self recordVideoView] layer] connection] videoOrientation]];
        // check if flash is on. if it is on turn off
        // if it is off :
            // check the current position of the camera, if it is front facing change to back facing then flash mode can be enabled.
            // if the camera position is changed to front facing and flash is on turn flash off before changing position of the camera to front facing.
        // Flash set to Auto for Still Capture
    
        [RecordVideoViewController setFlashMode:AVCaptureFlashModeOn forDevice:[[self videoDeviceInput] device]];
        
        // Capture a still image.
//        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
//            
//            if (imageDataSampleBuffer)
//            {
//                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
//                UIImage *image = [[UIImage alloc] initWithData:imageData];
//                [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
//            }
//        }];
    });
}

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.videoDevice.focusMode != AVCaptureFocusModeLocked && self.videoDevice.exposureMode != AVCaptureExposureModeCustom)
    {
        CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[self recordVideoView] layer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
        [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
    }
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    CGPoint devicePoint = CGPointMake(.5, .5);
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}
#pragma mark Actions

- (IBAction)cancel:(id)sender
{
    //[self stopRunning];
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.outputFileURL.path])
    {
        NSLog(@"FILE AT PATH SHOULD BE TEMP DIRECTORY: %@", [self.outputFileURL path]);
        [[NSFileManager defaultManager] removeItemAtPath:[self.outputFileURL path] error:nil];
        
    }
    self.outputFileURL = nil;
    [self.navigationController popViewControllerAnimated:YES];
    //
    
    
}

- (IBAction)save:(id)sender
{
    
    //[self stopRunning];
    
    //if ([[NSFileManager defaultManager] fileExistsAtPath:self.outputFileURL.path])
    //{
        //Take *newTake = [[Take alloc] initWithURL:self.outputFileURL];
        // should have compleion block after take is done being created so we know if we can remove item from the temp folder.
       // [[NSNotificationCenter defaultCenter] postNotificationName:@"didCreateVideoForTake" object:newTake];
//        NSLog(@"FILE AT PATH SHOULD BE TEMP DIRECTORY: %@", [self.outputFileURL path]);
        //[[NSFileManager defaultManager] removeItemAtPath:[self.outputFileURL path] error:nil];
   // }
//    else{
//        NSLog(@"file dne");
//    }
//    
    [self.navigationController popViewControllerAnimated:YES];
    
    
    
    
}
#pragma mark File Output Delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if (error)
        NSLog(@"%@", error);

    [self setLockInterfaceRotation:NO];
    
    // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
   
    
    UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
    [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
    
    self.outputFileURL = outputFileURL;
    
    
    
    
    //self.take = [[Take alloc] initWithURL:self.outputFileURL];
//    [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
//        if (error)
//            NSLog(@"%@", error);
    
        
        //[[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        ////////////////
     if (backgroundRecordingID != UIBackgroundTaskInvalid)
     {
         [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];

     }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.saveButton setEnabled:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishRecordingVideoToURL" object:outputFileURL];
    //}];
    
}

#pragma mark Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *device = [[self videoDeviceInput] device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
            {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    });
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ([device hasFlash] && [device isFlashModeSupported:flashMode])
    {
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

#pragma mark UI

//- (void)runStillImageCaptureAnimation
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[[self recordVideoView] layer] setOpacity:0.0];
//        [UIView animateWithDuration:.25 animations:^{
//            [[[self recordVideoView] layer] setOpacity:1.0];
//        }];
//    });
//}

- (void)checkDeviceAuthorizationStatus
{
    NSString *mediaType = AVMediaTypeVideo;
    
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted)
        {
            //Granted access to mediaType
            [self setDeviceAuthorized:YES];
        }
        else
        {
            //Not granted access to mediaType
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"!!"
                                            message:@"please change privacy settings"
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                [self setDeviceAuthorized:NO];
            });
        }
    }];
}


- (void)configureCameraForHighestFrameRate:(AVCaptureDevice *)device
{
    AVCaptureDeviceFormat *bestFormat = nil;
    AVFrameRateRange *bestFrameRateRange = nil;
    for ( AVCaptureDeviceFormat *format in [device formats] ) {
        for ( AVFrameRateRange *range in format.videoSupportedFrameRateRanges ) {
            if ( range.maxFrameRate > bestFrameRateRange.maxFrameRate ) {
                bestFormat = format;
                bestFrameRateRange = range;
            }
        }
    }
    if ( bestFormat ) {
        if ( [device lockForConfiguration:NULL] == YES ) {
            device.activeFormat = bestFormat;
            device.activeVideoMinFrameDuration = bestFrameRateRange.minFrameDuration;
            device.activeVideoMaxFrameDuration = bestFrameRateRange.minFrameDuration;
            [device unlockForConfiguration];
        }
    }
}
//-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
//    
//    // Handle a movie capture
//    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo)
//    {
//        
//        NSURL *movieUrl = [info objectForKey:UIImagePickerControllerMediaURL];
//        NSString *moviePath = [(NSURL *)[info objectForKey:UIImagePickerControllerMediaURL] path];
//        
//        // create a new take instance. the url property of the take will be set to moviePath
//        // get the index path of the current section (the section whose add button was pressed in within the collection vc. pass this from the collection vc. 
//        // call method on video controller to insert a new take to the shared videos array.
//        
//        NSLog(@"moviePath: %@", moviePath);
//        
//        //VideoLibrary *ml = [[VideoLibrary alloc] init];
//        // add take to array passed from the collection view controller (via video controller)
//        
//        Take *newVideo = [[Take alloc] initWithURL:movieUrl];
//
//        NSLog(@"New video created: %@", newVideo);
//        
//        [self.scene.takes insertObject:newVideo atIndex:0];
//        
//        NSLog(@"self.scene now has %lu videos", (unsigned long)self.scene.takes.count);
//        
//        
//        if (self.completionBlock != nil)
//        {
//            self.completionBlock(YES);
//        }
//        
//        [self dismissViewControllerAnimated:NO completion:nil];
//
//    
//    }
//}

@end
