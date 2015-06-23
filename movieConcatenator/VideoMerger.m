//
//  VideoMerger.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-03.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "VideoMerger.h"
#import "PlaybackViewController.h"

#define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )
@interface VideoMerger ()

@property (nonatomic, getter = isFrontFacingVideoInTakes) BOOL frontFacingVideoInTakes;
@property (nonatomic, strong) NSMutableArray *tempClips;
@property (nonatomic, strong) dispatch_queue_t exportQueue;

@property (nonatomic, strong) AVAssetExportSession *scaleAssetExportSession;
@property (nonatomic) AVAssetExportSessionStatus scaleAssetExportStatus;
@property (nonatomic) NSInteger clipsToAdd;
@end

@implementation VideoMerger

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.videoLibrary = [VideoLibrary libraryWithFilename:@"VideoDatalist.plist"];
      
    }
    return self;
}

- (BOOL) checkForFrontFacingVideos:(NSArray*)takes
{
    self.clipsToAdd = takes.count;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsPreparedForComposition:) name:@"assetsPreparedForComposition" object:nil];
    for (Take *take in takes)
    {
        switch (take.videoOrientationAndPosition)
        {
            case LandscapeLeft_Back:
                
                // scale this current composition video track down to the size of the smallest composition track in the composition
                
                break;
                
            case LandscapeLeft_Front:
                
                // if isFrontFacingVideoInAssets = NO then this is the first asset in the compostion that is front facing, so we must scale all previous videos in the composition down to a size that will fit this one. otherwise there will be black bars on the sides of this video.
                
                
                self.frontFacingVideoInTakes = YES;
                return YES;
                
                
            case LandscapeRight_Back:
                
                break;
                
            case LandscapeRight_Front:
                
                self.frontFacingVideoInTakes = YES;
                // front facing video is in list of takes, overwrite previously set widths,heights for the other videos.
                return YES;
            
                
            default:
                break;
                
        }

    }
    return NO;
    
}
// get the assets from takes
- (void)prepareAssetsFromTakes:(NSArray*)takes
{
    /// GET AN ARRAY OF ASSETS
    /*
     -   from an array of takes, get each asset from the take's file url for which it is stored on the disk. Put these assets in an array of "videoClips"
    */
    /// - GET AN ARRAY OF ASSET TIME RANGES
    /*
     -   also, get the duration of each asset and create a timeRange for each asset (kCMTimeZero to asset.duration) and insert it into the "clipTimeRanges" array.
     -   use avasync key value loading (if not loaded) to get the duration of the asset without blocking the main thread... (which i likely did not do correctly and still need a completion block)
    */
    /// - CHECK IF FRONT FACING/BACK FACING VIDEOS IN COMPOSITION ARE MIXED
    /*
    -   also check if there are any videos in the array are front facing, so that we know whether or not to scale down the video clips that are recorded with the back facing camera (1920x1080 whereas the front facing camera takes videos that are 1280x720)
    -   if no front facing videos are in this array, then no scaling needs to be done on the videos and they can all have the same 1920x1080 resolution
    -   if there is at least one video that is front facing, we must scale all videos (that are back facing) down to 1280x720 otherwise the final composition will contain videos where large parts of the video frame are cropped or the front facing videos contain unsightly black bars on the bottom and right edges of the video.
    */
    //NSMutableArray *clips = [NSMutableArray array];
   
    self.tempClips = [NSMutableArray arrayWithCapacity:takes.count];
    
    
    self.frontFacingVideoInTakes = [self checkForFrontFacingVideos:takes];
    
    for (int i=0; i<takes.count; i++)
    {
        Take *take = takes[i];
        NSDictionary *options = @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES };
        // Load the values of AVAsset keys to inspect subsequently
        //NSArray *assetKeysToLoadAndTest = @[@"playable", @"composable", @"tracks", @"duration"];
        BOOL isTakeRecordedUsingBackFacingCamera = NO;
        if (([take videoOrientationAndPosition] == LandscapeLeft_Back )||
            ([take videoOrientationAndPosition] == LandscapeRight_Back))
        {
            isTakeRecordedUsingBackFacingCamera = YES;
        }
        
        NSLog(@"take duration: %lld, %d, %f", take.duration.value, take.duration.timescale, CMTimeGetSeconds(take.duration));
        
        AVAsset *urlAsset = [[AVURLAsset alloc] initWithURL:[take getFileURL] options:options];
        
        
//        [take loadDurationOfAsset:urlAsset withCompletionHandler:^{
//            NSValue *timeRange = [NSValue valueWithCMTimeRange:CMTimeRangeMake(kCMTimeZero, take.duration)];
//            
//            [self.clipTimeRanges addObject:timeRange];
//        }];
        
        
       // CMTime durationOfAsset = urlAsset.duration;
        NSLog(@"duration of asset: %f", CMTimeGetSeconds(urlAsset.duration));
        //durationOfAsset = take.duration;
        
        NSValue *timeRange = [NSValue valueWithCMTimeRange:CMTimeRangeMake(kCMTimeZero, urlAsset.duration)];
        
        [self.clipTimeRanges addObject:timeRange];
        
        
        
        if (self.frontFacingVideoInTakes && isTakeRecordedUsingBackFacingCamera)
        {
            //dispatch_block_notify(<#^(void)block#>, <#dispatch_queue_t queue#>, <#^(void)notification_block#>)
            
            NSString *pathComponent = [NSString stringWithFormat:@"take-1280x720-%i", arc4random()%1000];
            
            NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[pathComponent stringByAppendingPathExtension:@"mov"]];
            NSURL *scaledAssetURL = [NSURL fileURLWithPath:outputFilePath];
            
//            dispatch_async(self.exportQueue, ^{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                [self exportAssetToScaleDown:urlAsset toURL:scaledAssetURL indexInArray:i];
                
            });
            

            //AVAssetExportSessionStatus status;
                
                
            //});
            
        }
        else
        {
            //dispatch_async(self.exportQueue, ^{
            //[self.tempClips addObject:urlAsset];
            
            [self.tempClips addObject:urlAsset];
            //});
            
            
        }

        
        
    }
    
    if (!self.frontFacingVideoInTakes)
    {
        self.videoClips = [NSArray arrayWithArray:self.tempClips];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"assetsPreparedForComposition" object:self.videoClips];
    }
//    for (int i=0; i<takes.count; i++)
//    {
//        Take *take = takes[i];
//        NSDictionary *options = @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES };
//        // Load the values of AVAsset keys to inspect subsequently
//        //NSArray *assetKeysToLoadAndTest = @[@"playable", @"composable", @"tracks", @"duration"];
//        BOOL isTakeRecordedUsingBackFacingCamera = NO;
//        if (([take videoOrientationAndPosition] == LandscapeLeft_Back )||
//            ([take videoOrientationAndPosition] == LandscapeRight_Back))
//        {
//            isTakeRecordedUsingBackFacingCamera = YES;
//        }
//        
//        AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:[take getFileURL] options:options];
//        
//        CMTime durationOfAsset = urlAsset.duration;
//        durationOfAsset = take.duration;
//        
//        NSValue *timeRange = [NSValue valueWithCMTimeRange:CMTimeRangeMake(kCMTimeZero, durationOfAsset)];
//        
//        [self.clipTimeRanges addObject:timeRange];
//        
//        
//        
//        if (self.frontFacingVideoInTakes && isTakeRecordedUsingBackFacingCamera)
//        {
//            //dispatch_block_notify(<#^(void)block#>, <#dispatch_queue_t queue#>, <#^(void)notification_block#>)
//            
//            NSString *pathComponent = [NSString stringWithFormat:@"take-1280x720-%i", arc4random()%1000];
//            
//            NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[pathComponent stringByAppendingPathExtension:@"mov"]];
//            NSURL *scaledAssetURL = [NSURL fileURLWithPath:outputFilePath];
//            
//            dispatch_async(self.exportQueue, ^{
//                [self exportAssetToScaleDown:urlAsset toURL:scaledAssetURL indexInArray:(NSInteger)index];
//           
//
//                
//            });
//    
//        }
//        else
//        {
//            [self.tempClips addObject:urlAsset];
//            
//        }
    
    
        
        
        
        //AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:[take getFileURL] options:options];
        
       
        //[clips addObject:urlAsset];
        //[self.tempClips addObject:urlAsset];
        
        
///
   // }
///
    /*
     if (self.frontFacingVideoInTakes)
     {
     NSLog(@"front facing video is in the group of takes.");
     for (int i=0; i<takes.count; i++)
     {
     // take the videos recorded using the back facing camera and scale them down
     if ([takes[i] videoOrientationAndPosition] == (LandscapeLeft_Back|LandscapeRight_Back))
     {
     NSLog(@"video was recorded using back facing camera, so this video willbe exported smaller?");
     
     dispatch_async(self.exportQueue, ^{
     
     [self exportAssetToScaleDown:self.tempClips[i]];
     NSLog(@"temp clip %i: %@", i, self.tempClips[i]);
     });
     
     
     
     
     }
     }
     
     }
     */
    
    
    
    

    

    
    //[self videoClipTimeRangesFromAssets:clips];
    
    
    
    
}



- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    self.scaleAssetExportStatus = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
    if (self.scaleAssetExportStatus == AVAssetExportSessionStatusCompleted)
    {
        
    }
    
    
}



