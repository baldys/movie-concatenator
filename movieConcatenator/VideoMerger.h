//
//  VideoMerger.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-03.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Scene.h"
#import "Take.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>

@interface VideoMerger : NSObject


@property (nonatomic, strong) AVMutableComposition *mixComposition;
@property (nonatomic, strong) AVMutableVideoComposition *mainComposition;
//@property (nonatomic, strong) AVMutableVideoCompositionInstruction *videoCompositionInstruction;
// contains layer instructions for each video asset/composirtion
//@property (nonatomic, strong) NSMutableArray *videoCompositionLayerInstructions;


//- (IBAction)loadVideo1:(id)sender;
//
//- (IBAction)loadVideo2:(id)sender;

- (void)concatenateAssets:(NSMutableArray*)assetArray;

- (void)appendAsset:(AVAsset*)asset2 toPreviousAsset:(AVAsset*)asset1;

-(void) exportVideoComposition:(AVMutableComposition*)composition;

-(BOOL) startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate;

-(void) exportDidFinish:(AVAssetExportSession*)session;


- (AVMutableComposition*) appendAsset:(AVAsset *)asset ToComposition:(AVMutableComposition*)composition;

@end
