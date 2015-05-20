//
//  VideoMerger.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-03.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "VideoMerger.h"


#define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )
@interface VideoMerger ()

@property (nonatomic, getter = isFrontFacingVideoInTakes) BOOL frontFacingVideoInTakes;

@end

@implementation VideoMerger


//interpret the takes to access all tracks

//for each asset in takes {
//add asset tracks to video track
//add audio track for audio track
//timer = CMTimeAdd(timer, asset.duration)
//}

//log timer, log mutablecomposition.tracks

//make avasset from avmutablecomposition (is an avasset)

//- (void) loadMetadata
//{
//    AVAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
//    // Load the values of AVAsset keys to inspect subsequently
//    NSArray *assetKeysToLoadAndTest = @[@"playable", @"composable", @"tracks", @"duration"];
//    
//    // Tells the asset to load the values of any of the specified keys that are not already loaded.
//    [asset loadValuesAsynchronouslyForKeys:assetKeysToLoadAndTest completionHandler:
//     ^{
//         dispatch_async( dispatch_get_main_queue(),
//                        ^{
//                            // IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem.
//                           // [self setUpPlaybackOfAsset:asset withKeys:assetKeysToLoadAndTest];
//                        });
//     }];
//    
//    self.inputAsset = asset;
//}

//
//- (NSMutableArray*)videoClipTimeRangesFromAssets:(NSMutableArray*)assets
//{
//    NSMutableArray *timeRanges = [NSMutableArray array];
//    CMTime insertionPoint = kCMTimeZero;
//
//    for (int i=0; i<assets.count; i++)
//    {
//        AVAsset *asset = assets[i];
//        NSError *error = nil;
//        if ([asset statusOfValueForKey:@"duration" error:&error] == AVKeyValueStatusLoaded)
//        {
//            
//            NSValue *timeRangeOfAsset = [NSValue valueWithCMTimeRange:CMTimeRangeMake(insertionPoint, asset.duration)];
//            [timeRanges addObject:timeRangeOfAsset];
//            
////            insertionPoint = CMTimeAdd(insertionPoint, asset.duration);
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"ASSET TIME RANGE/DURATION: %@", timeRangeOfAsset.description);
//            });
//        }
//        else
//        {
//            //NSValue *timeRangeOfAsset = [NSValue valueWithCMTimeRange:CMTimeRangeMake(kCMTimeZero, [self loadDurationOfAsset:asset])];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"ERROR: %@", error);
//            });
//            
//        }
//    }
//
//    
//}