// export the assets  that use back-facing camera if a composition is being created where mixed (front-facing with back facing) assets are used as scaled down versions so they are all the same size
- (void)exportAssetToScaleDown:(AVAsset*)assetToScale toURL:(NSURL*)exportURL indexInArray:(NSInteger)index
{
//    if (!self.scaleAssetExportSession)
//    {
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:assetToScale presetName:AVAssetExportPreset1280x720];
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
    //}
    
    //[exporter addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:NULL];
    
    //exporter.outputURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"scaled-down-asset-%i-.mov", arc4random() % 1000]]];
    
    exporter.outputURL = exportURL;
    //__block BOOL success = NO;
    //__weak __block VideoMerger *weakSelf = (VideoMerger*)self;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           self.scaleAssetExportStatus = exporter.status;
                           
                           if (exporter.status ==AVAssetExportSessionStatusCompleted)
                           {
                               
                               [self.tempClips addObject:[AVURLAsset assetWithURL:exporter.outputURL]];
                               // replace the current url of the asset with the new scaled down asset.
                               //                                   [self.tempClips addObject:[AVURLAsset assetWithURL:exporter.outputURL]];
                              
                               NSLog(@"successfully scaled down asset %i \n the url for this exported asset is at: %@ \n and added it to the array of temp clips.", index, exporter.outputURL);
                               
                               NSLog(@"clips to add(number of takes): %i \n number of temp clips: %i", self.clipsToAdd, self.tempClips.count);
                               
                               if (self.tempClips.count == self.clipsToAdd)
                               {
                                   self.videoClips = [NSArray arrayWithArray:self.tempClips];
                                   
                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"assetsPreparedForComposition" object:self.videoClips];
                               }
                           }
                           else if (exporter.status == AVAssetExportSessionStatusFailed)
                           {
                              
                               [self.tempClips insertObject:assetToScale atIndex:index];
                               
                               
                           }
                           
                        
                           
                           
                           
                       });
        
        
    }];
    
    
    
    
    
}
//- (void)buildPassThroughVideoComposition:(AVMutableVideoComposition *)videoComposition forComposition:(AVMutableComposition *)composition
//{
//
//    // Make a "pass through video track" video composition.
//    AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//    passThroughInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [composition duration]);
//    
//    AVAssetTrack *videoTrack = [[composition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//    AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
//    
//    passThroughInstruction.layerInstructions = [NSArray arrayWithObject:passThroughLayer];
//    videoComposition.instructions = [NSArray arrayWithObject:passThroughInstruction];
//}




- (AVAsset*)buildTransitionComposition:(NSArray*)takes
{
        
    self.transitionDuration = CMTimeMakeWithSeconds(600, 600); // default transition time=1second
    
    self.composition = [AVMutableComposition composition];
    self.videoComposition = [AVMutableVideoComposition videoComposition];
    
    NSInteger i;
    CMTime insertionTime = kCMTimeZero;

    
    NSMutableArray *instructions = [NSMutableArray array];
    
    
    // Make transitionDuration no greater than half the shortest clip duration.
    CMTime transitionDuration = CMTimeMakeWithSeconds(2, 1);
    for (i = 0; i < _videoClips.count; i++ )
    {
        AVURLAsset *asset = _videoClips[i];
        
        NSValue *clipTimeRange = [_clipTimeRanges objectAtIndex:i];
        CMTime videoClipDuration = asset.duration;
        
        float videoClipSeconds = videoClipDuration.value/videoClipDuration.timescale;
        NSLog(@"duration of video clip: %f", videoClipSeconds );
        
        float minimumVideoClipTime;
        
        // for the first and last clips, the minimum clip time is the duration of one transition
        if (i == 0 || i == (_videoClips.count-1))
        {
            minimumVideoClipTime = (transitionDuration.value/transitionDuration.timescale)*1.01;
        }
        // the durations of the clips in the middle of the composition need to be longer than 2x the transition duration otherwise export will fail
        else
        {
            minimumVideoClipTime = (transitionDuration.value/transitionDuration.timescale)*2.01;
        }
        NSLog(@"minimum time of video clip %f", minimumVideoClipTime);
        
        if (videoClipSeconds < minimumVideoClipTime)
        {
            NSLog(@"THIS VIDEO IS TOO SHORT TO ADD TRANSITIONS");
            NSLog(@"videos will be combined with no transitions");
            
            return [self spliceAssets:takes];
            
        }
        

        if (clipTimeRange)
        {
            CMTime halfClipDuration = [clipTimeRange CMTimeRangeValue].duration;
            halfClipDuration.timescale *= 2;
            transitionDuration = CMTimeMinimum(transitionDuration, halfClipDuration);
        }
    }
    // Set up the video composition if we are to perform crossfade or push transitions between clips.
    //NSMutableArray *instructions = [NSMutableArray array];
    
    // Add two video tracks and two audio tracks.
    AVMutableCompositionTrack *compositionVideoTracks[2];
    AVMutableCompositionTrack *compositionAudioTracks[2];
    compositionVideoTracks[0] = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    compositionVideoTracks[1] = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    compositionAudioTracks[0] = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    compositionAudioTracks[1] = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    
    
    CMTimeRange *passThroughTimeRanges = alloca(sizeof(CMTimeRange) * [_videoClips count]);
    CMTimeRange *transitionTimeRanges = alloca(sizeof(CMTimeRange) * [_videoClips count]);
    

    // Place clips into alternating video & audio tracks in composition, overlapped by transitionDuration.
    
   
    for (i = 0; i < _videoClips.count; i++ )
    {
//        ////////////////////////////////////////////////////////////////////
//        insertionTime = CMTimeAdd(insertionTime, CMTimeMakeWithSeconds(3, 1));
//        ///////////////////////////////////////////////////////////////
        NSLog(@"videoClips.count: %lu", (unsigned long)_videoClips.count);
        NSInteger alternatingIndex = i % 2; // alternating targets: 0, 1, 0, 1, ...
        AVURLAsset *asset = [_videoClips objectAtIndex:i];
        
        //preferredTransform = asset.preferredTransform;
        
        NSValue *clipTimeRange = [_clipTimeRanges objectAtIndex:i];
        
        CMTimeRange timeRangeInAsset;
        if (clipTimeRange)
        {
            timeRangeInAsset = [clipTimeRange CMTimeRangeValue];
        }
        else
        {
            timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [asset duration]);
        }
   
        
        AVAssetTrack *assetTrack_video = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];


        [compositionVideoTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:assetTrack_video atTime:insertionTime error:nil];
        
        if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] != 0)
        {
            AVAssetTrack *assetTrack_audio = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
            [compositionAudioTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:assetTrack_audio atTime:insertionTime error:nil];
            
        }
        
        // Remember the time range in which this clip should pass through.
        // Every clip after the first begins with a transition.
        // Every clip before the last ends with a transition.
        // Exclude those transitions from the pass through time ranges.
        passThroughTimeRanges[i] = CMTimeRangeMake(insertionTime, timeRangeInAsset.duration);
        if (i > 0)
        {
            passThroughTimeRanges[i].start = CMTimeAdd(passThroughTimeRanges[i].start, transitionDuration);
            passThroughTimeRanges[i].duration = CMTimeSubtract(passThroughTimeRanges[i].duration, transitionDuration);
        }
        if (i+1 < [_videoClips count])
        {
            passThroughTimeRanges[i].duration = CMTimeSubtract(passThroughTimeRanges[i].duration, transitionDuration);
        }
        
        // The end of this clip will overlap the start of the next by transitionDuration.
        // (Note: this arithmetic falls apart if timeRangeInAsset.duration < 2 * transitionDuration.)

        insertionTime = CMTimeAdd(insertionTime, timeRangeInAsset.duration);
        // insertionTime = CMTimeAdd(insertionTime
        insertionTime = CMTimeSubtract(insertionTime, transitionDuration);
        
        // Remember the time range for the transition to the next item.
