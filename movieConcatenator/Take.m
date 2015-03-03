//
//  RONVideo.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-23.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//
/*

 
 @property (nonatomic) NSInteger takeNumber;
 
 @property (nonatomic) NSInteger assetID;
 
 @property (nonatomic, strong) NSDate *timeStamp;
 
 @property (nonatomic, getter=isSelected) BOOL *selected;
*/


#import "Take.h"
#import "MediaLibrary.h"


@interface Take ()


@property(readonly, unsafe_unretained) dispatch_once_t thumbnailToken;

@end
@implementation Take



- (instancetype) initWithURL:(NSURL*)url
{
    self = [super init];
    if(self)
    {
        self.assetID = [[NSUUID UUID] UUIDString];
        NSLog(@"%@", self.assetID);
        

        NSURL *toUrl = [self getPathURL];
        NSLog(@"%@", toUrl);

        self.assetFileURL = toUrl;
        
        NSError *error = nil;
        if (![[NSFileManager defaultManager]copyItemAtURL:url toURL:toUrl error:&error])
        {
            NSLog(@"file copy error %@", error);
        }
       
        self.asset = [AVAsset assetWithURL:toUrl];
        self.imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self.asset];
        //self.thumbailImg = [UIImage imageNamed: @"movie-1"];
        
        //self.asset = nil;
        //self.assetURL = url;
        
        //thumbnailImageAtTime
        
    }
    return self;
}


- (NSURL*) getPathURL
{
    // 4 - Get path
    // generate a random filename for the movie
    
    NSString *myPathDocs =  [[self documentsDirectory ]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",self.assetID]];
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    return url;
}

- (NSString*) documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}


// LOAD
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        ///self.assetURL = ppath name + assetid.file ext
        self.takeNumber = [aDecoder decodeIntegerForKey:@"takeNumber"];
        self.assetID = [aDecoder decodeObjectForKey:@"assetID"];
        self.timeStamp = [aDecoder decodeObjectForKey:@"timeStamp"];
        self.selected = [aDecoder decodeBoolForKey:@"selected"];
        
    }
    return self;
}
// SAVE
- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.takeNumber forKey:@"takeNumber"];
    [aCoder encodeObject:self.assetID forKey:@"assetID"];
    [aCoder encodeObject:self.timeStamp forKey:@"timeStamp"];
    [aCoder encodeBool:self.selected forKey:@"selected"];
    
}

- (NSArray*) videoaAssetTracks
{
    
    AVAssetTrack *assetVideoTrack = nil;
    AVAssetTrack *assetAudioTrack = nil;
    // Check if the asset contains video and audio tracks
    if ([[self.asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        assetVideoTrack = [self.asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    if ([[self.asset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
        assetAudioTrack = [self.asset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    
    
    NSError *error = nil;
    
   
    //AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *audioAssetTrack = [[self.asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    //[audioAssetTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.firstAsset.duration) ofTrack:firstAssetTrack atTime:kCMTimeZero error:nil];
    AVAssetTrack *videoAssetTrack = [[self.asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
    NSArray *assetTracks = [NSArray arrayWithObjects:audioAssetTrack, videoAssetTrack, nil];
    return assetTracks;
}


- (void) createCompositionWithAudioAndVideoTracks
{
    AVMutableComposition *composition = [AVMutableComposition composition];
}

// Load the first frame of the video for a thumbnail
- (UIImage *)loadThumbnailWithCompletionHandler:(void (^)(UIImage *))completionHandler
{
    __unsafe_unretained __block Take *weakSelf = (Take *)self;
    
    dispatch_once(&_thumbnailToken, ^{
        [self.imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:kCMTimeZero]] completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
            if (result == AVAssetImageGeneratorSucceeded)
            {
                weakSelf.thumbailImg = [UIImage imageWithCGImage:image];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Loaded thumbnail for %@", weakSelf.assetID);
                    completionHandler(weakSelf.thumbailImg);
                });
            }
            else if (result == AVAssetImageGeneratorFailed)
            {
                NSLog(@"couldn't generate thumbnail, error:%@", error);
            }
        }];
    });
    
    return weakSelf.thumbailImg;

}

@end
