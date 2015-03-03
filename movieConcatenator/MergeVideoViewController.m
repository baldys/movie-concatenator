//
//  MergeVideoViewController.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-21.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "MergeVideoViewController.h"

@interface MergeVideoViewController ()




@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@end

@implementation MergeVideoViewController

- (IBAction)loadVideo1:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Saved Album Found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        isSelectingAssetOne = TRUE;
        [self startMediaBrowserFromViewController:self usingDelegate:self];
    }
}

- (IBAction)loadVideo2:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Saved Album Found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        isSelectingAssetOne = FALSE;
        [self startMediaBrowserFromViewController:self usingDelegate:self];
    }
}

- (BOOL)extracted_method:(AVAssetTrack *)assetTrack_video
{
    UIImageOrientation assetOrientation_  = UIImageOrientationUp;
    BOOL isSecondAssetPortrait_  = NO;
    
    CGAffineTransform secondTransform = assetTrack_video.preferredTransform;
    
    if (secondTransform.a == 0 && secondTransform.b == 1.0 &&
        secondTransform.c == -1.0 && secondTransform.d == 0)
    {
        assetOrientation_= UIImageOrientationRight;
        isSecondAssetPortrait_ = YES;
    }
    if (secondTransform.a == 0 && secondTransform.b == -1.0 &&
        secondTransform.c == 1.0 && secondTransform.d == 0)
    {
        assetOrientation_ =  UIImageOrientationLeft;
        isSecondAssetPortrait_ = YES;
    }
    if (secondTransform.a == 1.0 && secondTransform.b == 0 &&
        secondTransform.c == 0 && secondTransform.d == 1.0)
    {
        assetOrientation_ =  UIImageOrientationUp;
    }
    if (secondTransform.a == -1.0 && secondTransform.b == 0 &&
        secondTransform.c == 0 && secondTransform.d == -1.0)
    {
        assetOrientation_ = UIImageOrientationDown;
    }
    return isSecondAssetPortrait_;
}

- (IBAction)mergeAndSave:(id)sender
{
    if (self.firstAsset == nil || self.secondAsset == nil)
    {
        NSLog(@"one or more of the assets were not initialized.");
        return;
    }
    
    NSLog(@"$$$$$$$$");
    [self.activityView startAnimating];
        
    // Create AVMutableComposition object. This object will hold AVMutableCompositionTrack instances.
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    /// 1 video and audio composition tracks:
    // Add 1sr video track to composition
    AVMutableCompositionTrack *compositionTrack1_video = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    // Add 1st audio track to composition
    AVMutableCompositionTrack *compositionTrack1_audio = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];

    /// 2 video and audio composition tracks:
    // Add 2nd video track to composition
    AVMutableCompositionTrack *compositionTrack2_video = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    // Add 2nd audio track to composition
    AVMutableCompositionTrack *compositionTrack2_audio = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    ///////////////////////////////////////////////////////////////////
   //      MUTABLE      \\
   //    COMPOSITION    \\
   //___________________\\  MUTABLE COMPOSITION
   //|comptrk1|comptrk2|
   //| TRACK  |  TRACK |    - MUTABLE COMPOSITION TRACKS