//        if (i+1 < _videoClips.count)
//        {
            transitionTimeRanges[i] = CMTimeRangeMake(insertionTime, transitionDuration);
        //}

    }
    
    //[instructions addObject:videoCompositionInstruction];
  
    
    CMTime transformTime = kCMTimeZero;
    
    // Cycle between "pass through A", "transition from A to B", "pass through B", "transition from B to A".
    for (int i=0; i<_videoClips.count; i++ )
    {
        BOOL applyRotationToTransitionTimeRange = NO;
        AVURLAsset *asset1 = _videoClips[i];
        
        AVAssetTrack *assetTrack_video1 = [[asset1 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        
        
        NSInteger alternatingIndex = i % 2; // alternating targets
    
        // Pass through clip i.
        AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        passThroughInstruction.timeRange = passThroughTimeRanges[i];
        AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[alternatingIndex]];
      
        CGAffineTransform transform = assetTrack_video1.preferredTransform;
        if (transform.a == -1.0f && transform.d == -1.0f)
        {
            CGAffineTransform t2 = CGAffineTransformMake(-1, 0, 0, -1,1920,1080);
            CGAffineTransform t3 = CGAffineTransformConcat(asset1.preferredTransform, t2);
            NSLog(@"transition time range.start = %lld", transitionTimeRanges[i].start.value/transitionTimeRanges[i].start.timescale);
            
            [passThroughLayer setTransformRampFromStartTransform:t3 toEndTransform:t3 timeRange:passThroughTimeRanges[i]];
            applyRotationToTransitionTimeRange = YES;
        }
    
        passThroughInstruction.layerInstructions = [NSArray arrayWithObject:passThroughLayer];
        
        [instructions addObject:passThroughInstruction];
        
        transformTime = CMTimeAdd(transformTime, asset1.duration);
 
        if (i+1 < [_videoClips count])
        {
            AVURLAsset *asset2 = _videoClips[i+1];
            // Add transition from clip i to clip i+1.
            AVAssetTrack *assetTrack_video2 = [asset2 tracksWithMediaType:AVMediaTypeVideo][0];
            CGAffineTransform transform2 = assetTrack_video2.preferredTransform;
            AVMutableVideoCompositionInstruction *transitionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            
            transitionInstruction.timeRange = transitionTimeRanges[i];
            
            AVMutableVideoCompositionLayerInstruction *fromLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[alternatingIndex]];
            
            AVMutableVideoCompositionLayerInstruction *toLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[1-alternatingIndex]];
            
            if (self.transitionType == TransitionTypeCrossFade)
            {
                // Fade out the fromLayer by setting a ramp from 1.0 to 0.0.
                [fromLayer setOpacityRampFromStartOpacity:1.0 toEndOpacity:0.0 timeRange:transitionTimeRanges[i]];
                
                // check clip[i+1]'s asset track to see if it needs to be rotated during the transition
                CGAffineTransform transform2 = assetTrack_video2.preferredTransform;
                if (assetTrack_video2.preferredTransform.a == -1 && assetTrack_video2.preferredTransform.d == -1)
                {
                   
                    CGAffineTransform t2 = CGAffineTransformMake(-1, 0, 0, -1,1920,1080);
                    CGAffineTransform t3 = CGAffineTransformConcat(asset2.preferredTransform, t2);
        
                    [toLayer setTransformRampFromStartTransform:t3 toEndTransform:t3 timeRange:transitionTimeRanges[i]];
                }
                // if asset1 has been rotated in its pass through time range, then it also needs to be rotated for the time range where it fades out during the transition to the next asset.
                if (applyRotationToTransitionTimeRange)
                {
                    CGAffineTransform t2 = CGAffineTransformMake(-1, 0, 0, -1,1920,1080);
                    CGAffineTransform t3 = CGAffineTransformConcat(asset1.preferredTransform, t2);
                    
                    [fromLayer setTransformRampFromStartTransform:t3 toEndTransform:t3 timeRange:transitionTimeRanges[i]];
                    
                    ///[fromLayer setTransform:t3 atTime:transitionTimeRanges[i].start];
                }
                
                //[fromLayer setTransform:preferredTransform atTime:transformTime];
            }
            else if (self.transitionType == TransitionTypePush)
            {
                // Set a transform ramp on fromLayer from identity to all the way left of the screen.
                
                // Set a transform ramp on toLayer from all the way right of the screen to identity.
                if (assetTrack_video2.preferredTransform.a == -1 && assetTrack_video2.preferredTransform.d == -1)
                {
                    
                    CGAffineTransform t2 = CGAffineTransformMake(-1, 0, 0, -1,1920,1080);
                    CGAffineTransform t3 = CGAffineTransformConcat(asset2.preferredTransform, t2);
                    
                    //[toLayer setTransformRampFromStartTransform:t3 toEndTransform:t3 timeRange:transitionTimeRanges[i]];
                    
                    [fromLayer setTransformRampFromStartTransform:t3 toEndTransform:CGAffineTransformConcat(t3, CGAffineTransformMakeTranslation(-self.composition.naturalSize.width, 0.0)) timeRange:transitionTimeRanges[i]];
                }
                else
                {
                    [fromLayer setTransformRampFromStartTransform:CGAffineTransformIdentity toEndTransform:CGAffineTransformMakeTranslation(-self.composition.naturalSize.width, 0.0) timeRange:transitionTimeRanges[i]];
                }
            
     
                if (applyRotationToTransitionTimeRange)
                {
                    CGAffineTransform t2 = CGAffineTransformMake(-1, 0, 0, -1,1920,1080);
                    CGAffineTransform t3 = CGAffineTransformConcat(asset1.preferredTransform, t2);
                    
                    //[fromLayer setTransformRampFromStartTransform:t3 toEndTransform:t3 timeRange:transitionTimeRanges[i]];
                    
                    [toLayer setTransformRampFromStartTransform:CGAffineTransformConcat(t3,CGAffineTransformMakeTranslation(+self.composition.naturalSize.width, 0.0)) toEndTransform:t3 timeRange:transitionTimeRanges[i]];
                    
                    ///[fromLayer setTransform:t3 atTime:transitionTimeRanges[i].start];
                }
                else
                {
                    [toLayer setTransformRampFromStartTransform:CGAffineTransformMakeTranslation(+self.composition.naturalSize.width, 0.0) toEndTransform:CGAffineTransformIdentity timeRange:transitionTimeRanges[i]];
                }
            }
            
            transitionInstruction.layerInstructions = [NSArray arrayWithObjects:fromLayer, toLayer, nil];
            
            [instructions addObject:transitionInstruction];
            
        }
    }

    self.videoComposition.frameDuration = CMTimeMake(1,30);
    self.videoComposition.renderScale = 1.0;
    self.videoComposition.renderSize = compositionVideoTracks[0].naturalSize;
    
    self.videoComposition.instructions = [NSArray arrayWithArray:instructions];
//    for (i=0; i<self.videoClips.count;i++)
//    {
//        NSValue *clipTimeRange = self.clipTimeRanges[i];
//        NSLog(@"clip time ranges: %@", clipTimeRange.description);
//        [self.composition.tracks objectAtIndex:i];
//        
//    }
    
    [self exportVideoComposition:self.composition];
    return self.composition;
}



- (void)buildCompositionObjects:(NSArray*)takes
{
    //self.exportQueue = dispatch_queue_create("export queue", DISPATCH_QUEUE_SERIAL);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"videoMergingStartedNotification" object:nil];
    self.composition = nil;
    self.videoComposition = nil;

    [self prepareAssetsFromTakes:takes];
     
    
    
    //self.transitionType = TransitionTypeCrossFade;
  
    
    //AVMutableAudioMix *audioMix = nil;
    //CALayer *animatedTitleLayer = nil;
    
    
    
    // No transition selected; generates the default composition
    
        // No transitions: place clips into one video track and one audio track in composition.
        
        //dispatch_barrier_async(self.exportQueue, ^{
           // [self spliceAssets:takes];
           
            
            ////
            /*
            [self addBlackBackgroundTransitionsWithDuration:CMTimeMakeWithSeconds(3.0,NSEC_PER_SEC) betweenClips:takes];
             */
            
            ////
       // });
        
        //return [self spliceAssets:takes];
    
    
//    dispatch_async(self.exportQueue, ^{
//        
//        [self exportVideoComposition:self.composition];
//    
//    });
    
 
}

- (void)assetsPreparedForComposition:(NSNotification*)notification
{
    self.scaleAssetExportSession = nil;
    if (self.transitionType == TransitionTypeNone && !self.titleSlidesEnabled)
    {
        [self spliceAssets:notification.object];
        
        
    }
    else if (self.transitionType == TransitionTypeNone && self.titleSlidesEnabled)
    {
        [self addBlackBackgroundTransitionsWithDuration:3.0 betweenClips:notification.object];
        
    }
    else if (self.transitionType != TransitionTypeNone && self.titleSlidesEnabled)
    {
        [self addBlackBackgroundTransitionsWithDuration:CMTimeMakeWithSeconds(3,1) betweenClips:notification.object withTransitionDuration:CMTimeMakeWithSeconds(2, 1)];
    }
    else
    {
        // With transitions:
        // Place clips into alternating video & audio tracks in composition, overlapped by transitionDuration.
        // Set up the video composition to cycle between "pass through A", "transition from A to B",
        // "pass through B", "transition from B to A".
        
        //videoComposition = [AVMutableVideoComposition videoComposition];
        [self buildTransitionComposition:notification.object];
    }
    
    //[self.scaleAssetExportSession removeObserver:self forKeyPath:@"status"];

}

// regular composition without trnsitions
-(AVAsset*)spliceAssets: (NSArray*)takes
{
    
    self.composition = [[AVMutableComposition alloc] init];
    //composition.naturalSize = videoSize;
    AVMutableCompositionTrack *compositionTrack_video = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *compositionTrack_audio = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    self.videoComposition = [AVMutableVideoComposition videoComposition];

    CMTime insertionTime = kCMTimeZero;
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionTrack_video];

    //so we can adjust the video size according to the smallest video in the sequence, so we dont crop large portions of the large videos or have black bars around the small videos.

    
    for (int i=0; i<_videoClips.count; i++)
    {
        AVURLAsset *asset = self.videoClips[i];
        NSValue *clipTimeRange = [_clipTimeRanges objectAtIndex:i];
        CMTimeRange timeRangeInAsset;
        
        if (clipTimeRange)
            timeRangeInAsset = [clipTimeRange CMTimeRangeValue];
        else
            timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [asset duration]);
        
        //AVAsset *asset = self.videoClips[i];
        AVAssetTrack *assetTrack_video = [asset tracksWithMediaType:AVMediaTypeVideo][0];
        AVAssetTrack *assetTrack_audio = [asset tracksWithMediaType:AVMediaTypeAudio][0];
        
        [compositionTrack_video insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetTrack_video atTime:insertionTime error:nil];
        
        [compositionTrack_audio insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetTrack_audio atTime:insertionTime error:nil];
        
        
        [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
        
        
        
        // the video currently being analyzed is larger than the last one, then it must be scaled down so that it does not get cropped when in the final composition
        
        
        
        
                //[compositionTrack_video setPreferredTransform:scale];
                // there is a front facing video, which have smaller dimensions than a video taken with the front facing camera. to prevent cropping the videos taken with the back facing camera to make the sizes equal, or adding black bars to all the videos taken with the front facing camera, we will check if the current video has a width greater than 1280? this may not be correct since other i phones may have different resolutions.
                // so if the width of the video is 1920 (width if back facing video was taken) then we will scale the size down to the size of the front facing videos
                // there must be a better solution for this
            
               // [layerInstruction setTransform:transform atTime:timer];
            
          //[layerInstruction setTransform:assetTrack_video.preferredTransform atTime:timer];
       
        
        [layerInstruction setTransform:assetTrack_video.preferredTransform atTime:insertionTime];
        
        
        insertionTime = CMTimeAdd(insertionTime, asset.duration);
        
        //previousVideoSize = currentVideoSize;
        
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, insertionTime);
        
        instruction.layerInstructions = [NSArray arrayWithObjects:layerInstruction, nil];
        self.videoComposition.instructions = [NSArray arrayWithObject:instruction];
        
        self.videoComposition.frameDuration = CMTimeMake(1, 30);

        CGSize videoSize = assetTrack_video.naturalSize;
        NSLog(@"VIDEO SIZE: width=%f, height=%f", videoSize.width, videoSize.height);
        
        self.videoComposition.renderSize = assetTrack_video.naturalSize;
        
        
        self.videoComposition.renderScale = 1.0;
        
        
   

    }
    
//    AVComposition *copyOfComposition = [self.composition copy];
//    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:copyOfComposition];
    
    
    
    
    [self exportVideoComposition:self.composition];
        
        

    
    return self.composition;
    
    
    
}

- (AVAsset*) insertEmptyTimeRangesWithDuration:(float)durationOfEmptyClips betweenClips:(NSArray*)videoClips intoComposition:(AVAsset*)composition
{
    CMTime emptyClipStartTime = kCMTimeZero;
    CMTime emptyClipDuration = CMTimeMakeWithSeconds(durationOfEmptyClips, 600);
    for (int i=0; i<_videoClips.count;i++)
    {
        NSValue *clipTimeRange = [_clipTimeRanges objectAtIndex:i];
        AVURLAsset *asset = _videoClips[i];
        CMTimeRange timeRangeInAsset;
        if (clipTimeRange)
            timeRangeInAsset = [clipTimeRange CMTimeRangeValue];
        else
            timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, asset.duration);
        
        [self.composition insertEmptyTimeRange:CMTimeRangeMake(emptyClipStartTime, emptyClipDuration)];
        
        emptyClipStartTime = CMTimeAdd(emptyClipDuration, timeRangeInAsset.duration);
    }

    return self.composition;
    
}