//
//- (void)loadDurationOfAsset:(AVAsset*)asset
//{
//    
//    
//    NSString *durationKey = @"duration";
//    
//    [asset loadValuesAsynchronouslyForKeys:@[durationKey] completionHandler:
//     ^{
//         NSError *error = nil;
//         switch ([asset statusOfValueForKey:@"duration" error:&error])
//         {
//                 
//             case AVKeyValueStatusLoaded:
//                 // duration is now known, so we can fetch it without blocking
//                 //CMTime duration = [asset valueForKey:@"duration"];
//                 //CMTime duration = [asset duration];
//                 //assetDuration = asset.duration;
//                 break;
//            default:
//                 break;
//         }
//         //// completion block
//         
//     }];
//    
//}

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
    /// - CHECK IF FRONT FACING/BACK FACING VIDEOS IN COPOSITION ARE MIXED
    /*
    -   also check if there are any videos in the array are front facing, so that we know whether or not to scale down the video clips that are recorded with the back facing camera (1920x1080 whereas the front facing camera takes videos that are 1280x720)
    -   if no front facing videos are in this array, then no scaling needs to be done on the videos and they can all have the samee 1920x1080 resolution
    -   if there is at least one video that is front facing, we must scale all videos (that are back facing) down to 1280x720 otherwise the final composition will contain videos where large parts of the video frame are cropped or the front facing videos contain unsightly black bars on the bottom and right edges of the video.
    */
    // POSSIBLE SCALING SOLUTION ^__^
    // to scale down properly you should probably export the videos that are using the back facing camera individually with a preset of 1280x720 and take that result replace it in the array of assets to merge. then do the merging/export of the final composition. if this doesnt work then i dont know...
    
    
    NSMutableArray *clips = [NSMutableArray array];
   
    self.frontFacingVideoInTakes = NO;
 
    for (Take *take in takes)
    {
        NSDictionary *options = @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES };
        // Load the values of AVAsset keys to inspect subsequently
        //NSArray *assetKeysToLoadAndTest = @[@"playable", @"composable", @"tracks", @"duration"];
        
        AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:[take getFileURL] options:options];
        
        CMTime durationOfAsset = urlAsset.duration;
        NSValue *timeRange = [NSValue valueWithCMTimeRange:CMTimeRangeMake(kCMTimeZero, durationOfAsset)];
        
        [self.clipTimeRanges addObject:timeRange];
      
        [clips addObject:urlAsset];
        
        switch (take.videoOrientationAndPosition)
        {
            case LandscapeLeft_Back:
                // all videos in composition so far are front facing
                if (self.isFrontFacingVideoInTakes)
                {
                  
                }
                else{
                    // scale this current composition video track down to the size of the smallest composition track in the composition
                }
                break;
                
            case LandscapeLeft_Front:
               
                // if isFrontFacingVideoInAssets = NO then this is the first asset in the compostion that is front facing, so we must scale all previous videos in the composition down to a size that will fit this one. otherwise there will be black bars on the sides of this video.
                
                if (self.isFrontFacingVideoInTakes)
                {
                    
                }
                self.frontFacingVideoInTakes = YES;
                
                break;
                
            case LandscapeRight_Back:
              
                // if we havent seen a video that uses front fcaing camera, the render widtths and heights can be
                if (self.isFrontFacingVideoInTakes)
                {
                    
                }
              
                break;
                
            case LandscapeRight_Front:
                
                self.frontFacingVideoInTakes = YES;
                // front facing video is in list of takes, overwrite previously set widths,heights for the other videos.
               
                break;
                
            default:
                break;
                
        }
        

    }
    //[self videoClipTimeRangesFromAssets:clips];
    _videoClips =[NSArray arrayWithArray:clips];
    
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
    
    self.transitionDuration = CMTimeMakeWithSeconds(1, 1); // default transition time=1second
    //[self prepareAssetsFromTakes:takes];
    
    self.composition = [AVMutableComposition composition];
    self.videoComposition = [AVMutableVideoComposition videoComposition];
    
    NSInteger i;
    CMTime insertionTime = kCMTimeZero;

    
    NSMutableArray *instructions = [NSMutableArray array];
    
    
    // Make transitionDuration no greater than half the shortest clip duration.
    CMTime transitionDuration = self.transitionDuration;
    for (i = 0; i < _videoClips.count; i++ )
    {
        NSValue *clipTimeRange = [_clipTimeRanges objectAtIndex:i];
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
    

//    AVMutableVideoCompositionInstruction *videoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//
//    AVMutableVideoCompositionInstruction *preferredTransformInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//
//    AVMutableVideoCompositionLayerInstruction *layer1 = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[0]];
////
//
//    AVMutableVideoCompositionLayerInstruction *layer2 = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[1]];
////    

    //NSArray *layerInstructions = [NSArray arrayWithObjects:layer1, layer2, nil];
//
//    CGAffineTransform preferredTransform;
    
    // Place clips into alternating video & audio tracks in composition, overlapped by transitionDuration.
    
    NSMutableArray *preferredTransforms = [NSMutableArray array];
    for (i = 0; i < _videoClips.count; i++ )
    {
        NSLog(@"videoClips.count: %i", _videoClips.count);
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
    /////
        
        
        AVAssetTrack *assetTrack_video = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        
        NSLog(@"assetTrack_video.preferredTransform:");
        NSLog(@"%f,%f,%f,%f",assetTrack_video.preferredTransform.a, assetTrack_video.preferredTransform.b, assetTrack_video.preferredTransform.c, assetTrack_video.preferredTransform.d);

        NSInteger *isIdentity;
        
    
        if ([[NSNumber numberWithFloat: assetTrack_video.preferredTransform.a] isEqualToNumber:@1])
        {
            NSLog(@"assetTrack_video isEqual to @1!!!");
            //do stuff to orient it properly
        }
        else
        {
            NSLog(@"assetTrack_video is NOT equal to @1!!!");
        }
        
//        [preferredTransforms addObject:isIdentity];
        
        //[compositionVideoTracks[alternatingIndex] setPreferredTransform:assetTrack_video.preferredTransform];
    /////

        [compositionVideoTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:assetTrack_video atTime:insertionTime error:nil];
//        
//        [layerInstructions[alternatingIndex] setTransform:assetTrack_video.preferredTransform atTime:insertionTime];
//        //[layerInstructions[alternatingIndex] setTransformRampFromStartTransform:assetTrack_video.preferredTransform toEndTransform:assetTrack_video.preferredTransform timeRange:timeRangeInAsset];
//    
//        preferredTransformInstruction.timeRange = timeRangeInAsset;
//        //
//        preferredTransformInstruction.layerInstructions = layerInstructions;
//        [instructions addObject:preferredTransformInstruction];
        
        
//        // instructions for setting the preferred transform of the asset so that all the videos in the composition have the same orientation

     

//      AVMutableVideoCompositionLayerInstruction *transformLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[alternatingIndex]];
        //[transformLayerInstruction setTransformRampFromStartTransform:assetTrack_video.preferredTransform toEndTransform:assetTrack_video.preferredTransform timeRange:timeRangeInAsset];
////
//      preferredTransformInstruction.timeRange = timeRangeInAsset;
//
//        preferredTransformInstruction.layerInstructions = [NSArray arrayWithObject:transformLayerInstruction];
//        [instructions addObject:preferredTransformInstruction];
//        
        
        
        
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
        if (i+1 < _videoClips.count)
        {
            transitionTimeRanges[i] = CMTimeRangeMake(insertionTime, transitionDuration);
        }

    }
    
    //[instructions addObject:videoCompositionInstruction];
  
    
    CMTime transformTime = kCMTimeZero;
    // Cycle between "pass through A", "transition from A to B", "pass through B", "transition from B to A".
    for (int i=0; i<_videoClips.count; i++ )
    {
        AVURLAsset *asset = _videoClips[i];
        AVAssetTrack *assetTrack_video = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        
        
        NSInteger alternatingIndex = i % 2; // alternating targets
    
        // Pass through clip i.
        AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        passThroughInstruction.timeRange = passThroughTimeRanges[i];
        AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[alternatingIndex]];
        NSLog(@"assetTrack_video.preferredTransform:");
        NSLog(@"%f,%f,%f,%f", asset.preferredTransform.a, asset.preferredTransform.b, asset.preferredTransform.c, asset.preferredTransform.d);
        
        CGAffineTransform transform = assetTrack_video.preferredTransform;
        if (transform.a == -1.0f && transform.d == -1.0f)
        {
            //CGAffineTransform t1 = CGAffineTransformMakeTranslation(1920, 1080);
            //CGAffineTransform t2 = CGAffineTransformRotate(asset.preferredTransform, M_PI);
            
            //CGAffineTransform t3 = CGAffineTransformTranslate(asset.preferredTransform, 1920, 1080);
            CGAffineTransform t2 = CGAffineTransformMake(-1, 0, 0, -1,1920,1080);
            CGAffineTransform t3 = CGAffineTransformConcat(asset.preferredTransform, t2);
            //CGAffineTransform t2 = asset.preferredTransform;
            
            [passThroughLayer setTransform:t3 atTime:transformTime];
        }
        else
        {
            
        }
       // CGAffineTransform t1 = CGAffineTransformRotate(asset.preferredTransform, M_PI);
        //CGAffineTransform t2 = CGAffineTransformTranslate(t1, 1920, 1080);
      
       
    
        passThroughInstruction.layerInstructions = [NSArray arrayWithObject:passThroughLayer];
        
        [instructions addObject:passThroughInstruction];
        
        transformTime = CMTimeAdd(transformTime, asset.duration);
        
        
        if (i+1 < [_videoClips count])
        {
            // Add transition from clip i to clip i+1.
            
            AVMutableVideoCompositionInstruction *transitionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            transitionInstruction.timeRange = transitionTimeRanges[i];
            
            AVMutableVideoCompositionLayerInstruction *fromLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[alternatingIndex]];
            
            AVMutableVideoCompositionLayerInstruction *toLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[1-alternatingIndex]];
            
            
            
            if (self.transitionType == TransitionTypeCrossFade)
            {
                // Fade out the fromLayer by setting a ramp from 1.0 to 0.0.
                [fromLayer setOpacityRampFromStartOpacity:1.0 toEndOpacity:0.0 timeRange:transitionTimeRanges[i]];
                
                //[fromLayer setTransform:preferredTransform atTime:transformTime];
            }
            else if (self.transitionType == TransitionTypePush)
            {
                // Set a transform ramp on fromLayer from identity to all the way left of the screen.
                [fromLayer setTransformRampFromStartTransform:CGAffineTransformIdentity toEndTransform:CGAffineTransformMakeTranslation(-self.composition.naturalSize.width, 0.0) timeRange:transitionTimeRanges[i]];
                // Set a transform ramp on toLayer from all the way right of the screen to identity.
                
            
                [toLayer setTransformRampFromStartTransform:CGAffineTransformMakeTranslation(+self.composition.naturalSize.width, 0.0) toEndTransform:CGAffineTransformIdentity timeRange:transitionTimeRanges[i]];
            }
            
            transitionInstruction.layerInstructions = [NSArray arrayWithObjects:fromLayer, toLayer, nil];
            
            [instructions addObject:transitionInstruction];
            
        }
    }

    self.videoComposition.frameDuration = CMTimeMake(1,30);
    self.videoComposition.renderScale = 1.0;
    self.videoComposition.renderSize = CGSizeMake(1920, 1080);
    
    self.videoComposition.instructions = [NSArray arrayWithArray:instructions];