//// |________|________|
//// ||      | |      ||
//// || aud1 | | aud2 ||  COMPOSITION TRACK 1 + COMPOSITION TRACK 2
//// ||  +   |+|  +   ||  (AUDIO+VIDEO)
//// || vid1 | | vid2 ||
//// ||______|_|______||
    ///////////////////////////////////////////////////////////////////
    
    // CREATE A NEW MUTABLE EMPTY COMPOSITION (this will CONTAIN THE
    // ASSETS YOU WANT TO INCLUDE IN THE NEW MERGED VIDEO)...
    //
    // AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    //
    // break them down into two composition tracks: one for audioand one for video and then add them to the mutable composition track.
    /*
    */
    /// method tat takes array of assets and returns composition.
    ///
    // CREATE METHOD THAT BREAKS DOWN AN ASSET INTO (AUDIO AND VIDEO) TRACKS:
        //->// CALL THEM FOR EACH ASSET YOU WANT TO ADD TO THE final COMPOSITION
    
    //
    ///////////////////////////////////////////////////////////////////
    
    ///* Asset tracks FOR 1ST COMPOSITION, CREATE VIDEO COMPOSITION LATYER INSTRUCTING WITH ASSET TRACKS
    
    
    //.......................................................................
    //////////////////////
    // video asset track 1
    AVAssetTrack *assetTrack1_video = [[self.firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    [compositionTrack1_video insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.firstAsset.duration) ofTrack:assetTrack1_video atTime:kCMTimeZero error:nil];
    // audio asset track
    AVAssetTrack *assetTrack1_audio = [[self.firstAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    [compositionTrack1_audio insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.firstAsset.duration) ofTrack:assetTrack1_audio atTime:kCMTimeZero error:nil];
    /////////////////////
    
    /////////////////////
    // video asset track 2
    AVAssetTrack *assetTrack2_video = [[self.secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    [compositionTrack2_video insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.secondAsset.duration) ofTrack:assetTrack2_video atTime:self.firstAsset.duration error:nil];
    // TODO HANDLE ERRORS
    
    
    // audio asset track 2
    AVAssetTrack *assetTrack2_audio = [[self.secondAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    [compositionTrack2_audio insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.secondAsset.duration) ofTrack: assetTrack2_audio atTime:self.firstAsset.duration error:nil];
    
    // [self layerInstructionForVideoTracks:[NSArray compositionTrack1_video, compositionTrack2_video]];
    /////////////////////
    
    
    //........................................................................
    /////////////////////
    // videoLayerInstruction for track 1
    AVMutableVideoCompositionLayerInstruction *firstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionTrack1_video];
    
    UIImageOrientation firstAssetOrientation_  = UIImageOrientationUp;
    BOOL isFirstAssetPortrait_  = NO;
    isFirstAssetPortrait_ = [self extracted_method:assetTrack1_video];
    
    [firstlayerInstruction setTransform:self.firstAsset.preferredTransform atTime:kCMTimeZero];
    
    [firstlayerInstruction setOpacity:0.0 atTime:self.firstAsset.duration];
    
    ///////////////////////////////////////////////////////
    // VideoLayerInstruction for track 2
    AVMutableVideoCompositionLayerInstruction *secondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionTrack2_video];
    
    BOOL isSecondAssetPortrait_;
    isSecondAssetPortrait_ = [self extracted_method:assetTrack2_video];
    [secondlayerInstruction setTransform:self.secondAsset.preferredTransform atTime:self.firstAsset.duration];
    /////////////////////////////////////////
    
    // 2.4 - Add instructions
    //TODO: add an AVMutableAudioMix
    //TODO: add AVMutableComposition
    
    //TODO: assign MutableVideoComposition and MutableAudioMix to the MutableComposition
    
    //TODO: assign an asset made from MutableComposition
    
    //TODO: make sure that the length of mutableVideoComposition and AudioMix is the same.
    
    //only then export.
    
    //  (Video composition)
    self.mainComposition = [AVMutableVideoComposition videoComposition];

    //  VIDEO INSTRUCTION
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    mainInstruction.timeRange =
    CMTimeRangeMake(kCMTimeZero, CMTimeAdd(self.firstAsset.duration, self.secondAsset.duration));
    
    mainInstruction.layerInstructions =
    [NSArray arrayWithObjects:firstlayerInstruction, secondlayerInstruction,nil];
    
    self.mainComposition.instructions = [NSArray arrayWithObject:mainInstruction];
    self.mainComposition.frameDuration = CMTimeMake(1, 30);
    
    CGSize naturalSizeFirst, naturalSizeSecond;
    if(isFirstAssetPortrait_)
    {
        naturalSizeFirst = CGSizeMake(assetTrack1_video.naturalSize.height, assetTrack1_video.naturalSize.width);
    }
    else
    {
        naturalSizeFirst = assetTrack1_video.naturalSize;
    }

    if(isSecondAssetPortrait_)
    {
    naturalSizeSecond = CGSizeMake(assetTrack2_video.naturalSize.height, assetTrack2_video.naturalSize.width);
    }
    else
    {
        naturalSizeSecond = assetTrack2_video.naturalSize;

    }

    float renderWidth, renderHeight;
    if(naturalSizeFirst.width > naturalSizeSecond.width)
    {
    
        renderWidth = naturalSizeFirst.width;
    }
    else
    {
        renderWidth = naturalSizeSecond.width;

    }

    if(naturalSizeFirst.height > naturalSizeSecond.height)
    {
        renderHeight = naturalSizeFirst.height;
    }
    else
    {
        renderHeight = naturalSizeSecond.height;
    }

    self.mainComposition.renderSize = CGSizeMake(renderWidth, renderHeight);
    
    // check that the duration of the time and video track duration are the same and if not dont eport
    
    [self exportVideoComposition:mixComposition];
}


// return a new composition by adding an asset to a compositon
- (AVMutableComposition*) appendAsset:(AVAsset *)asset ToComposition:(AVMutableComposition*)composition
{
    // video composition track
    //add a video track to the composition.
    AVMutableCompositionTrack *compositionTrack_video =
    [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // audio composition track
    //add anaudio track to a composition.
    AVMutableCompositionTrack *compositionTrack_audio =
    [composition addMutableTrackWithMediaType:AVMediaTypeAudio                                     preferredTrackID:kCMPersistentTrackID_Invalid];
    
    return composition;
}






// existing asset -> audio+video asset tracks -> add to  MutableComposition
// put in some controller class
- (void) exportVideoComposition:(AVMutableComposition*)composition
{
    // 5 - Create exporter
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    
    exporter.outputURL = [self createOutputURL];
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = self.mainComposition;
    //TODO: exporter.audioComposition = an instance of MutableAudioMix
    
    [exporter exportAsynchronouslyWithCompletionHandler:
     ^{
         dispatch_async(dispatch_get_main_queue(),
        ^{
            [self exportDidFinish:exporter];
                            
        });
     }];
}

// TODO: put into video model class so that for each video you can retrieve the url path that contains it?
- (NSURL*) createOutputURL
{
    // 4 - Get path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"mergeVideo-%d.mov",arc4random() % 1000]];
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    return url;
}

-(BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate
{
    // 1 - Validation
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
    {
        return NO;
    }
    
    // 2 - Create image picker
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, kUTTypeAudiovisualContent, nil];
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = YES;
    mediaUI.delegate = delegate;
    
    // 3 - Display image picker
    [controller presentModalViewController:mediaUI animated: YES];
    
    return YES;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 1 - Get media type
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    // 2 - Dismiss image picker
    [self dismissModalViewControllerAnimated:NO];
    
    // 3 - Handle video selection
    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo)
    {
        if (isSelectingAssetOne)
        {
            NSLog(@"Video One  Loaded");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Loaded" message:@"Video One Loaded"
                delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            self.firstAsset = [AVAsset assetWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
        }
        else
        {
            NSLog(@"Video two Loaded");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Loaded" message:@"Video Two Loaded" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            self.secondAsset = [AVAsset assetWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
        }
    }
}

-(void)exportDidFinish:(AVAssetExportSession*)session
{
    if (session.status == AVAssetExportSessionStatusCompleted)
    {
        NSURL *outputURL = session.outputURL;
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL])
        {
            [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error)
            {
                dispatch_async(dispatch_get_main_queue(),
                ^{
                    if (error)
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    }
                    else
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    }
                });
            }];
        }
    }

    self.firstAsset = nil;
    self.secondAsset = nil;
    //[activityView stopAnimating];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end