- (void)addBlackBackgroundTransitionsWithDuration:(float)intervalBetweenClipsInSeconds betweenClips:(NSArray*)takes
{
    CMTime emptyClipDuration = CMTimeMakeWithSeconds(intervalBetweenClipsInSeconds, 600);
   // [self insertEmptyTimeRangesWithDuration:3 betweenClips:takes intoComposition:[self spliceAssets:takes]];
    
    self.composition = [[AVMutableComposition alloc] init];
    
    //composition.naturalSize = videoSize;
    AVMutableCompositionTrack *videoTrackA = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *videoTrackB = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVMutableCompositionTrack *audioTrackA= [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioTrackB= [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    self.videoComposition = nil;
    self.videoComposition = [AVMutableVideoComposition videoComposition];
    NSMutableArray *videoInstructions = [[NSMutableArray alloc] init];

    //CMTimeRange *videoTimeRanges = alloca(sizeof(CMTimeRange) * [_videoClips count]);

    CMTimeRange *videoTimeRanges = alloca(sizeof(CMTimeRange) * 2);
    //CMTimeRange *emptyClipTimeRanges = alloca(sizeof(CMTimeRange) * [_videoClips count]);
    CMTimeRange *emptyClipTimeRanges = alloca(sizeof(CMTimeRange) * 2);
    //CMTimeRange *transitionTimeRanges = alloca(sizeof(CMTimeRange) * 2);
    CMTimeRange *fadeInTransitionTimeRanges = alloca(sizeof(CMTimeRange) * 2);
    //CMTimeRange *fadeOutTransitionTimeRanges = alloca(sizeof(CMTimeRange) *2);
    CMTimeRange *passThroughTimeRanges = alloca(sizeof(CMTimeRange) *2);
    
    
    CMTime insertionTime = kCMTimeZero;
    CMTime transitionDuration = CMTimeMakeWithSeconds(2, 600);
    ///// first try with the firt two assets, extend over all clips if this works.
   // for (int i=0; i<_videoClips.count;i++)
   // {
        // get the asset and its time range: [0, assetsDuration]
        AVURLAsset *asset1 = self.videoClips[0];
        NSValue *clipTimeRange1 = _clipTimeRanges[0];
        CMTimeRange timeRangeInAsset1;
        if (clipTimeRange1)
            timeRangeInAsset1 = [clipTimeRange1 CMTimeRangeValue];
        else
            timeRangeInAsset1 = CMTimeRangeMake(kCMTimeZero, [asset1 duration]);
        
        AVAssetTrack *sourceVideoTrack = [asset1 tracksWithMediaType: AVMediaTypeVideo][0];
        AVAssetTrack *sourceAudioTrack = [asset1 tracksWithMediaType:AVMediaTypeAudio][0];
        
        // prior to the start of the video clip, there will be a blank/empty clip that shows for x seconds (value retreived from method parameter)
        // save this time range in the array
    
        emptyClipTimeRanges[0] = CMTimeRangeMake(insertionTime, emptyClipDuration);
    
        [videoTrackA insertEmptyTimeRange:emptyClipTimeRanges[0]];
        [audioTrackA insertEmptyTimeRange:emptyClipTimeRanges[0]];
        // start time at which the video clip is to be inserted (after the empty clip):
        insertionTime = CMTimeAdd(insertionTime, emptyClipDuration);
        
        // get time range in asset, and add to array of video time ranges
        videoTimeRanges[0] = CMTimeRangeMake(insertionTime, timeRangeInAsset1.duration);
    fadeInTransitionTimeRanges[0] = CMTimeRangeMake(insertionTime, transitionDuration);
    passThroughTimeRanges[0] = CMTimeRangeMake(CMTimeAdd(insertionTime,transitionDuration), CMTimeSubtract(videoTimeRanges[0].duration, transitionDuration));
    
    [videoTrackA insertTimeRange:timeRangeInAsset1 ofTrack:sourceVideoTrack atTime:insertionTime error:nil];
    [audioTrackA insertTimeRange:timeRangeInAsset1 ofTrack:sourceAudioTrack atTime:insertionTime error:nil];
    
    
    
    insertionTime = CMTimeAdd(insertionTime, timeRangeInAsset1.duration);
    
    
    AVURLAsset *asset2 = self.videoClips[1];
    NSValue *clipTimeRange2 = _clipTimeRanges[1];
    CMTimeRange timeRangeInAsset2;
    if (clipTimeRange2)
        timeRangeInAsset2 = [clipTimeRange2 CMTimeRangeValue];
    else
        timeRangeInAsset2 = CMTimeRangeMake(kCMTimeZero, [asset2 duration]);
    
    AVAssetTrack *sourceVideoTrack2 = [asset2 tracksWithMediaType: AVMediaTypeVideo][0];
    AVAssetTrack *sourceAudioTrack2 = [asset2 tracksWithMediaType:AVMediaTypeAudio][0];
    
    // prior to the start of the video clip, there will be a blank/empty clip that shows for x seconds (value retreived from method parameter)
    // save this time range in the array
    
    emptyClipTimeRanges[1] = CMTimeRangeMake(insertionTime, emptyClipDuration);
    
    [videoTrackB insertEmptyTimeRange:emptyClipTimeRanges[1]];
    [audioTrackB insertEmptyTimeRange:emptyClipTimeRanges[1]];
    // start time at which the video clip is to be inserted (after the empty clip):
    insertionTime = CMTimeAdd(insertionTime, emptyClipDuration);
    
    // get time range in asset, and add to array of video time ranges
    videoTimeRanges[1] = CMTimeRangeMake(insertionTime, timeRangeInAsset2.duration
                                         );
    fadeInTransitionTimeRanges[1] = CMTimeRangeMake(insertionTime, transitionDuration);
    passThroughTimeRanges[1] = CMTimeRangeMake(CMTimeRangeGetEnd(fadeInTransitionTimeRanges[1]), CMTimeSubtract(videoTimeRanges[1].duration, transitionDuration));
    
    NSLog(@"EMPTY:");
    CMTimeRangeShow(emptyClipTimeRanges[0]);
    NSLog(@"TRANSITION:");
    CMTimeRangeShow(fadeInTransitionTimeRanges[0]);
    NSLog(@"PASSTHROUGH TIME RANGES:");
    CMTimeRangeShow(passThroughTimeRanges[0]);
    NSLog(@"EMPTY:");
    CMTimeRangeShow(emptyClipTimeRanges[1]);
    NSLog(@"TRANSITION:");
    CMTimeRangeShow(fadeInTransitionTimeRanges[1]);
    NSLog(@"PASSTHROUGH TIME RANGES:");
    CMTimeRangeShow(passThroughTimeRanges[1]);
    
    NSLog(@"VIDEO CLIP TIME RANGES IN COMPOSITION:");
    CMTimeRangeShow(videoTimeRanges[0]);
    CMTimeRangeShow(videoTimeRanges[1]);
    
    NSLog(@"SOURCE TRACK TIME RANGES");
    CMTimeRangeShow(timeRangeInAsset1);
    CMTimeRangeShow(timeRangeInAsset2);
    
 
    
    
    NSError *trackBError = nil;
    if (![videoTrackB insertTimeRange:timeRangeInAsset2 ofTrack:sourceVideoTrack2 atTime:insertionTime error:&trackBError])
    {
        NSLog(@"ERROR: %@", trackBError);
    }
    [audioTrackB insertTimeRange:timeRangeInAsset2 ofTrack:sourceAudioTrack2 atTime:insertionTime error:nil];
    
    
    
    //
   
    // }
    
    
    /**-------------------------------**
     ** BLANK INTRO CLIP INSTRUCTIONS **
     **-------------------------------**/
    //AVMutableVideoCompositionInstruction *blankIntroClipInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    ///////////////////////////////////////////
    /*  _____________________________________
       |     !                               |
      A|EEEEE!AAAAAAAAAAA|EEEEE|0000000000000|
       |-----|xxx********|                   |
       |     !           |-----|xxx**********|
      B|EEEEE!00000000000|EEEEE!BBBBBBBBBBBBB|
       |_____!_______________________________|
       [<===>]
     
    *//////////////////////////////////////////
    // Time range of interest for this composition:
    //blankIntroClipInstruction.timeRange = emptyClipTimeRanges[0];
    
    /* layer instructions */
    
    AVMutableVideoCompositionInstruction *blankIntroClipInstruction1 = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    blankIntroClipInstruction1.timeRange = emptyClipTimeRanges[0];
    
    AVMutableVideoCompositionLayerInstruction *emptyLayer1A = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrackA];
    AVMutableVideoCompositionLayerInstruction *emptyLayer1B = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrackB];
    [emptyLayer1A setOpacity:0.0 atTime:emptyClipTimeRanges[0].start];
    [emptyLayer1B setOpacity:0.0 atTime:emptyClipTimeRanges[0].start];
    
    blankIntroClipInstruction1.layerInstructions = [NSArray arrayWithObjects:emptyLayer1A,emptyLayer1B, nil];
    [videoInstructions addObject:blankIntroClipInstruction1];
    
    /**---------------------------------------**
     ** FADE-IN TRANSITION CLIP INSTRUCTIONS  **
     **---------------------------------------**/
    AVMutableVideoCompositionInstruction *transitionInstructionA = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    ///////////////////////////////////////////
    /*  _____________________________________
       |     !   !                           |
      A|     |AAA!AAAAAAA|                   |
       |-----|xxx!*******|                   |
       |     !   !       |-----|xxx**********|
      B|     !000!       |      BBBBBBBBBBBBB|
       |_____!___!___________________________|
             [<->]
     
     *//////////////////////////////////////////
    // Time range of interest for this composition:
    transitionInstructionA.timeRange = fadeInTransitionTimeRanges[0];
    
    /* layer instruction for track A  = xxx */
    AVMutableVideoCompositionLayerInstruction *aInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrackA];
    // apply opacity ramp for fade in
    [aInstruction setOpacityRampFromStartOpacity:0.0
                                    toEndOpacity:1.0
                                       timeRange:fadeInTransitionTimeRanges[0]];

    
    //[aInstruction setTransformRampFromStartTransform:sourceVideoTrack.preferredTransform toEndTransform:sourceVideoTrack.preferredTransform timeRange:fadeInTransitionTimeRanges[0]];
    
    AVMutableVideoCompositionLayerInstruction *bLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrackB];
    
    [bLayerInstruction setOpacity:0.0 atTime:fadeInTransitionTimeRanges[0].start];
    
    transitionInstructionA.layerInstructions = [NSArray arrayWithObjects:aInstruction, bLayerInstruction, nil];

    [videoInstructions addObject:transitionInstructionA];
    
    // part of trackA without transitions, held constant at opacity 1.0
    // spans the duration of the clip that does not include the transition duration at the start of the clip
    // so the duration = assetDuration - transitionDuration
    AVMutableVideoCompositionInstruction *passThroughA = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    // ***** = PASS THROUGH INSTRUCTIONS
    //    _____________________________________
    //   |        !        !                   |
    //   |      AAAAAAAAAAA|                   |
    //A  |-----|xxx********|                   |
    //   |        !        |-----|xxx**********|
    //B  |        !        !      BBBBBBBBBBBBB|
    //   |________!________!___________________|
    //            [<------>]
    //
    passThroughA.timeRange = passThroughTimeRanges[0];
    /* Pass through layer instructions for track A. */
    AVMutableVideoCompositionLayerInstruction *passThroughLayerA= [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrackA];
    // passThroughLayerB...
    
    [passThroughLayerA setOpacity:1.0 atTime:passThroughA.timeRange.start];
    // set opacity for layer B??
    
    //[passThroughLayerA setTransform:sourceVideoTrack.preferredTransform atTime:passThroughTimeRanges[0].start];
    passThroughA.layerInstructions = @[passThroughLayerA];
    [videoInstructions addObject:passThroughA];

    //   ______________________________________
    //   |                 !     !             |
    //   |     |AAAAAAAAAAA|     !             |
    //A  |-----|xxx********|     !             |
    //   |                 |-----|xxx**********|
    //B  |                 |     |BBBBBBBBBBBBB|
    //   |_________________!_____!_____________|
    //                     [<--->]
    // Blank empty clip 2;
    // the segment separating the end of clip #1 on track A and the start of clip #2 on trackB by a given duration.
    
    AVMutableVideoCompositionInstruction *blankIntroClipInstruction2 = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    blankIntroClipInstruction2.timeRange = emptyClipTimeRanges[1];
    AVMutableVideoCompositionLayerInstruction *emptyLayer2A = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrackA];
    AVMutableVideoCompositionLayerInstruction *emptyLayer2B = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrackB];
    //?
    [emptyLayer2A setOpacity:0.0 atTime:emptyClipTimeRanges[1].start];
    [emptyLayer2B setOpacity:0.0 atTime:emptyClipTimeRanges[1].start];
    blankIntroClipInstruction2.layerInstructions = [NSArray arrayWithObjects:emptyLayer2A,emptyLayer2B,nil];
    [videoInstructions addObject:blankIntroClipInstruction2];
   
    
    AVMutableVideoCompositionInstruction *transitionInstructionB = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    transitionInstructionB.timeRange = fadeInTransitionTimeRanges[1];
    AVMutableVideoCompositionLayerInstruction *bInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrackB];
    [bInstruction setOpacityRampFromStartOpacity:0.0
                                    toEndOpacity:1.0
                                       timeRange:fadeInTransitionTimeRanges[1]];
    //    AVMutableVideoCompositionLayerInstruction *emptyPassThroughA = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrackA];
    //    [bInstruction setTransform:sourceVideoTrack2.preferredTransform
    //                        atTime:fadeInTransitionTimeRanges[1].start];
    //    [emptyPassThroughA setOpacity:0.0
    //                           atTime:fadeInTransitionTimeRanges[1].start];
    //    transitionInstructionB.layerInstructions = [NSArray arrayWithObjects:bInstruction, emptyPassThroughA, nil];
    //    [videoInstructions addObject:transitionInstructionB];
    
    transitionInstructionB.layerInstructions = @[bInstruction];
    [videoInstructions addObject:transitionInstructionB];
    

    
    AVMutableVideoCompositionInstruction *passThroughB = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    passThroughB.timeRange = passThroughTimeRanges[1];
    /* Pass through layer instructions for track A. */
    AVMutableVideoCompositionLayerInstruction *passThroughLayerB= [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrackB];
    
    [passThroughLayerB setOpacity:1.0 atTime:passThroughTimeRanges[1].start];
    //[passThroughLayerB setTransform:sourceVideoTrack2.preferredTransform atTime:passThroughTimeRanges[1].start];
    passThroughB.layerInstructions = @[passThroughLayerB];
    [videoInstructions addObject:passThroughB];
    
    
    //may need to have these methods apply to one asset at a time if i want to enable chosiing different effects for each clip
    // since you added empty time ranges to the tracks themselves, the intro layer instructions may need to be applied to the asset track with that empty time range instead of creating layer instructions that are not intialized to an asset
    
    //[aInstruction setOpacity:1.0 atTime:CMTimeAdd(videoTimeRanges[0].start, transitionDuration)];
    /// layer instructions in a set of video instructions can occur at overlapping time but must be on different tracks?
    // all time ranges for every  instruction must be mutually exclusive and no overlapping and NO GAPS
    // |----|=======|
    // |----|-------|
    //  empty instructions with layer not initalized with any asset track
    //  empty time ranges[i]
    // for no transitions, only need to create one set of instructions
    
    
    /* AVMutableVideoCompositionInstruction *blankIntroClipAInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
     emptyClipInstructions.timeRange = emptyClipTimeRanges[0];
     AVMutableVideoCompositionLayerInstruction *emptyLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstruction];
     emptyClipInstructions.layerInstructions = [NSArray arrayWithObject:emptyLayer];
     [videoInstructions addObject:blankIntroClipAInstruction];
     
     // NO TRANSITIONS
     AVMutableVideoCompositionInstruction *passThroughAInstructions = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
     passThroughInstructions.timeRange = videoTimeRanges[0];
     
     AVMutableVideoCompositionLayerInstruction *layerA = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrackA];
     //// or try using sourceVideoTrack instead?
     [layerA setOpacity:1.0 atTime:videoTimeRanges[0].start];
     [layerA setTransform:sourceVideoTrack.preferredTransform atTime:videoTimeRanges[0].start];
     
     
     /// ?? is this nesessary?
     AVMutableVideoCompositionLayerInstruction *emptylayerB = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrackB];
     [layerB setOpacity:0.0 atTime:videoTimeRanges[0].start];
     
     passThroughInstructions.layerInstructions = [NSArray arrayWithObjects:layerA, emptyLayerB, nil];
     [videoInstructions addObject:passThroughAInstructions];
     
     
     
     AVMutableVideoCompositionInstruction *passThroughBInstructions = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
     passThroughInstructions.timeRange = videoTimeRanges[1];
     
     AVMutableVideoCompositionLayerInstruction *emptylayerA = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrackA];
     //// or try using sourceVideoTrack instead?
     [layerA setOpacity:0.0 atTime:videoTimeRanges[1].start];
     
     
     AVMutableVideoCompositionLayerInstruction *layerB = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrackB];
     [layerB setOpacity:1.0 atTime:videoTimeRanges[0].start];
     [layerA setTransform:sourceVideoTrack2.preferredTransform atTime:videoTimeRanges[1].start];
     passThroughInstructions.layerInstructions = [NSArray arrayWithObjects:emptylayerA, layerB, nil];
     [videoInstructions addObject:passThroughBInstructions];
     
*/
    
    
       //AVMutableVideoCompositionInstruction *transitionInstruction2 = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//    transitionInstruction2.timeRange =
