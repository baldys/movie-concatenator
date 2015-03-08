//
//  VideoMerger.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-03.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "VideoMerger.h"

@implementation VideoMerger



//interpret the takes to access all tracks

//for each asset in takes {
//add asset tracks to video track
//add audio track for audio track
//timer = CMTimeAdd(timer, asset.duration)
//}

//log timer, log mutablecomposition.tracks

//make avasset from avmutablecomposition (is an avasset)

-(AVAsset*)spliceAssets: (NSArray*)takes
{
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    AVMutableCompositionTrack *compositionTrack1_video = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *compositionTrack1_audio = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];

    //keep track of CMTime *timer;
    CMTime timer = kCMTimeZero;
    
    NSMutableArray *assets = [NSMutableArray array];
    
    for (Take* take in takes)
    {
        [assets addObject:[AVAsset assetWithURL:[take getPathURL]]];
    }
 
    for (AVAsset* asset in assets) {
        //add video from asset to track
        //NSLog(@"[asset tracksWithMediaType:AVMediaTypeVideo].count: %lu", (unsigned long)[asset tracksWithMediaType:AVMediaTypeVideo].count) ;
        AVAssetTrack *assetTrack1_video = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        AVAssetTrack *assetTrack1_audio = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        [compositionTrack1_video insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetTrack1_video atTime:timer error:nil];
        // audio audio from asset to track
        [compositionTrack1_audio insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetTrack1_audio atTime:timer error:nil];
        timer = CMTimeAdd(timer, asset.duration);
    }
    
    AVMutableVideoCompositionLayerInstruction *firstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionTrack1_video];
    [firstlayerInstruction setOpacity:1.0 atTime:kCMTimeZero];
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, timer);
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:firstlayerInstruction, nil];
    
    self.mainComposition = [AVMutableVideoComposition videoComposition];
    
    self.mainComposition.instructions = [NSArray arrayWithObject:mainInstruction];
    self.mainComposition.frameDuration = CMTimeMake(1, 30);
    self.mainComposition.renderSize = CGSizeMake(320.0, 480.0);
    
    //NSLog(@"timer scale, value: %d %lld", timer.timescale, timer.value);
    //expecting positive values
    //NSLog(@"mixComposition properties: %@", mixComposition.debugDescription);
    
    
    return mixComposition;
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
- (void) exportVideoComposition:(AVAsset*)composition
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
