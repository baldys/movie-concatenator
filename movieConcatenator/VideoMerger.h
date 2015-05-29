//
//  VideoMerger.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-03.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import "VideoLibrary.h"
#import "Scene.h"
#import "Take.h"

typedef NS_ENUM(NSInteger, TransitionType)
{
    TransitionTypeNone      = 0,
    TransitionTypeCrossFade = 1,
    TransitionTypePush      = 2
};

@interface VideoMerger : NSObject

@property (nonatomic) NSInteger transitionType;

@property (nonatomic, strong) AVMutableComposition *composition;

@property (nonatomic, strong) AVMutableVideoComposition *videoComposition;

@property (nonatomic, strong) NSArray *videoClips;
@property (nonatomic, strong) NSMutableArray *clipTimeRanges; // array of CMTimeRanges stored in NSValues.
@property (nonatomic, strong) NSMutableArray *compositions;

@property (nonatomic) CMTime transitionDuration;
@property (nonatomic, strong) VideoLibrary *videoLibrary;

-(AVAsset*)spliceAssets: (NSArray*)takes;
-(AVAsset*)buildCompositionObjects:(NSArray*)takes;
-(void) exportTrimmedTake:(Take*)take;
-(void) exportVideoComposition:(AVAsset*)composition;

//-(BOOL) startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate;

-(void) exportDidFinish:(AVAssetExportSession*)session;

@end