//     AVMutableVideoCompositionLayerInstruction *fadeOutInstruction =[AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrackA];
//    
//     CMTime fadeOutStartTime = CMTimeAdd(videoTimeRanges[0].start, CMTimeSubtract(videoTimeRanges[0].duration, transitionDuration));
//     CMTimeRange fadeOutTimeRange = CMTimeRangeMake(fadeOutStartTime, transitionDuration);
//     [fadeOutInstruction setOpacityRampFromStartOpacity:1.0 toEndOpacity:0.0 timeRange:fadeOutTimeRange];
    
    
    // try creating just an empty track with an instruction spanning the composition duration. the layer instructions can just be initialized without an asset track. then set up each asset in the video track as separated by equally spaced intervals. Black empty time ranges space out the assets in equally spaced out intervals.
    /// try doing this: create instructions for every asset
    
    
    
    /*
    //insertionTime = kCMTimeZero;
    for (int i=0; i<_videoClips.count; i++)
    {
        AVURLAsset *asset = self.videoClips[i];
        NSValue *clipTimeRange = [_clipTimeRanges objectAtIndex:i];
        CMTimeRange timeRangeInAsset;
        
        if (clipTimeRange)
            timeRangeInAsset = [clipTimeRange CMTimeRangeValue];
        else
            timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [asset duration]);
        
        AVAssetTrack *assetTrack_video = [asset tracksWithMediaType:AVMediaTypeVideo][0];
        AVAssetTrack *assetTrack_audio = [asset tracksWithMediaType:AVMediaTypeAudio][0];
        
        [compositionTrack_video insertTimeRange:timeRangeInAsset ofTrack:assetTrack_video atTime:insertionTime error:nil];
        
        [compositionTrack_audio insertTimeRange:timeRangeInAsset ofTrack:assetTrack_audio atTime:insertionTime error:nil];
        
        insertionTime = CMTimeAdd(insertionTime, timeRangeInAsset.duration);
     
    
        // fade in time ranges[i] = CMTimeRangeMake(insertionTime (or videoTimeRanges[i].start), transitionDuration)
        // pass through time ranges[i].start = CMTimeAdd(insertionTime, transitionDuration)
        // CMTimeMake *transitionDurationx2 = CMTimeAdd(transitionDuration, transitionDuration)
        // passThroughTimeRanges[i].duration = CMTimeSubtract(asset.duration, transitionDurationx2)
        
        // insertionTime = insertionTime + asset.duration
        
        // fade out timeRanges[i].start = CMTimeSubtract(insertionTime, transitionDuration)
        // fade out timeRanges[i].duration = transitionDuration
    } */
    

