//
//  VideoMerger.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-03.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "VideoMerger.h"
#import "PlaybackViewController.h"
#import "VBTitleItem.h"


#define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )
@interface VideoMerger ()

@property (nonatomic, getter = isFrontFacingVideoInTakes) BOOL frontFacingVideoInTakes;
@property (nonatomic, strong) NSMutableArray *tempClips;
//@property (nonatomic, strong) dispatch_queue_t exportQueue;

@property (nonatomic, strong) AVAssetExportSession *scaleAssetExportSession;
@property (nonatomic) AVAssetExportSessionStatus scaleAssetExportStatus;
@property (nonatomic) NSInteger clipsToAdd;
@property (nonatomic, strong) NSMutableArray *sceneTitlesForTakes;




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

    self.tempClips = [NSMutableArray arrayWithCapacity:takes.count];
    self.frontFacingVideoInTakes = [self checkForFrontFacingVideos:takes];
    
    self.sceneTitlesForTakes = nil;

    if (self.titleSlidesEnabled)
    {
        self.sceneTitlesForTakes = [NSMutableArray array];
    }
    
    for (int i=0; i<takes.count; i++)
    {
        
        Take *take = takes[i];
        
        if (self.titleSlidesEnabled)
        {
            [self.sceneTitlesForTakes addObject:take.sceneTitle];
        }
        
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
            NSString *pathComponent = [NSString stringWithFormat:@"take-1280x720-%i", arc4random()%1000];
            
            NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[pathComponent stringByAppendingPathExtension:@"mov"]];
            NSURL *scaledAssetURL = [NSURL fileURLWithPath:outputFilePath];
            
            //            dispatch_async(self.exportQueue, ^{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [self exportAssetToScaleDown:urlAsset toURL:scaledAssetURL indexInArray:i];
            });
            
        }
        else
        {
            [self.tempClips addObject:urlAsset];
        }
    }
    
    if (!self.frontFacingVideoInTakes)
    {
        self.videoClips = [NSArray arrayWithArray:self.tempClips];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"assetsPreparedForComposition" object:self.videoClips];
    }
    
}


- (BOOL) checkForFrontFacingVideos:(NSArray*)takes
{
    self.clipsToAdd = takes.count;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsPreparedForComposition:) name:@"assetsPreparedForComposition" object:nil];
    
    for (Take *take in takes)
    {
        switch (take.videoOrientationAndPosition)
        {
            case LandscapeLeft_Back: break;
            case LandscapeLeft_Front:
                // if isFrontFacingVideoInAssets = NO then this is the first asset in the compostion that is front facing, so we must scale all previous videos in the composition down to a size that will fit this one. otherwise there will be black bars on the sides of this video.
                self.frontFacingVideoInTakes = YES;
                return YES;
            case LandscapeRight_Back: break;
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

- (void)buildCompositionObjects:(NSArray*)takes
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"videoMergingStartedNotification" object:nil];
    self.composition = nil;
    self.videoComposition = nil;
    
    [self prepareAssetsFromTakes:takes];

}

// for deciding what editing options to apply to the composition
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


//- (void)observeValueForKeyPath:(NSString*) path
//                      ofObject:(id)object
//                        change:(NSDictionary*)change
//                       context:(void*)context
//{
//    self.scaleAssetExportStatus = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
//    if (self.scaleAssetExportStatus == AVAssetExportSessionStatusCompleted)
//    {
//        
//    }
//    
//    
//}



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

