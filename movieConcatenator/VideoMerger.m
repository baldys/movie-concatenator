//
//  VideoMerger.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-03.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "VideoMerger.h"

@implementation VideoMerger




- (void)concatenateAssets:(NSArray *)assetArray
{
    // dispatch start
    //AVAsset *temp;
    //for (AVAsset *asset in assetArray)
    //{
    // temp = [self appendAsset:asset toPreviousAsset:temp];
    //}
    //NSLog(@"ended");
    // dispatch end
    
    [self appendAsset:assetArray[0] toPreviousAsset:assetArray[1]];
}



- (BOOL)isAssetPortrait:(AVAssetTrack *)assetTrack_video
{
    UIImageOrientation assetOrientation_  = UIImageOrientationUp;
    BOOL isAssetPortrait_  = NO;
    
    CGAffineTransform aTransform = assetTrack_video.preferredTransform;
    // right  left   up     down
    // [0  1] [0 -1] [1  0] [-1 0]
    // [-1 0] [1  0] [0  1] [0 -1]
    if (aTransform.a == 0 && aTransform.b == 1.0 &&
        aTransform.c == -1.0 && aTransform.d == 0)
    {
        assetOrientation_= UIImageOrientationRight;
        isAssetPortrait_ = YES;
    }
    if (aTransform.a == 0 && aTransform.b == -1.0 &&
        aTransform.c == 1.0 && aTransform.d == 0)
    {
        assetOrientation_ =  UIImageOrientationLeft;
        isAssetPortrait_ = YES;
    }
    if (aTransform.a == 1.0 && aTransform.b == 0 &&
        aTransform.c == 0 && aTransform.d == 1.0)
    {
        assetOrientation_ =  UIImageOrientationUp;
    }
    if (aTransform.a == -1.0 && aTransform.b == 0 &&
        aTransform.c == 0 && aTransform.d == -1.0)
    {
        assetOrientation_ = UIImageOrientationDown;
    }
    return isAssetPortrait_;
}

- (void)appendAsset:(AVAsset*)asset2 toPreviousAsset:(AVAsset*)asset1
{
    //if (!asset1) return asset2;
    
    NSLog(@"$$$$$$$$");
    //[self.activityView startAnimating];
    
    // Create AVMutableComposition object. This object will hold AVMutableCompositionTrack instances.
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    // get the count of the array, make that number of audio tracks and video tracks and add to mix composition
    
    
    
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
    
    
    /*
     
     Asset[ ] -> Asset
     
     Append(asset1, asset2) -> newAsset
     Append(newAsset, asset3)
     asset1 insertion point = 0
     asset2 insertion point = asset1 duration
     
     AVMutableComposition *mixComposition = [AVMutableComposition composition]
     
     // Video Composition
     /////// compositionWithAsset:(AVAsset*) forType:(AVMediaType)mediaType
     
     1) AVMutableCompositionTrack *compositionTrack_video =
     [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
     
     2) AVAssetTrack *assetTrack_video =
     [[self.firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
     
     3) [compositionTrack_video insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.firstAsset.duration) ofTrack:assetTrack_video atTime:kCMTimeZero error:nil];
     
     // Audio Composition Track
     1) AVMutableCompositionTrack *compositionTrack_audio =
     [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
     
     2) AVAssetTrack *assetTrack_audio =
     [[self.firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
     
     3) [compositionTrack_audio insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.firstAsset.duration) ofTrack:assetTrack_video atTime:kCMTimeZero error:nil];
     
     
     */
    
    //.......................................................................
    //////////////////////
    // video asset track 1
    AVAssetTrack *assetTrack1_video = [[asset1 tracksWithMediaType:AVMediaTypeVideo] firstObject];
    [compositionTrack1_video insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset1.duration) ofTrack:assetTrack1_video atTime:kCMTimeZero error:nil];
    // audio asset track
    AVAssetTrack *assetTrack1_audio = [[asset1 tracksWithMediaType:AVMediaTypeAudio] firstObject];
    [compositionTrack1_audio insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset1.duration) ofTrack:assetTrack1_audio atTime:kCMTimeZero error:nil];
    /////////////////////
    
    /////////////////////
    // video asset track 2
    AVAssetTrack *assetTrack2_video = [[asset2 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    [compositionTrack2_video insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset2.duration) ofTrack:assetTrack2_video atTime:asset1.duration error:nil];
    // TODO HANDLE ERRORS
    
    
    // audio asset track 2
    AVAssetTrack *assetTrack2_audio = [[asset2 tracksWithMediaType:AVMediaTypeAudio] firstObject];
    [compositionTrack2_audio insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset2.duration) ofTrack: assetTrack2_audio atTime:asset1.duration error:nil];
    
    // [self layerInstructionForVideoTracks:[NSArray compositionTrack1_video, compositionTrack2_video]];
    /////////////////////
    
    
    //........................................................................
    /////////////////////
    // videoLayerInstruction for track 1
    AVMutableVideoCompositionLayerInstruction *firstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionTrack1_video];
    