//    CGAffineTransform preferredTransform;
//    CGSize naturalSize;
//    
//    for (int i=0; i<_videoClips.count; i++)
//    {
//        AVURLAsset *asset = self.videoClips[i];
//        NSValue *clipTimeRange = [_clipTimeRanges objectAtIndex:i];
//        CMTimeRange timeRangeInAsset;
//        
//        if (clipTimeRange)
//            timeRangeInAsset = [clipTimeRange CMTimeRangeValue];
//        else
//            timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [asset duration]);
//        
        
//        AVAssetTrack *assetTrack_video = [asset tracksWithMediaType:AVMediaTypeVideo][0];
//        AVAssetTrack *assetTrack_audio = [asset tracksWithMediaType:AVMediaTypeAudio][0];
        
        
        
//        [compositionTrack_video insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeAdd(asset.duration, duration)) ofTrack:assetTrack_video atTime:insertionTime error:nil];
//        
//        [compositionTrack_audio insertTimeRange:CMTimeRangeMake(kCMTimeZero,CMTimeAdd(asset.duration, duration)) ofTrack:assetTrack_audio atTime:insertionTime error:nil];
       
//        AVURLAsset *asset = self.videoClips[i];
//        AVAssetTrack *assetTrack_video = [asset tracksWithMediaType:AVMediaTypeVideo][0];
//        preferredTransform = assetTrack_video.preferredTransform;
//        naturalSize = assetTrack_video.naturalSize;
        
        //[layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
        
        
        
        // the video currently being analyzed is larger than the last one, then it must be scaled down so that it does not get cropped when in the final composition
        
        
        
        
        //[compositionTrack_video setPreferredTransform:scale];
        // there is a front facing video, which have smaller dimensions than a video taken with the front facing camera. to prevent cropping the videos taken with the back facing camera to make the sizes equal, or adding black bars to all the videos taken with the front facing camera, we will check if the current video has a width greater than 1280? this may not be correct since other i phones may have different resolutions.
        // so if the width of the video is 1920 (width if back facing video was taken) then we will scale the size down to the size of the front facing videos
        // there must be a better solution for this
        
        // [layerInstruction setTransform:transform atTime:timer];
        
        //[layerInstruction setTransform:assetTrack_video.preferredTransform atTime:timer];
//        AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//        instruction.timeRange = CMTimeRangeMake(emptyClipTimeRanges[i].start, CMTimeAdd(videoTimeRanges[i].start, videoTimeRanges[i].duration));
       //          TRACK A
       //       |           |
       //       |--|<======>|
       //       |           |
                        ///    TRACK B
                        /// |           |
                        /// |--|<======>|
                        /// |           |
        
       /////////////////////////////////////////////////////////////
//start//0|  td0|           |     |td1=td0+ad0 |     |             | \\
       // |<   >|<=========>|<   >|<==========>|<   >|<----------->| \\
//dur  // | td  |      ad0  | td  |   ad1      | td  |     ad2     | \\
       /////////////////////////////////////////////////////////////
       // <----------------->
       // (0)+td+ad0             = it0
       // (td+ad0)+td+ad1        = it0+td+ad1 = it1
       // (td+ad0+td+ad1)+td+ad2 =     it1         +td+ad2 = it2
        
        
        
//        AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionTrack_video];
//        
//        [layerInstruction setTransform:preferredTransform atTime:videoTimeRanges[i].start];
        // if not try at kCMTimeZero
        
        
//        insertionTime = CMTimeAdd(insertionTime, asset.duration);
//        insertionTime = CMTimeAdd(insertionTime, duration);
        
        
        //instruction.timeRange = CMTimeRangeMake(kCMTimeZero, insertionTime);
        
//        instruction.timeRange = videoTimeRanges[i];
//        
//        instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
//        [videoInstructions addObject:instruction];
//        self.videoComposition.instructions = [NSArray arrayWithObject:instruction];
//        
//        self.videoComposition.frameDuration = CMTimeMake(1, 30);
//        
//        self.videoComposition.renderSize = naturalSize;
//        
//        self.videoComposition.renderScale = 1.0;
        
        
        /// after try adding empty time ranges after creating video composition
        
    //}
    
    // tell the player about our effects
    
    
    
    

    self.videoComposition.instructions = [NSArray arrayWithArray:videoInstructions];
    
    self.videoComposition.frameDuration = CMTimeMake(1, 30);
    
    self.videoComposition.renderSize = sourceVideoTrack.naturalSize;
    
    self.videoComposition.renderScale = 1.0;

    [self exportVideoComposition:self.composition];
    //return self.composition;
    
    
}

/// this is for applying empty black clips between each video in the composition. add text overlay to introduce the next clip or for scene intro. Same as previous method except it adds a transition effect between the black clip and the next/previous clips in the composition.
/*  duration - length of time the black clip shows (this includes the transition times)
    transitionDuration - time taken at the end of previoous clip for duration to occur and for trnsition to occur for the next corresponding clip
*/

- (void)addBlackBackgroundTransitionsWithDuration:(CMTime)duration betweenClips:(NSArray*)takes withTransitionDuration:(CMTime)transitionDuration
{
    

    // check the times of the duration and make sure it is 1 second longer than 2x the transition duration so it shows by itself for at least one second before the next clip starts to fade in

    //NSMutableArray *fadeInTransitionTimeRanges = [NSMutableArray array];
    //NSMutableArray *fadeOuttransitionTimeRanges = [NSMutableArray array];

    NSInteger i;
    CMTime insertionTime = kCMTimeZero;

 
    self.composition = [[AVMutableComposition alloc] init];
    //composition.naturalSize = videoSize;
    AVMutableCompositionTrack *compositionTrack_video = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *compositionTrack_audio = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    self.videoComposition = [AVMutableVideoComposition videoComposition];
    
    
    AVMutableVideoCompositionInstruction *transitionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    AVMutableVideoCompositionLayerInstruction *fadeInTransitionLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionTrack_video];
    
    NSMutableArray *videoInstructions = [NSMutableArray array];
    //so we can adjust the video size according to the smallest video in the sequence, so we dont crop large portions of the large videos or have black bars around the small videos.
    
    CGSize videoSize;
    for (int i=0; i<_videoClips.count; i++)
    {
        
        // fade-in transition time range = [insertionTime, transitionDuration]
        
        // fade-out                      = [insertionTime,
        AVURLAsset *asset = self.videoClips[i];
        NSValue *clipTimeRange = [_clipTimeRanges objectAtIndex:i];
        CMTimeRange timeRangeInAsset;
        
        if (clipTimeRange)
            timeRangeInAsset = [clipTimeRange CMTimeRangeValue];
        else
            timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [asset duration]);
        
        //AVAsset *asset = self.videoClips[i];
        AVAssetTrack *assetTrack_video = [asset tracksWithMediaType:AVMediaTypeVideo][0];
        videoSize = assetTrack_video.naturalSize;
        AVAssetTrack *assetTrack_audio = [asset tracksWithMediaType:AVMediaTypeAudio][0];
        
        NSError *videoTrackError = nil;
        NSError *audioTrackError = nil;
        
        [compositionTrack_video insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeAdd(asset.duration, duration)) ofTrack:assetTrack_video atTime:insertionTime error:&videoTrackError];
        if (videoTrackError)
        {
            NSLog(@"videoTrackError: %@", videoTrackError.description);
        }
        
        [compositionTrack_audio insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeAdd(asset.duration, duration)) ofTrack:assetTrack_audio atTime:insertionTime error:&audioTrackError];
        if (audioTrackError)
        {
            NSLog(@"videoTrackError: %@", audioTrackError.description);
        }
        
        NSLog(@"TIME RANGE IN ASSET:%@, INSERTION TIME: %@", CMTimeRangeCopyDescription(kCFAllocatorDefault, CMTimeRangeMake(kCMTimeZero, CMTimeAdd(asset.duration, duration))), CMTimeCopyDescription(kCFAllocatorDefault, insertionTime));
        
        
        

        transitionInstruction.timeRange = CMTimeRangeMake(insertionTime, transitionDuration);
        //[layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
        

        [fadeInTransitionLayer setOpacityRampFromStartOpacity:0.0 toEndOpacity:1.0f timeRange:CMTimeRangeMake(insertionTime, transitionDuration)];
        
        // add layer instruction to video composition instructions
   
        //[layerInstruction setTransform:assetTrack_video.preferredTransform atTime:insertionTime];
        
        
        insertionTime = CMTimeAdd(insertionTime, asset.duration);
        insertionTime = CMTimeAdd(insertionTime, duration);
        //previousVideoSize = currentVideoSize;
        
        //instruction.timeRange = CMTimeRangeMake(insertionTime, transitionDuration);
        
        transitionInstruction.layerInstructions = @[fadeInTransitionLayer];

        [videoInstructions addObject:transitionInstruction];
        
    }
    

    self.videoComposition.instructions = [NSArray arrayWithArray:videoInstructions];
    
    self.videoComposition.frameDuration = CMTimeMake(1, 30);
    
    self.videoComposition.renderSize = videoSize;
    
    self.videoComposition.renderScale = 1.0;
    
    
    [self exportVideoComposition:self.composition];
    //return self.composition;
    
    
}


// existing asset -> audio+video asset tracks -> add to  MutableComposition
// put in some controller class
- (void) exportVideoComposition:(AVAsset*)composition
{
    // 5 - Create exporter
    NSString *preset = AVAssetExportPreset1920x1080;
    if (self.frontFacingVideoInTakes)
    {
        preset = AVAssetExportPreset1280x720;
    }
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition presetName:preset];
    
    exporter.outputURL = [self createOutputURLWithFilename:@"videoComposition"];
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = self.videoComposition;
    //TODO: exporter.audioComposition = an instance of MutableAudioMix
    
    [exporter exportAsynchronouslyWithCompletionHandler:
     ^{
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            [self exportDidFinish:exporter];
                            
                            
                            
                        });
     }];
}

- (void) addURLToMergedVideosArray:(NSURL*)url
{
    
    if (!self.compositions)
    {
        self.compositions = [NSMutableArray array];
    }
    [self.compositions addObject:url];
    
}

- (NSURL*) createOutputURLWithFilename:(NSString*)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%d.mov",filename, arc4random() % 1000]];
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    
    
    return url;
}