- (AVAsset*)buildTransitionComposition:(NSArray*)takes
{
        
    self.transitionDuration = CMTimeMakeWithSeconds(1, 600); // default transition time=1second
    
    self.composition = [AVMutableComposition composition];
    self.videoComposition = [AVMutableVideoComposition videoComposition];
    
    NSInteger i;
    CMTime insertionTime = kCMTimeZero;
    
    NSMutableArray *instructions = [NSMutableArray array];
    
    // Make transitionDuration no greater than half the shortest clip duration.
    CMTime transitionDuration = self.transitionDuration;
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
        insertionTime = CMTimeSubtract(insertionTime, transitionDuration);
    
        // Remember the time range for the transition to the next item.

        transitionTimeRanges[i] = CMTimeRangeMake(insertionTime, transitionDuration);
    

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






- (void)addBlackBackgroundTransitionsWithDuration:(float)intervalBetweenClipsInSeconds betweenClips:(NSArray*)takes
{
    CMTime emptyClipDuration = CMTimeMakeWithSeconds(intervalBetweenClipsInSeconds, 600);
   // [self insertEmptyTimeRangesWithDuration:3 betweenClips:takes intoComposition:[self spliceAssets:takes]];
    
    self.composition = [[AVMutableComposition alloc] init];
    
    // Add two video tracks and two audio tracks.
    AVMutableCompositionTrack *compositionVideoTracks[2];
    AVMutableCompositionTrack *compositionAudioTracks[2];
    compositionVideoTracks[0] = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    compositionVideoTracks[1] = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    compositionAudioTracks[0] = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    compositionAudioTracks[1] = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    self.videoComposition = nil;
    self.videoComposition = [AVMutableVideoComposition videoComposition];
    
    CMTimeRange *videoTimeRanges = alloca(sizeof(CMTimeRange) * [_videoClips count]);
    CMTimeRange *emptyClipTimeRanges = alloca(sizeof(CMTimeRange) * [_videoClips count]);
    //CMTimeRange *transitionTimeRanges = alloca(sizeof(CMTimeRange) * 2);
    CMTimeRange *fadeInTransitionTimeRanges = alloca(sizeof(CMTimeRange) * [_videoClips count]);
    //CMTimeRange *fadeOutTransitionTimeRanges = alloca(sizeof(CMTimeRange) *2);
    CMTimeRange *passThroughTimeRanges = alloca(sizeof(CMTimeRange) *[_videoClips count]);
    
    CMTime insertionTime = kCMTimeZero;
    CMTime transitionDuration = CMTimeMakeWithSeconds(1, 600); // 1 second fade in transition
    
    self.emptyClipTimeRanges = [[NSMutableArray alloc] init];
    
    for (int i=0; i<_videoClips.count;i++)
    {
        NSInteger alternatingIndex = i % 2;
        // get the asset and its time range: [0, assetsDuration]
        AVURLAsset *asset = self.videoClips[i];
        NSValue *clipTimeRange = _clipTimeRanges[i];
        CMTimeRange timeRangeInAsset;
        if (clipTimeRange)
            timeRangeInAsset = [clipTimeRange CMTimeRangeValue];
        else
            timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [asset duration]);
        
        AVAssetTrack *sourceVideoTrack = [asset tracksWithMediaType: AVMediaTypeVideo][0];
        AVAssetTrack *sourceAudioTrack = [asset tracksWithMediaType: AVMediaTypeAudio][0];
        
        // prior to the start of the video clip, there will be a blank/empty clip that shows for x seconds (value retreived from method parameter)
        
    
        emptyClipTimeRanges[i] = CMTimeRangeMake(insertionTime, emptyClipDuration);
        
        NSValue *emptyTimeRange = [NSValue valueWithCMTimeRange:emptyClipTimeRanges[i]];
        
        // remember the time ranges so that text can be added during those intervals
        [self.emptyClipTimeRanges addObject:emptyTimeRange];
        
    
        [compositionVideoTracks[alternatingIndex] insertEmptyTimeRange:emptyClipTimeRanges[i]];
        [compositionAudioTracks[alternatingIndex] insertEmptyTimeRange:emptyClipTimeRanges[i]];
        // start time at which the video clip is to be inserted (after the empty clip):
        insertionTime = CMTimeAdd(insertionTime, emptyClipDuration);
        
        // get time range in asset, and add to array of video time ranges
        videoTimeRanges[i] = CMTimeRangeMake(insertionTime, timeRangeInAsset.duration);
    
        fadeInTransitionTimeRanges[i] = CMTimeRangeMake(insertionTime, transitionDuration);
    
        passThroughTimeRanges[i] = CMTimeRangeMake(CMTimeAdd(insertionTime,transitionDuration), CMTimeSubtract(videoTimeRanges[i].duration, transitionDuration));
    
        [compositionVideoTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:sourceVideoTrack atTime:insertionTime error:nil];
        [compositionAudioTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:sourceAudioTrack atTime:insertionTime error:nil];
    
    
    
        insertionTime = CMTimeAdd(insertionTime, timeRangeInAsset.duration);
        
        NSLog(@"EMPTY:");
        CMTimeRangeShow(emptyClipTimeRanges[i]);
        NSLog(@"TRANSITION:");
        CMTimeRangeShow(fadeInTransitionTimeRanges[i]);
        NSLog(@"PASSTHROUGH TIME RANGES:");
        CMTimeRangeShow(passThroughTimeRanges[i]);
        //    NSLog(@"EMPTY:");
        //    CMTimeRangeShow(emptyClipTimeRanges[1]);
        //    NSLog(@"TRANSITION:");
        //    CMTimeRangeShow(fadeInTransitionTimeRanges[1]);
        //    NSLog(@"PASSTHROUGH TIME RANGES:");
        //    CMTimeRangeShow(passThroughTimeRanges[1]);
        
        NSLog(@"VIDEO CLIP TIME RANGE IN COMPOSITION:");
        CMTimeRangeShow(videoTimeRanges[i]);
        
        NSLog(@"SOURCE TRACK TIME RANGE");
        CMTimeRangeShow(timeRangeInAsset);
        
    }
    
//    self.parentLayer = [CALayer layer];
//    self.videoLayer = [CALayer layer];
    
    /* create an array of instructions for the video composition */
    NSMutableArray *videoInstructions = [[NSMutableArray alloc] init];
    self.keyTimesArray = [NSMutableArray array];
    
    for (int i=0; i<_videoClips.count; i++)
    {
        NSInteger alternatingIndex = i % 2;
        
        // we need the preferred transform of the asset track so the clips in the composition are are all in their proper expected orientations
        AVURLAsset *asset = self.videoClips[i];
        AVAssetTrack *assetTrack = [asset tracksWithMediaType: AVMediaTypeVideo][0];
        CGAffineTransform correctTransform = assetTrack.preferredTransform;
        
        /**-------------------------------**
         ** BLANK INTRO CLIP INSTRUCTIONS **
         **-------------------------------**/
        AVMutableVideoCompositionInstruction *blankIntroClipInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
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
        blankIntroClipInstruction.timeRange = emptyClipTimeRanges[i];
        
        [self.emptyClipTimeRanges addObject:[NSValue valueWithCMTimeRange:emptyClipTimeRanges[i]]];
        
        
        [self.keyTimesArray addObject:[NSNumber numberWithFloat:CMTimeGetSeconds(emptyClipTimeRanges[i].start)]];
        
       
        AVMutableVideoCompositionLayerInstruction *emptyLayer1A = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[alternatingIndex]];
        //AVMutableVideoCompositionLayerInstruction *emptyLayer1B = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrackB];
        [emptyLayer1A setOpacity:0.0 atTime:emptyClipTimeRanges[i].start];
        //[emptyLayer1B setOpacity:0.0 atTime:emptyClipTimeRanges[0].start];
        
        blankIntroClipInstruction.layerInstructions = [NSArray arrayWithObjects:emptyLayer1A, nil];
        [videoInstructions addObject:blankIntroClipInstruction];
        
        
        
        /**---------------------------------------**
         ** FADE-IN TRANSITION CLIP INSTRUCTIONS  **
         **---------------------------------------**/
        AVMutableVideoCompositionInstruction *transitionInstructionA = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        
        ///////////////////////////////////////////
        /* _____________________________________
          |     !   !                           |
         A|     |AAA!AAAAAAA|                   |
          |-----|xxx!*******|                   |
          |     !   !       |-----|xxx**********|
         B|     !000!       |      BBBBBBBBBBBBB|
          |_____!___!___________________________|
          [<->]
         
         *//////////////////////////////////////////
        // Time range of interest for this composition:
        transitionInstructionA.timeRange = fadeInTransitionTimeRanges[i];
        
        /* layer instruction for track A  = xxx */
        AVMutableVideoCompositionLayerInstruction *aInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[alternatingIndex]];
        // apply opacity ramp for fade in
        [aInstruction setOpacityRampFromStartOpacity:0.0
                                        toEndOpacity:1.0
                                           timeRange:fadeInTransitionTimeRanges[i]];
        
        
        [aInstruction setTransform:correctTransform atTime:fadeInTransitionTimeRanges[i].start];
        
        //AVMutableVideoCompositionLayerInstruction *bLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrackB];
        
        //[bLayerInstruction setOpacity:0.0 atTime:fadeInTransitionTimeRanges[0].start];
        
        transitionInstructionA.layerInstructions = [NSArray arrayWithObjects:aInstruction, /*bLayerInstruction,*/ nil];
        
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
        passThroughA.timeRange = passThroughTimeRanges[i];
        /* Pass through layer instructions for track A. */
        AVMutableVideoCompositionLayerInstruction *passThroughLayerA= [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[alternatingIndex]];
        // passThroughLayerB...
        
        [passThroughLayerA setOpacity:1.0 atTime:passThroughA.timeRange.start];
        // set opacity for layer B??
        [passThroughLayerA setTransform:correctTransform atTime:passThroughA.timeRange.start];
        
        //[passThroughLayerA setTransform:sourceVideoTrack.preferredTransform atTime:passThroughTimeRanges[0].start];
        passThroughA.layerInstructions = @[passThroughLayerA];
        [videoInstructions addObject:passThroughA];
        
    }
    
    /**/
    
    self.videoComposition.instructions = [NSArray arrayWithArray:videoInstructions];
    
    self.videoComposition.frameDuration = CMTimeMake(1, 30);
    
    self.videoComposition.renderSize = compositionVideoTracks[0].naturalSize;
    
    self.videoComposition.renderScale = 1.0;

    CGSize size = self.videoComposition.renderSize;


    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer addSublayer:videoLayer];
    
    for (int i=0; i<_videoClips.count; i++)
    {
        NSLog(@"EMPTY:");
        CMTimeRangeShow(emptyClipTimeRanges[i]);
        if (i == 0)
        {
//            [parentLayer addSublayer:[self createTextLayerWithSize:size WithTitleText:self.sceneTitlesForTakes[i] withAnimationAtTime:AVCoreAnimationBeginTimeAtZero]];
            [parentLayer addSublayer:[self createAnimatedTextLayerWithSize:size WithTitleText:self.sceneTitlesForTakes[i] withAnimationAtTime:AVCoreAnimationBeginTimeAtZero]];
            
        }
        else{
//            [parentLayer addSublayer:[self createTextLayerWithSize:size WithTitleText:self.sceneTitlesForTakes[i] withAnimationAtTime:CMTimeGetSeconds(emptyClipTimeRanges[i].start)]];
    
            [parentLayer addSublayer:[self createAnimatedTextLayerWithSize:size WithTitleText:self.sceneTitlesForTakes[i] withAnimationAtTime:CMTimeGetSeconds(emptyClipTimeRanges[i].start)]];

            
        }
       // try animation tool here here as well.
        
    }
    self.videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 /*
    for (int i=0; i<_videoClips.count; i++)
    {
        if (i == 0)
        {
            [self applyVideoEffectsToComposition:self.videoComposition atTime:AVCoreAnimationBeginTimeAtZero withTitle:self.sceneTitlesForTakes[i]];
            
        }
        else{
            [self applyVideoEffectsToComposition:self.videoComposition atTime:CMTimeGetSeconds(emptyClipTimeRanges[i].start) withTitle:self.sceneTitlesForTakes[i]];
            
        }
        
    }*/
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
//    self.parentLayer.frame = CGRectMake(0, 0, self.videoComposition.renderSize.width, self.videoComposition.renderSize.height);
//    self.videoLayer.frame = CGRectMake(0, 0,self.videoComposition.renderSize.width, self.videoComposition.renderSize.height);
//    [self.parentLayer addSublayer:self.videoLayer];
    
     ///self.videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:self.videoLayer inLayer:self.parentLayer];

    //[self applyTextOverlay:self.sceneTitlesForTakes[i] toComposition:self.videoComposition forTimeRange:emptyClipTimeRanges[i]];
    
   // [self applyVideoEffectsToComposition:self.videoComposition size:self.videoComposition.renderSize];
    