//    [firstlayerInstruction setTransform:asset1.preferredTransform atTime:kCMTimeZero];
//    [firstlayerInstruction setOpacity:0.0 atTime:asset1.duration];
 
   // BOOL isFirstAssetPortrait_ = [self isAssetPortrait:assetTrack1_video];
    
    UIImageOrientation firstAssetOrientation_  = UIImageOrientationUp;
    BOOL isFirstAssetPortrait_  = NO;
    
    CGAffineTransform aTransform1 = assetTrack1_video.preferredTransform;
    // right  left   up     down
    // [0  1] [0 -1] [1  0] [-1 0]
    // [-1 0] [1  0] [0  1] [0 -1]
    if (aTransform1.a == 0 && aTransform1.b == 1.0 &&
        aTransform1.c == -1.0 && aTransform1.d == 0)
    {
        firstAssetOrientation_= UIImageOrientationRight;
        isFirstAssetPortrait_ = YES;
    }
    if (aTransform1.a == 0 && aTransform1.b == -1.0 &&
        aTransform1.c == 1.0 && aTransform1.d == 0)
    {
        firstAssetOrientation_ =  UIImageOrientationLeft;
        isFirstAssetPortrait_ = YES;
    }
    if (aTransform1.a == 1.0 && aTransform1.b == 0 &&
        aTransform1.c == 0 && aTransform1.d == 1.0)
    {
        firstAssetOrientation_ =  UIImageOrientationUp;
    }
    if (aTransform1.a == -1.0 && aTransform1.b == 0 &&
        aTransform1.c == 0 && aTransform1.d == -1.0)
    {
        firstAssetOrientation_ = UIImageOrientationDown;
    }
    CGFloat FirstAssetScaleToFitRatio = 320.0/assetTrack1_video.naturalSize.width;
    
    if(isFirstAssetPortrait_){
        FirstAssetScaleToFitRatio = 320.0/assetTrack1_video.naturalSize.height;
        
        CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
        [firstlayerInstruction setTransform:CGAffineTransformConcat(assetTrack1_video.preferredTransform, FirstAssetScaleFactor) atTime:kCMTimeZero];
    }else{
        CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
        [firstlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(assetTrack1_video.preferredTransform, FirstAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:kCMTimeZero];
    }
    [firstlayerInstruction setTransform:asset1.preferredTransform atTime:kCMTimeZero];
    [firstlayerInstruction setOpacity:0.0 atTime:asset1.duration];
    
    
    ///////////////////////////////////////////////////////
    // VideoLayerInstruction for track 2
    AVMutableVideoCompositionLayerInstruction *secondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionTrack2_video];
    
    UIImageOrientation secondAssetOrientation_  = UIImageOrientationUp;
    BOOL isSecondAssetPortrait_  = NO;
    CGAffineTransform aTransform2 = assetTrack2_video.preferredTransform;
    
    // right  left   up     down
    // [0  1] [0 -1] [1  0] [-1 0]
    // [-1 0] [1  0] [0  1] [0 -1]
    if (aTransform2.a == 0 && aTransform2.b == 1.0 &&
        aTransform2.c == -1.0 && aTransform2.d == 0)
    {
        secondAssetOrientation_= UIImageOrientationRight;
        isSecondAssetPortrait_ = YES;
    }
    if (aTransform2.a == 0 && aTransform2.b == -1.0 &&
        aTransform2.c == 1.0 && aTransform2.d == 0)
    {
        secondAssetOrientation_ =  UIImageOrientationLeft;
        isSecondAssetPortrait_ = YES;
    }
    if (aTransform2.a == 1.0 && aTransform2.b == 0 &&
        aTransform2.c == 0 && aTransform2.d == 1.0)
    {
        secondAssetOrientation_ =  UIImageOrientationUp;
    }
    if (aTransform2.a == -1.0 && aTransform2.b == 0 &&
        aTransform2.c == 0 && aTransform2.d == -1.0)
    {
        secondAssetOrientation_ = UIImageOrientationDown;
    }
    CGFloat SecondAssetScaleToFitRatio = 320.0/assetTrack2_video.naturalSize.width;
    if(isSecondAssetPortrait_)
    {
        SecondAssetScaleToFitRatio = 320.0/assetTrack2_video.naturalSize.height;
        CGAffineTransform SecondAssetScaleFactor = CGAffineTransformMakeScale(SecondAssetScaleToFitRatio,SecondAssetScaleToFitRatio);
        [secondlayerInstruction setTransform:CGAffineTransformConcat(assetTrack2_video.preferredTransform, SecondAssetScaleFactor) atTime:asset1.duration];
    }
    else
    {
        ;
        CGAffineTransform SecondAssetScaleFactor = CGAffineTransformMakeScale(SecondAssetScaleToFitRatio,SecondAssetScaleToFitRatio);
        [secondlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(assetTrack2_video.preferredTransform, SecondAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:asset1.duration];
    }

    [secondlayerInstruction setTransform:asset2.preferredTransform atTime:asset1.duration];


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
    CMTimeRangeMake(kCMTimeZero, CMTimeAdd(asset1.duration, asset2.duration));
    
    mainInstruction.layerInstructions =
    [NSArray arrayWithObjects:firstlayerInstruction, secondlayerInstruction,nil];
    
    self.mainComposition.instructions = [NSArray arrayWithObject:mainInstruction];
    self.mainComposition.frameDuration = CMTimeMake(1, 30);
    self.mainComposition.renderSize = CGSizeMake(320.0, 480.0);
    
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
- (AVMutableComposition*) mixCompositionFromAsset
{
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    
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
                            NSLog(@"exported video");
                            
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

/*
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 1 - Get media type
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    // 2 - Dismiss image picker
    //[self dismissModalViewControllerAnimated:NO];
    
    // 3 - Handle video selection
    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo)
    {
        //if (isSelectingAssetOne)
        //{
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
*/

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
}




@end