-(void)exportDidFinish:(AVAssetExportSession*)session
{
    NSError *error = nil;
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
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"videoMergingCompletedNotification" object:nil];
                                    if (error)
                                    {
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                        [alert show];
                                    }
                                    else
                                    {
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                        [self addURLToMergedVideosArray:outputURL];
                                        [self.videoLibrary addURLToEditedVideos:outputURL];
                                        [alert show];
                                        
                                        
                                        
                                    }
                                    
                                    
                                });
             }];
        }
    }
    else if (session.status == AVAssetExportSessionStatusFailed)
    {
        NSLog(@"EPIC FAIL");
        if (session.error)
        {
            NSLog(@"%@,%@", session.error,session.error.userInfo);
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:session.outputURL.path])
        {
            if (![[NSFileManager defaultManager] removeItemAtURL:session.outputURL error:nil])
            {
                NSLog(@"error with removing item at outputURL");
            }
        }
    }
    else if (session.status == AVAssetExportSessionStatusExporting)
    {
        NSLog(@"exporting");
    }
    else if (session.status == AVAssetExportSessionStatusWaiting)
    {
        NSLog(@"waiting....");
    }
    else if (session.status == AVAssetExportSessionStatusUnknown)
    {
        NSLog(@"??????");
    }
}

// create text overlay.
- (CALayer *)buildAnimatedTitleLayerForSize:(CGSize)videoSize withDuration:(float)seconds
{
    // Create a layer for the overall title animation.
    CALayer *animatedTitleLayer = [CALayer layer];
    
    // Create a layer for the text of the title.
    CATextLayer *titleLayer = [CATextLayer layer];
    //titleLayer.string = self.titleText;
    titleLayer.string = @"TEXT OVERLAY TITLE";
    titleLayer.font = (__bridge CFTypeRef)(@"Helvetica");
    titleLayer.fontSize = videoSize.height / 6;
    titleLayer.foregroundColor = [UIColor whiteColor].CGColor;
    //?? titleLayer.shadowOpacity = 0.5;
    titleLayer.alignmentMode = kCAAlignmentCenter;
    titleLayer.bounds = CGRectMake(0, 0, videoSize.width, videoSize.height / 6);
    
    // Add it to the overall layer.
    [animatedTitleLayer addSublayer:titleLayer];
    
//    // Create a layer that contains a ring of stars.
//    CALayer *ringOfStarsLayer = [CALayer layer];
//    
//    NSInteger starCount = 9, s;
//    CGFloat starRadius = videoSize.height / 10;
//    CGFloat ringRadius = videoSize.height * 0.8 / 2;
//    CGImageRef starImage = createStarImage(starRadius);
//    for (s = 0; s < starCount; s++) {
//        CALayer *starLayer = [CALayer layer];
//        CGFloat angle = s * 2 * M_PI / starCount;
//        starLayer.bounds = CGRectMake(0, 0, 2 * starRadius, 2 * starRadius);
//        starLayer.position = CGPointMake(ringRadius * cos(angle), ringRadius * sin(angle));
//        starLayer.contents = (id)starImage;
//        [ringOfStarsLayer addSublayer:starLayer];
//    }
//    CGImageRelease(starImage);
    
    // Rotate the ring of stars.
//    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
//    rotationAnimation.repeatCount = 1e100; // forever
//    rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0];
//    rotationAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
//    rotationAnimation.duration = 10.0; // repeat every 10 seconds
//    rotationAnimation.additive = YES;
//    rotationAnimation.removedOnCompletion = NO;
//    rotationAnimation.beginTime = 1e-100; // CoreAnimation automatically replaces zero beginTime with CACurrentMediaTime().  The constant AVCoreAnimationBeginTimeAtZero is also available.
//    [ringOfStarsLayer addAnimation:rotationAnimation forKey:nil];
//    
    // Add the ring of stars to the overall layer.
    animatedTitleLayer.position = CGPointMake(videoSize.width / 2.0, videoSize.height / 2.0);
    //[animatedTitleLayer addSublayer:ringOfStarsLayer];
    
    // Animate the opacity of the overall layer so that it fades out from 3 sec to 4 sec.
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    fadeAnimation.toValue = [NSNumber numberWithFloat:0.0];
    fadeAnimation.additive = NO;
    fadeAnimation.removedOnCompletion = NO;
    fadeAnimation.beginTime = 10.0;
    fadeAnimation.duration = seconds;
    fadeAnimation.fillMode = kCAFillModeBoth;
    [animatedTitleLayer addAnimation:fadeAnimation forKey:nil];
    
    return animatedTitleLayer;
}


    /*
    for (AVAsset *asset in self.videoClips)
    {
        AVAssetTrack *assetTrack_video = [asset tracksWithMediaType:AVMediaTypeVideo][0];
        AVAssetTrack *assetTrack_audio = [asset tracksWithMediaType:AVMediaTypeAudio][0];
        
        [compositionTrack_video insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetTrack_video atTime:timer error:nil];
        
        [compositionTrack_audio insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetTrack_audio atTime:timer error:nil];
        
        
        [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
        
        [layerInstruction setTransform:assetTrack_video.preferredTransform atTime:timer];
        
        timer = CMTimeAdd(timer, asset.duration);
        
        //previousVideoSize = currentVideoSize;
        
        //i++;
        
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, timer);
        
        instruction.layerInstructions = [NSArray arrayWithObjects:layerInstruction, nil];
        self.videoComposition.instructions = [NSArray arrayWithObject:instruction];
        
        //self.videoComposition.renderScale
        self.videoComposition.frameDuration = CMTimeMake(1, 30);
        
        if (self.isFrontFacingVideoInTakes)
        {
            self.videoComposition.renderSize = CGSizeMake(1280,720);
        }
        else
        {
            self.videoComposition.renderSize = compositionTrack_video.naturalSize;
        }
        
        
        NSLog(@"COMPOSITION TRACK VIDEO %i NATURAL SIZE: width = %f height = %f", i,compositionTrack_video.naturalSize.width, compositionTrack_video.naturalSize.height);
    }
    */
    /*
    for (Take* take in takes)
    {
        AVAsset *asset = [AVAsset assetWithURL:[take getFileURL]];
        
        //AVAsset *rotatedAsset = (AVAsset*)[self performWithAsset:[AVAsset assetWithURL:[take getFileURL]]];
        NSLog(@"video position/ orientation %ld", (long)take.videoOrientationAndPosition);
        
        //NSLog(@"[asset tracksWithMediaType:AVMediaTypeVideo].count: %lu", (unsigned long)[asset tracksWithMediaType:AVMediaTypeVideo].count) ;
        
        AVAssetTrack *assetTrack_video = [asset tracksWithMediaType:AVMediaTypeVideo][0];
        AVAssetTrack *assetTrack_audio = [asset tracksWithMediaType:AVMediaTypeAudio][0];
        
        [compositionTrack_video insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetTrack_video atTime:timer error:nil];
        
        [compositionTrack_audio insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetTrack_audio atTime:timer error:nil];
        

        [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
        
        currentVideoSize = assetTrack_video.naturalSize;
        if (previousVideoSize.width == 0 && previousVideoSize.height == 0)
        {
            
        }
        CGFloat renderWidth, renderHeight;
        switch (take.videoOrientationAndPosition)
        {
            case LandscapeLeft_Back:
                NSLog(@" # %i LANDSCAPE LEFT BACK DO NOT ROTATE",i);
                [layerInstruction setTransform:assetTrack_video.preferredTransform atTime:timer];
                // all videos in composition so far are front facing
                if (!isFrontFacingVideoInAssets)
                {
                    renderWidth = compositionTrack_video.naturalSize.width;
                    renderHeight = compositionTrack_video.naturalSize.height;
                    
                }
                else{
                    // scale this current composition video track down to the size of the smallest composition track in the composition
                }
                break;
                
            case LandscapeLeft_Front:
                //LRF
                NSLog(@"VIDEO # %i LANDSCAPE LEFT FRONT", i);
                // if isFrontFacingVideoInAssets = NO then this is the first asset in the compostion that is front facing, so we must scale all previous videos in the composition down to a size that will fit this one. otherwise there will be black bars on the sides of this video.
                
                if (!isFrontFacingVideoInAssets)
                {
                    
                }
                renderWidth = compositionTrack_video.naturalSize.width;
                renderHeight = compositionTrack_video.naturalSize.height;
                
                NSLog(@"%f, %f, %f %f", compositionTrack_video.preferredTransform.a, compositionTrack_video.preferredTransform.b, compositionTrack_video.preferredTransform.c,compositionTrack_video.preferredTransform.d);
                
                [layerInstruction setTransform:assetTrack_video.preferredTransform atTime:timer];
                isFrontFacingVideoInAssets = YES;

                break;
                
            case LandscapeRight_Back:
                //[assets addObject:asset];
                
                NSLog(@" # %i LANDSCAPE RIGHT BACK ROTATE:",i);

                //[layerInstruction setTransform:CGAffineTransformMake(-1,0,0,-1,1280,720) atTime:timer];
                [layerInstruction setTransform:assetTrack_video.preferredTransform atTime:timer];
                // if we havent seen a video that uses front fcaing camera, the render widtths and heights can be
                if (!isFrontFacingVideoInAssets)
                {
                    renderWidth = compositionTrack_video.naturalSize.width;
                    renderHeight = compositionTrack_video.naturalSize.height;
                }
                /// try compositionTrack_video setPreferredTransform:A]
                /// try setting the layer instructions in here instead of outside.
                break;
                
            case LandscapeRight_Front:
                NSLog(@" # %i LANDSCAPE RIGHT FRONT WILL ROTATE",i);
                isFrontFacingVideoInAssets = YES;
                // front facing video is in list of takes, overwrite previously set widths,heights for the other videos.
                renderWidth = compositionTrack_video.naturalSize.width;
                renderHeight = compositionTrack_video.naturalSize.height;
                //[layerInstruction setTransform:CGAffineTransformMake(-1,0,0,-1,1280,720) atTime:timer];
                [layerInstruction setTransform:assetTrack_video.preferredTransform atTime:timer];
               
                break;
                
            default:
                [layerInstruction setTransform:CGAffineTransformIdentity atTime:kCMTimeZero];
        }
        timer = CMTimeAdd(timer, asset.duration);
    
        previousVideoSize = currentVideoSize;
    
        i++;

        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, timer);
        
        instruction.layerInstructions = [NSArray arrayWithObjects:layerInstruction, nil];
        // Extract the existing layer instruction on the videoComposition
//        instruction = (self.videoComposition.instructions)[0];
//        layerInstruction = (instruction.layerInstructions)[0];
//        
//        // Check if a transform already exists on this layer instruction, this is done to add the current transform on top of previous edits
//        
//        CGAffineTransform existingTransform;
//        if (![layerInstruction getTransformRampForTime:[self.composition duration] startTransform:&existingTransform endTransform:NULL timeRange:NULL])
//        {
//                    [layerInstruction setTransform:t2 atTime:kCMTimeZero];
            //        } else {
            // Note: the point of origin for rotation is the upper left corner of the composition, t3 is to compensate for origin
            //  CGAffineTransform t3 = CGAffineTransformMakeTranslation(-1*assetVideoTrack.naturalSize./2, 0.0);
            // CGAffineTransform newTransform = CGAffineTransformConcat(t2, t3);
            //CGAffineTransform newTransform = CGAffineTransformConcat(existingTransform, CGAffineTransformConcat(t2, t3));
            // [layerInstruction setTransform:newTransform atTime:kCMTimeZero];
            
        self.videoComposition.instructions = [NSArray arrayWithObject:instruction];
        
        //self.videoComposition.renderScale
        self.videoComposition.frameDuration = CMTimeMake(1, 30);
        
        self.videoComposition.renderSize = compositionTrack_video.naturalSize;
        
        NSLog(@"COMPOSITION TRACK VIDEO %i NATURAL SIZE: width = %f height = %f", i,compositionTrack_video.naturalSize.width, compositionTrack_video.naturalSize.height);
        //NSLog(@)
    }
    */
    


    //self.videoComposition = [AVMutableVideoComposition videoComposition];