//        [self applyTextOverlay:self.sceneTitlesForTakes[i] withSize:self.videoComposition.renderSize toComposition:self.videoComposition forTimeRange:emptyClipTimeRanges[i]];
    
    
    
//    [self applyVideoEffectsToComposition:self.videoComposition size:self.videoComposition.renderSize];
//    CALayer *parentLayer = [CALayer layer];
//    CALayer *videoLayer = [CALayer layer];
//    parentLayer.frame = CGRectMake(0, 0, self.videoComposition.renderSize.width, self.videoComposition.renderSize.height);
//    videoLayer.frame = CGRectMake(0, 0,self.videoComposition.renderSize.width, self.videoComposition.renderSize.height);
//    [parentLayer addSublayer:videoLayer];
//    [parentLayer addSublayer:self.titleTextLayer];
    
    //self.videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    [self exportVideoComposition:self.composition];
    //return self.composition;
    
    // try animating each individual text layer insread of the whole title layer....
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

- (void) exportVideoComposition:(AVAsset*)composition
{
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
                                        for (NSURL *compositionURL in self.videoLibrary.editedVideoURLs)
                                        {
                                            NSLog(@"%@", compositionURL);
                                        }
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
- (CATextLayer*)textOverlayLayerWithTitle:(NSString*)title forSize:(CGSize)videoSize
{
 //Create a layer for the text of the title.
    CATextLayer *titleLayer = [CATextLayer layer];
    //titleLayer.string = self.titleText;
    titleLayer.string = title;
    titleLayer.font = (__bridge CFTypeRef)(@"Helvetica");
    titleLayer.fontSize = videoSize.height / 6;
    titleLayer.foregroundColor = [UIColor whiteColor].CGColor;
    //?? titleLayer.shadowOpacity = 0.5;
    titleLayer.alignmentMode = kCAAlignmentCenter;
    titleLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    titleLayer.opacity = 0.0;
    
    return titleLayer;
    
}
//- (CALayer *)textOverlayWithTitle:(NSString*)title forSize:(CGSize)videoSize
//{
    // Create a layer for the overall title animation.
  //  CALayer *animatedTitleLayer = [CALayer layer];
    
//    // Create a layer for the text of the title.
//    CATextLayer *titleLayer = [CATextLayer layer];
//    //titleLayer.string = self.titleText;
//    titleLayer.string = @"TEXT OVERLAY TITLE";
//    titleLayer.font = (__bridge CFTypeRef)(@"Helvetica");
//    titleLayer.fontSize = videoSize.height / 6;
//    titleLayer.foregroundColor = [UIColor whiteColor].CGColor;
//    //?? titleLayer.shadowOpacity = 0.5;
//    titleLayer.alignmentMode = kCAAlignmentCenter;
//    titleLayer.bounds = CGRectMake(0, 0, videoSize.width, videoSize.height / 6);
//    
    // Add it to the overall layer.
   // [animatedTitleLayer addSublayer:titleLayer];
    
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
//    animatedTitleLayer.position = CGPointMake(videoSize.width / 2.0, videoSize.height / 2.0);
    //[animatedTitleLayer addSublayer:ringOfStarsLayer];
    
    // Animate the opacity of the overall layer so that it fades out from 3 sec to 4 sec.

//    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0];
//    fadeAnimation.toValue = [NSNumber numberWithFloat:0.0];
//    fadeAnimation.additive = NO;
//    fadeAnimation.removedOnCompletion = NO;
//    fadeAnimation.beginTime = AVCoreAnimationBeginTimeAtZero;
//    fadeAnimation.duration = seconds;
//    fadeAnimation.fillMode = kCAFillModeBoth;
//    [animatedTitleLayer addAnimation:fadeAnimation forKey:nil];
//    
//    return animatedTitleLayer;
//}
//
- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition atTime:(float)startTime withTitle:(NSString*)title
{
    CGSize size = composition.renderSize;
    

    // Add it to the overall layer.

    // 1 - Set up the text layer
    CATextLayer *textLayer = [[CATextLayer alloc] init];
    [textLayer setFont:@"Helvetica-Bold"];
    [textLayer setFontSize:130];
    [textLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
    [textLayer setString:title];
    [textLayer setAlignmentMode:kCAAlignmentCenter];
    [textLayer setForegroundColor:[[UIColor whiteColor] CGColor]];
    
      //?? titleLayer.shadowOpacity = 0.5;
    
    
    // 2 - The usual overlay
//    CALayer *titleLayer = [CALayer layer];
//    [titleLayer addSublayer:textLayer];
//    titleLayer.frame = CGRectMake(0, 0, size.width, size.height);
//    [titleLayer setMasksToBounds:YES];
    // titleLayer.bounds = CGRectMake(0, 0, videoSize.width, videoSize.height / 6);
    
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:textLayer];
    

    
        CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0];
        fadeAnimation.toValue = [NSNumber numberWithFloat:0.0];
        fadeAnimation.additive = NO;
        fadeAnimation.removedOnCompletion = NO;
        fadeAnimation.beginTime = startTime;
        fadeAnimation.duration = 3.0;
        fadeAnimation.fillMode = kCAFillModeBoth;
        [textLayer addAnimation:fadeAnimation forKey:nil];
        
    
    
    

    composition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];

    
}

