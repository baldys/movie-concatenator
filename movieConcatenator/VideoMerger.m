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


@property (nonatomic, strong) NSMutableArray *layerInstructions;

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
-(AVAsset*)spliceAssets: (NSArray*)takes
{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"videoMergingStartedNotification" object:nil];
    
    // creating the composition
    

    //keep track of CMTime *timer;
    // timer = duration of the previous asset/assetTrack
    // = initial point in time to insert the next asset
    BOOL isFrontFacingVideoInAssets = NO;
    
    
    self.composition = [[AVMutableComposition alloc] init];
    
    AVMutableCompositionTrack *compositionTrack_video = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *compositionTrack_audio = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    self.videoComposition = [AVMutableVideoComposition videoComposition];

    CMTime timer = kCMTimeZero;
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionTrack_video];

    //NSMutableArray *assets = [NSMutableArray array];
    //NSMutableArray *compositionInstructions = [NSMutableArray array];
    //t1 = CGAffineTransformMakeRotation(degreesToRadians(180));
    //t2 = CGAffineTransformMakeTranslation(1280,720);
    //CGAffineTransform A = CGAffineTransformIdentity;
    //A = CGAffineTransformConcat(t1,t2);
    
    //so we can adjust the video size according to the smallest video in the sequence, so we dont crop large portions of the large videos or have black bars around the small videos.
    CGSize currentVideoSize;
    CGSize previousVideoSize = CGSizeMake(0, 0);
    
    int i = 0;
    
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
    return self.composition;


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
         
         
         
// existing asset -> audio+video asset tracks -> add to  MutableComposition
// put in some controller class
- (void) exportVideoComposition:(AVAsset*)composition
{
    // 5 - Create exporter
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    
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
    if (!self.videoClips)
    {
        self.videoClips = [NSMutableArray array];
    }
    [self.videoClips addObject:url];
    
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
}





@end
