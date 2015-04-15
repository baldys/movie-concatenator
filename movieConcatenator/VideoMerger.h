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

@property (nonatomic, strong) NSMutableArray *mergedMovies;
-(AVAsset*)spliceAssets: (NSArray*)takes;

-(void) exportVideoComposition:(AVAsset*)composition;

//-(BOOL) startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate;

-(void) exportDidFinish:(AVAssetExportSession*)session;

@end
