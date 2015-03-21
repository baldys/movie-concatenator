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

@interface Take : NSObject <NSCoding>

//@property (nonatomic) NSInteger takeNumber;

@property (nonatomic) NSInteger sceneNumber;

@property (nonatomic, strong) NSString* assetID;

@property (nonatomic, getter=isSelected) BOOL selected;

@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;

@property (nonatomic, strong) AVAsset *asset;

@property (nonatomic, strong) UIImage *thumbailImg; //TODO: make a custom getter that generates thumbnails lazily if they do not exist...

@property (nonatomic, strong) NSData *imageData;

// save todocuments directory (get the path of the folder and create a new empty file with the assetID.file_extension (i.e. .mp4 or .mov)c

//- (void) saveToFile:

@property AVMutableComposition *mutableComposition;
@property AVMutableVideoComposition *mutableVideoComposition;
@property AVMutableAudioMix *mutableAudioMix;
@property (nonatomic) CMTime *insertionPoint;

//@property (nonatomic, strong) NSArray *assetTracks;

- (instancetype) initWithURL:(NSURL *)url;

//- (NSArray*)assetTracks;


- (NSURL*)getPathURL;
- (NSString*) documentsDirectory;

- (UIImage *)loadThumbnailWithCompletionHandler:(void (^)(UIImage *))completionHandler;

@end
