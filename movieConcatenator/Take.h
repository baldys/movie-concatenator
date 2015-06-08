//
//  RONVideo.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-23.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, VideoOrientationAndPosition)
{
    LandscapeLeft_Back = 0,
    LandscapeLeft_Front = 1,
    LandscapeRight_Back = 2,
    LandscapeRight_Front = 3,
};
typedef NS_ENUM(NSInteger, TransitionTypes)
{
    None = 0,
    Fade = 1,
    Push = 2
};

@interface Take : NSObject <NSCoding>

@property (nonatomic) NSInteger videoOrientationAndPosition;

@property (nonatomic) NSInteger transitionType;

@property (nonatomic) NSInteger sceneNumber;
@property (nonatomic, strong) NSString *sceneTitle;
@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString* assetID;
@property (nonatomic, strong) NSURL *assetURL;

@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic) CMTime duration;
@property (nonatomic) CMTimeRange timeRange;
@property (nonatomic, strong) NSString *durationString;

//./././.
@property (nonatomic, strong) NSString *videoRecordingPosition;
@property (nonatomic, strong) NSString *videoOrientation;
//./././.

@property (nonatomic, strong) AVAsset *assetItem;


@property (nonatomic, strong) UIImage *thumbnail;

- (AVAsset*)createAssetItem;
- (NSString*)durationString;
//- (NSURL*) thumbnailURL;

//- (void) saveToFile:

//@property AVMutableComposition *mutableComposition;
//@property AVMutableVideoComposition *mutableVideoComposition;
//@property AVMutableAudioMix *mutableAudioMix;
//@property (nonatomic) CMTime *insertionPoint;

//@property (nonatomic, strong) NSArray *assetTracks;

- (instancetype) initWithURL:(NSURL *)url;

//- (NSArray*)assetTracks;


- (NSURL*)getFileURL;
- (NSString*) documentsDirectory;
- (void)loadDurationOfAsset:(AVAsset*)asset withCompletionHandler:(void (^)(void))completionHandler;
- (UIImage *)loadThumbnailWithCompletionHandler:(void (^)(UIImage *))completionHandler;

@end