//    for (i=0; i<self.videoClips.count;i++)
//    {
//        NSValue *clipTimeRange = self.clipTimeRanges[i];
//        NSLog(@"clip time ranges: %@", clipTimeRange.description);
//        [self.composition.tracks objectAtIndex:i];
//        
//    }
    return self.composition;
}



- (AVAsset*)buildCompositionObjects:(NSArray*)takes
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"videoMergingStartedNotification" object:nil];
    [self prepareAssetsFromTakes:takes];
    
    self.transitionType = TransitionTypeCrossFade;
    
    
    //AVMutableAudioMix *audioMix = nil;
    //CALayer *animatedTitleLayer = nil;
    
    
    
    // No transition selected; generates the default composition
    if (self.transitionType == TransitionTypeNone)
    {
        // No transitions: place clips into one video track and one audio track in composition.
        
        return [self spliceAssets:takes];
    }
    else
    {
        // With transitions:
        // Place clips into alternating video & audio tracks in composition, overlapped by transitionDuration.
        // Set up the video composition to cycle between "pass through A", "transition from A to B",
        // "pass through B", "transition from B to A".
        
        //videoComposition = [AVMutableVideoComposition videoComposition];
        return [self buildTransitionComposition:takes];
    }
    //return [self spliceAssets:takes];
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

    
    for (int i=0; i<self.videoClips.count; i++)
    {
        AVAsset *asset = [self.videoClips[i] copy];
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

        self.videoComposition.renderSize = assetTrack_video.naturalSize;
        
        self.videoComposition.renderScale = 1.0;
        
        
   

    }
    
    return self.composition;
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



   
}
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
         
         
// existing asset -> audio+video asset tracks -> add to  MutableComposition
// put in some controller class
- (void) exportVideoComposition:(AVAsset*)composition
{
    // 5 - Create exporter
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPreset1920x1080];
    
    exporter.outputURL = [self createOutputURL];
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = self.videoComposition;
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

- (void) addURLToMergedVideosArray:(NSURL*)url
{
    if (!self.compositions)
    {
        self.compositions = [NSMutableArray array];
    }
    [self.compositions addObject:url];
    
}

- (NSURL*) createOutputURL
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"auditionVideo-%d.mov",arc4random() % 1000]];
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
  
    [self addURLToMergedVideosArray:url];
    return url;
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
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"videoMergingCompletedNotification" object:nil];
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
    else if (session.status == AVAssetExportSessionStatusFailed)
    {
        NSLog(@"EPIC FAIL");
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





@end