-(CATextLayer*)createTextLayerWithSize:(CGSize)size WithTitleText:(NSString*)title withAnimationAtTime:(float)startTime
{
    CATextLayer *textLayer = [[CATextLayer alloc] init];
    [textLayer setFont:@"Helvetica-Bold"];
    [textLayer setFontSize:130];
    [textLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
    [textLayer setString:title];
    [textLayer setAlignmentMode:kCAAlignmentCenter];
    [textLayer setForegroundColor:[[UIColor whiteColor] CGColor]];
    
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    fadeAnimation.toValue = [NSNumber numberWithFloat:0.0];
    fadeAnimation.additive = NO;
    fadeAnimation.removedOnCompletion = NO;
    fadeAnimation.beginTime = startTime;
    fadeAnimation.duration = 3.0;
    fadeAnimation.fillMode = kCAFillModeBackwards;
    [textLayer addAnimation:fadeAnimation forKey:nil];
    
    return textLayer;
}

-(CATextLayer*)createAnimatedTextLayerWithSize:(CGSize)size WithTitleText:(NSString*)title withAnimationAtTime:(CFTimeInterval)startTime
{
    CATextLayer *textLayer = [[CATextLayer alloc] init];
    [textLayer setFont:@"Helvetica-Bold"];
    [textLayer setFontSize:130];
    [textLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
    [textLayer setString:title];
    [textLayer setAlignmentMode:kCAAlignmentCenter];
    [textLayer setForegroundColor:[[UIColor whiteColor] CGColor]];
    
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    fadeInAnimation.toValue = [NSNumber numberWithFloat:1.0];
    fadeInAnimation.additive = NO;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.beginTime = startTime;
    fadeInAnimation.duration = 1.0;
    fadeInAnimation.fillMode = kCAFillModeBackwards;
    [textLayer addAnimation:fadeInAnimation forKey:@"fadeIn"];
    
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOutAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    fadeOutAnimation.toValue = [NSNumber numberWithFloat:0.0];
    fadeOutAnimation.additive = NO;
    fadeOutAnimation.removedOnCompletion = NO;
    fadeOutAnimation.beginTime = startTime + 2.0;
    fadeOutAnimation.duration = 1.0;
    fadeOutAnimation.fillMode = kCAFillModeForwards;
    [textLayer addAnimation:fadeOutAnimation forKey:@"fadeOut"];
    
    
    
    
    return textLayer;
}

 -(void)applyTextOverlay:(NSString*)titleText forTimeRange:(CMTimeRange)timeRange
{
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
//        
//        double assetDuration = CMTimeGetSeconds(timeRangeInAsset.duration);
//    
    
    
    // Add it to the overall layer.
    
    
   // CALayer *parentLayer = [CALayer layer];

    // CALayer *videoLayer = [CALayer layer];
    
    
    
    
    
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
//
//        double assetDuration = CMTimeGetSeconds(timeRangeInAsset.duration);
//    
//        double assetStartTime = CMTimeGetSeconds(timeRangeInAsset.start);
    
   
    
        double startTime = CMTimeGetSeconds(timeRange.start);
        double duration = CMTimeGetSeconds(timeRange.duration);
        
    CATextLayer *textLayer = [self textOverlayLayerWithTitle:titleText forSize:self.videoComposition.renderSize];

        // 1 - Set up the text layer
//        CATextLayer *textLayer = [CALayer layer];
//        [textLayer setFont:@"Helvetica-Bold"];
//        [textLayer setFontSize:136];
//        [textLayer setFrame:CGRectMake(0, 0, self.videoComposition.renderSize.width, 200)];
//        textLayer.wrapped = YES;
//     //   [textLayer setString:self.sceneTitlesForTakes[i]];
//        [textLayer setAlignmentMode:kCAAlignmentCenter];
//        [textLayer setForegroundColor:[[UIColor whiteColor] CGColor]];
        //?? titleLayer.shadowOpacity = 0.5;
        
        
        // 2 - The usual overlay
        CALayer *titleLayer = [CALayer layer];
       // [titleLayer addSublayer:textLayer];
        titleLayer.frame = CGRectMake(0, 0, self.videoComposition.renderSize.width, self.videoComposition.renderSize.height);
        [titleLayer setMasksToBounds:YES];
        // titleLayer.bounds = CGRectMake(0, 0, videoSize.width, videoSize.height / 6);
    [titleLayer addSublayer:textLayer];
    [CATransaction begin];
    
        CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0];
        fadeAnimation.toValue = [NSNumber numberWithFloat:0.0];
        fadeAnimation.additive = NO;
        fadeAnimation.removedOnCompletion = NO;
    NSLog(@"start time %f dur %f", startTime, duration);
    
    fadeAnimation.beginTime = startTime;
    if (startTime == 0.0)
    {
        fadeAnimation.beginTime = AVCoreAnimationBeginTimeAtZero;
    }
    
    
    
            //fadeAnimation.beginTime = AVCoreAnimationBeginTimeAtZero;
    
        
        fadeAnimation.duration = duration;
        fadeAnimation.fillMode = kCAFillModeBoth;
        [titleLayer addAnimation:fadeAnimation forKey:nil];
    [CATransaction commit];
    
        [self.parentLayer addSublayer:titleLayer];
    
    
        // text does not fade in or fade out
//        CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//        fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0];
//        fadeAnimation.toValue = [NSNumber numberWithFloat:1.0];
//        fadeAnimation.additive = NO;
//        fadeAnimation.removedOnCompletion = YES;
//        fadeAnimation.beginTime = startTime;
//        fadeAnimation.duration = duration;
//        fadeAnimation.fillMode = kCAFillModeBoth;
//        [titleLayer addAnimation:fadeAnimation forKey:nil];
//        
    
    

    //self.titleTextLayer = titleLayer;
    
    // do this in playback view controller.
//    AVPlayerItem *compositionItem = [[AVPlayerItem alloc] initWithAsset:self.composition];
//    // synchronized layer to own all the title layers
    
//    synchronizedLayer.frame = CGRectMake(100,100,300,300);
//    
    //[self.view.layer addSublayer:synchronizedLayer];
    
   
}

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
{
    

    //Contains CMTime array for the time duration [0-1]

  
    //AVSynchronizedLayer *synchronizedLayer = [AVSynchronizedLayer synchronizedLayerWithPlayerItem:composition];
    
    //Calculate Video Duration Time
    
//    self.titleLayer.frame = CGRectMake(0, 0, size.width, size.height);
//
//    self.titleLayer setMasksToBounds:YES];
//
//    self.titleLayer.bounds = CGRectMake(0, 0, videoSize.width, videoSize.height / 6);
    
    //ANIMATION START
    CALayer *parentLayer = [CALayer layer];
    parentLayer.backgroundColor = [UIColor redColor].CGColor;
    
    CALayer *videoLayer = [CALayer layer];
    videoLayer.backgroundColor = [UIColor orangeColor].CGColor;
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer addSublayer:videoLayer];
    
    AVSynchronizedLayer *animationLayer = [CALayer layer];
    animationLayer.opacity = 1.0;
    animationLayer.backgroundColor = [UIColor yellowColor].CGColor;
    [animationLayer setFrame:videoLayer.frame];
    [parentLayer addSublayer:animationLayer];

    for (int i=0; i<_videoClips.count; i++)
    {
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer = [self textOverlayLayerWithTitle:self.sceneTitlesForTakes[i] forSize:self.videoComposition.renderSize];
        if (!self.titleLayer) self.titleLayer = [CALayer layer];
        
        [parentLayer addSublayer:self.titleLayer];
        [self.titleLayer addSublayer:textLayer];
        
        
    }
    
    
//    CAKeyframeAnimation *frameAnimation = [[CAKeyframeAnimation alloc] init];
//    frameAnimation.beginTime = AVCoreAnimationBeginTimeAtZero;
//    [frameAnimation setKeyPath:@"opacity"];
//    frameAnimation.calculationMode = kCAAnimationLinear;
//    frameAnimation.autoreverses = YES; //If set Yes, transition would be in fade in fade out manner
//    frameAnimation.duration = 3.0;
//    frameAnimation.repeatCount = 1; //this is for inifinite, can be set to any integer value as well
//    [frameAnimation setValues:self.sceneTitlesForTakes];
//    [frameAnimation setKeyTimes:self.keyTimesArray];
//    [frameAnimation setRemovedOnCompletion:NO];
//    [frameAnimation setDelegate:self];
//    [animationLayer addAnimation:frameAnimation forKey:@"opacity"];
    
    //END ANIMATION
    //CALayer *parentLayer = [CALayer layer];
    //CALayer *videoLayer = [CALayer layer];

  //  parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
  //  videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
  //  [parentLayer addSublayer:videoLayer];
    
    
    // main titles
//    for (int i=0; i<_videoClips.count; i++)
//    {
//        
//        
//        AVURLAsset *asset = self.videoClips[i];
//        NSValue *clipTimeRange = [_clipTimeRanges objectAtIndex:i];
//        CMTimeRange timeRangeInAsset;
//        
//        if (clipTimeRange)
//            timeRangeInAsset = [clipTimeRange CMTimeRangeValue];
//        else
//            timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [asset duration]);
//        
//
//        double assetDuration = CMTimeGetSeconds(timeRangeInAsset.duration);
//        
//        double assetStartTime = CMTimeGetSeconds(timeRangeInAsset.start);
//        
//        //insertionTime += assetStartTime;
//        
//        
//        
//        CATextLayer *textLayer = [CATextLayer layer];
//        textLayer = [self textOverlayLayerWithTitle:self.sceneTitlesForTakes[i] forSize:self.videoComposition.renderSize];
//        if (!self.titleLayer) self.titleLayer = [CALayer layer];
//       
//        [parentLayer addSublayer:self.titleLayer];
//        [self.titleLayer addSublayer:textLayer];
//        
//        // main title opacity animation
//        [CATransaction begin];
//        [CATransaction setDisableActions:YES];
//        CABasicAnimation *mainTitleInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//        mainTitleInAnimation.fromValue = [NSNumber numberWithFloat: 1.0];
//        mainTitleInAnimation.toValue = [NSNumber numberWithFloat: 0.0];
//        mainTitleInAnimation.removedOnCompletion = NO;
//        if (i==0)
//        {
//            mainTitleInAnimation.beginTime = AVCoreAnimationBeginTimeAtZero;
//        }
//        else{
//            mainTitleInAnimation.beginTime = assetStartTime;
//        }
//        //mainTitleInAnimation.beginTime = AVCoreAnimationBeginTimeAtZero;
//        mainTitleInAnimation.duration = 3.0;// = mainTItlOutAnimaton.beginTime
//        [textLayer addAnimation:mainTitleInAnimation forKey:@"in-animation"];
//        
//        CABasicAnimation *mainTitleNoAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//        mainTitleNoAnimation.fromValue = [NSNumber numberWithFloat: 0.0];
//        mainTitleNoAnimation.toValue = [NSNumber numberWithFloat: 0.0];
//        mainTitleNoAnimation.removedOnCompletion = NO;
//        mainTitleNoAnimation.beginTime = 3.0;
//        mainTitleNoAnimation.duration = assetDuration;// = mainTItlOutAnimaton.beginTime
//        [textLayer addAnimation:mainTitleNoAnimation forKey:@"in-animation"];
//        
    
//        CABasicAnimation *mainTitleOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//        mainTitleOutAnimation.fromValue = [NSNumber numberWithFloat: 1.0];
//        mainTitleOutAnimation.toValue = [NSNumber numberWithFloat: 0.0];
//        mainTitleOutAnimation.removedOnCompletion = NO;
//        mainTitleOutAnimation.beginTime = assetDuration;
//        mainTitleOutAnimation.duration = 3.0;
//        [mainTitleLayer addAnimation:mainTitleOutAnimation forKey:@"out-animation"];
        [CATransaction commit];

        //insertionTime = insertionTime + 3.0f;
        
}