//    self.videoComposition.renderScale = 1.0;
//    self.videoComposition.frameDuration = CMTimeMake(1, 30);
//    
//    self.videoComposition.renderSize = compositionTrack_video.naturalSize;
//    

//    // adding the assets
//    for (AVAsset* asset in assets) {
        //add video from asset to track
        
       
    
//        if (layerInstruction == nil)
//        {
//            layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionTrack_video];
//        }
//        else{
//            AVMutableVideoCompositionLayerInstruction *tempLayerInstruction = layerInstruction;
//        }
        
//        layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionTrack_video];
        //AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        
        
        
        
        
//        [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
//        CGAffineTransform mixedTransform = CGAffineTransformConcat(rotation, translation);
//        
//        [layerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
//        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, timer);
//        instruction.layerInstructions = [NSArray arrayWithObjects:layerInstruction, nil];
        
//        for (int i=0;i<[asset tracksWithMediaType:AVMediaTypeVideo].count;i++)
//        {
//            AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:i];
//            AVAssetTrack *previousVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:i-1];
//            // check if any of video tracks have different sizes, so we can scale each track down to the same size
//            // this is to prevent larger videos from being cropped or smaller ones from having black bars along the edges
//            
//            
//            if ((videoTrack.naturalSize.height < previousVideoTrack.naturalSize.height) && (videoTrack.naturalSize.width < previousVideoTrack.naturalSize.width))
//            {
//                
//                
//            }
//        }
        
        //
//        AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//        
//        // set the time range to span the duration of the current video track.
//        mainInstruction.timeRange = CMTimeRangeMake(timer, CMTimeAdd(timer, assetTrack_video.timeRange.duration));
//        
//        AVMutableVideoCompositionLayerInstruction *firstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionTrack_video];
//        
//        [firstlayerInstruction setOpacity:1.0 atTime:kCMTimeZero];
//        
//        mainInstruction.layerInstructions = [NSArray arrayWithObjects:firstlayerInstruction, nil];
   // compositionTrack_video.preferredTransform = CGAffineTransformMakeRotation(<#CGFloat angle#>)
        // (compositionTrack_video.naturalSize
  
//        self.videoComposition = [AVMutableVideoComposition videoComposition];
        //
        
        //self.videoComposition.instructions = [NSArray arrayWithObject:instruction];
        
//        self.videoComposition.frameDuration = CMTimeMake(1, 30);
//        
//        self.videoComposition.renderSize = compositionTrack_video.naturalSize;
//        
//        self.videoComposition.renderScale = 1.0;
//        
        
        //NSLog(@"timer scale, value: %d %lld", timer.timescale, timer.value);
        //expecting positive values
//        NSLog(@"mixComposition properties: %@", self.composition.debugDescription);
//        
//        self.videoComposition.instructions = [NSArray arrayWithObject:instruction];
        
   // }
//  AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionTrack_video];
//    
//    
//    CGAffineTransform mixedTransform = CGAffineTransformConcat(rotation, translateToCenter);
//    [firstTrackInstruction setTransform:mixedTransform atTime:kCMTimeZero];
    
    
    //[layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
    
    //[layerInstruction setTransform:compositionTrack_video.preferredTransform atTime:kCMTimeZero];
   // AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    //instruction.timeRange = CMTimeRangeMake(kCMTimeZero, timer);
    

    //instruction.layerInstructions = [NSArray arrayWithObjects:layerInstruction, nil];

//    self.videoComposition = [AVMutableVideoComposition videoComposition];
////    
//    
//    //self.videoComposition.instructions = [NSArray arrayWithObject:instruction];
//    
//    self.videoComposition.frameDuration = CMTimeMake(1, 30);
//    
//    //self.videoComposition.renderSize = compositionTrack_video.naturalSize;
//    
//    self.videoComposition.renderScale = 1.0;
//   
//    
//    //NSLog(@"timer scale, value: %d %lld", timer.timescale, timer.value);
//    //expecting positive values
//    NSLog(@"mixComposition properties: %@", self.composition.debugDescription);
//    
//    self.videoComposition.instructions = [NSArray arrayWithObject:instruction];



   

/*
 - (AVAsset*)performWithAsset:(AVAsset*)asset
{
    AVMutableVideoCompositionInstruction *instruction = nil;
    AVMutableVideoCompositionLayerInstruction *layerInstruction = nil;
    CGAffineTransform t1;
    CGAffineTransform t2;
    
    AVAssetTrack *assetVideoTrack = nil;
    AVAssetTrack *assetAudioTrack = nil;
    // Check if the asset contains video and audio tracks
    if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        assetVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
        assetAudioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    
    CMTime insertionPoint = kCMTimeZero;
    NSError *error = nil;
    
    
    // Step 1
    // Create a composition with the given asset and insert audio and video tracks into it from the asset

        
        // Check whether a composition has already been created, i.e, some other tool has already been applied
        // Create a new composition
        AVMutableComposition *composition = [AVMutableComposition composition];
        
        // Insert the video and audio tracks from AVAsset
        if (assetVideoTrack != nil) {
            AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:assetVideoTrack atTime:insertionPoint error:&error];
        }
        if (assetAudioTrack != nil) {
            AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:assetAudioTrack atTime:insertionPoint error:&error];
        }
        
    
    
    
    // Step 2
    // Translate the composition to compensate the movement caused by rotation (since rotation would cause it to move out of frame)
    t1 = CGAffineTransformMakeTranslation(assetVideoTrack.naturalSize.width,assetVideoTrack.naturalSize.height);
    // Rotate transformation
    //t2 = CGAffineTransformMakeRotation(degreesToRadians(180.0));
    
    t2 = CGAffineTransformRotate(t1,degreesToRadians(180.0));
    // Step 3
    // Set the appropriate render sizes and rotational transforms
    ///if (!self.videoComposition) {
        
        // Create a new video composition
        self.videoComposition = [AVMutableVideoComposition videoComposition];
    NSLog(@"natural size width: %f, height: %f",assetVideoTrack.naturalSize.width,assetVideoTrack.naturalSize.height);
    
        self.videoComposition.renderSize = CGSizeMake(assetVideoTrack.naturalSize.width,assetVideoTrack.naturalSize.height);
    NSLog(@"1  render size width: %f, height:%f",self.videoComposition.renderSize.width,self.videoComposition.renderSize.height);
        self.videoComposition.frameDuration = CMTimeMake(1, 30);
        
        // The rotate transform is set on a layer instruction
        instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [composition duration]);
        layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:(composition.tracks)[0]];
        [layerInstruction setTransform:t2 atTime:kCMTimeZero];
        NSLog(@"2   render size width: %f, height:%f",self.videoComposition.renderSize.width,self.videoComposition.renderSize.height);
//    } else {
//        
//        self.videoComposition.renderSize = CGSizeMake(self.videoComposition.renderSize.height, self.videoComposition.renderSize.width);
//        
        // Extract the existing layer instruction on the videoComposition
        //instruction = (self.videoComposition.instructions)[0];
        //layerInstruction = (instruction.layerInstructions)[0];
        
        // Check if a transform already exists on this layer instruction, this is done to add the current transform on top of previous edits
        //CGAffineTransform existingTransform;
        
//        if (![layerInstruction getTransformRampForTime:[composition duration] startTransform:&existingTransform endTransform:NULL timeRange:NULL]) {
//            [layerInstruction setTransform:t2 atTime:kCMTimeZero];
//        } else {
            // Note: the point of origin for rotation is the upper left corner of the composition, t3 is to compensate for origin
          //  CGAffineTransform t3 = CGAffineTransformMakeTranslation(-1*assetVideoTrack.naturalSize./2, 0.0);
           // CGAffineTransform newTransform = CGAffineTransformConcat(t2, t3);
    //CGAffineTransform newTransform = CGAffineTransformConcat(existingTransform, CGAffineTransformConcat(t2, t3));
           // [layerInstruction setTransform:newTransform atTime:kCMTimeZero];
     //   }
//        
    //}
    
    
    // Step 4
    // Add the transform instructions to the video composition
    instruction.layerInstructions = @[layerInstruction];
    self.videoComposition.instructions = @[instruction];
    
    
    // Step 5
    // Notify AVSEViewController about rotation operation completion
    [[NSNotificationCenter defaultCenter] postNotificationName:@"completedVideoRotation" object:self];
    return composition;
}
*/
         




@end
