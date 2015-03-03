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
//#import <MediaLibrary/MediaLibrary.h>
#import <UIKit/UIKit.h>

@interface Take : NSObject <NSCoding>

@property (nonatomic, strong) NSURL *assetFileURL;

@property (nonatomic) NSInteger takeNumber;

@property (nonatomic, strong) NSString* assetID;

@property (nonatomic, strong) NSDate *timeStamp;

@property (nonatomic, getter=isSelected) BOOL selected;

@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;

@property (nonatomic, strong) AVAsset *asset;

@property (nonatomic, strong) UIImage *thumbailImg;

//@property (nonatomic,strong) CMTi

// save todocuments directory (get the path of the folder and create a new empty file with the assetID.file_extension (i.e. .mp4 or .mov)c

//- (void) saveToFile:



//- (void) loadMedia:AV


@property AVMutableComposition *mutableComposition;
@property AVMutableVideoComposition *mutableVideoComposition;
@property AVMutableAudioMix *mutableAudioMix;
@property (nonatomic) CMTime *insertionPoint;

//@property (nonatomic, strong) AVMutableVideoComposition *videoComposition;
//@property (nonatomic, strong) AVMutableAudioMix *audioMix;
@property (nonatomic, strong) NSArray *assetTracks;

//TODO: each RON video has a beginning cut in time (CMTime), cut out time (CMTime)
//OR CMTimeRange
//additional feature


- (instancetype) initWithURL:(NSURL *)url;

- (NSArray*)assetTracks;
//TODO: split into two.
//- (AVAssetTrack*)videoAssetTrack;
//- (AVAssetTrack*)audioAssetTrack;

//@property (nonatomic, strong) AVAssetTrack *videoAsset

- (NSURL*)getPathURL;
- (NSString*) documentsDirectory;

- (UIImage *)loadThumbnailWithCompletionHandler:(void (^)(UIImage *))completionHandler;

@end
