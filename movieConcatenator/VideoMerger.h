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

//- (IBAction)loadVideo1:(id)sender;
//
//- (IBAction)loadVideo2:(id)sender;

-(AVAsset*)spliceAssets: (NSArray*)takes;

//- (void)concatenateAssets:(NSMutableArray*)assetArray;

-(void) exportVideoComposition:(AVAsset*)composition;

//-(BOOL) startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate;

-(void) exportDidFinish:(AVAssetExportSession*)session;



@end