//    self.videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:self.titleLayer];

    //return self.titleTextLayer;
    
    
    
    //mainTitleLayer.string = NSLocalizedString(@"Running Start", nil);
    //mainTitleLayer.font = @"Verdana-Bold";
    //mainTitleLayer.fontSize = videoSize.height / 8;
    //mainTitleLayer.foregroundColor = [[UIColor yellowColor] CGColor];
//    mainTitleLayer.alignmentMode = kCAAlignmentCenter;
//    mainTitleLayer.frame = CGRectMake(0.0, 0.0, videoSize.width, videoSize.height);
//    mainTitleLayer.opacity = 0.0; // initially invisible
//    
    /*[synchronizedLayer addSublayer:mainTitleLayer];*/
    
//    // main title opacity animation
//    [CATransaction begin];
//    [CATransaction setDisableActions:YES];
//    CABasicAnimation *mainTitleInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    mainTitleInAnimation.fromValue = [NSNumber numberWithFloat: 0.0];
//    mainTitleInAnimation.toValue = [NSNumber numberWithFloat: 1.0];
//    mainTitleInAnimation.removedOnCompletion = NO;
//    mainTitleInAnimation.beginTime = AVCoreAnimationBeginTimeAtZero;
//    mainTitleInAnimation.duration = 5.0;// = mainTItlOutAnimaton.beginTime
//    [mainTitleLayer addAnimation:mainTitleInAnimation forKey:@"in-animation"];
//    
//    
//    CABasicAnimation *mainTitleOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    mainTitleOutAnimation.fromValue = [NSNumber numberWithFloat: 1.0];
//    mainTitleOutAnimation.toValue = [NSNumber numberWithFloat: 0.0];
//    mainTitleOutAnimation.removedOnCompletion = NO;
//    mainTitleOutAnimation.beginTime = 5.0;
//    mainTitleOutAnimation.duration = 2.0;
//    [mainTitleLayer addAnimation:mainTitleOutAnimation forKey:@"out-animation"];
//    [CATransaction commit];
    
    

    /*
    
    */

//    //NSLog(@"timer scale, value: %d %lld", timer.timescale, timer.value);
//    //expecting positive values
//    NSLog(@"mixComposition properties: %@", self.composition.debugDescription);
//    
//    self.videoComposition.instructions = [NSArray arrayWithObject:instruction];




@end
