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
#import "VideoLibrary.h"
#import "UIImage+Extras.h"

@interface Take () //<AVAsynchronousKeyValueLoading>

@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong) AVAsset *videoAsset;
@property(readonly, unsafe_unretained) dispatch_once_t thumbnailToken;

@end

@implementation Take

- (instancetype) initWithURL:(NSURL*)url
{
    self = [super init];
    if(self)
    {
        // create a unique identifier for the take so
        // it can be stored in the file system and retreived

        self.assetID = [[NSUUID UUID] UUIDString];
        
        _assetURL = [self getPathURL];
        
        NSLog(@"%@", self.assetID);
        
        NSLog(@"url to copy from for the take: %@", url);
        NSLog(@"path url for the take _assetURL %@", _assetURL);
        
        NSError *error = nil;
        if (![[NSFileManager defaultManager]moveItemAtURL:url toURL:self.assetURL error:&error])
        {
            NSLog(@"file copy error %@", error);
        }
        
       
        _videoAsset = [[AVURLAsset alloc] initWithURL:self.assetURL options:nil];
        
        _selected = NO;
        
        //_imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:_videoAsset];
    
        //;

        ///// load lazily instead in collection view cell subclass.
        
        ////// to make this work must add ::
        
     [self loadThumbnailWithCompletionHandler:^(UIImage *image){
//    
            self.thumbnail = [image imageByScalingProportionallyToSize:CGSizeMake(120, 80)];
         //CGRect screenRect = [UIScreen mainScreen].bounds;
         //screenRect.size.
            self.thumbnail = image;
      }];
        
        
        if (_thumbnail == nil)
        {
            _thumbnail = [UIImage imageNamed:@"vid.png"];
        }
        
        
        //[self getThumbnailImage];
        
    }
    return self;
}

- (AVAsset*) createAssetItem
{
    if (!self.assetItem)
    {
        self.assetURL = [self getPathURL];
        self.assetItem = [AVAsset assetWithURL:self.assetURL];
        
    }
    return self.assetItem;
}


// get the file url of the take or create one if it doesn't exist in the documents directory named by its randomly generated uuid.
- (NSURL*) getPathURL
{
    // 4 - Get path
    // generate a random filename for the movie
    
    NSString *myPathDocs =  [[self documentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",self.assetID]];
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    return url;
}

- (NSString*) documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (void) createGeneratorFromItemInFilePathURL
{
    if (!_videoAsset)
    {
        
        _videoAsset = [[AVURLAsset alloc] initWithURL:[self getPathURL] options:nil];

        
    }
    if (!_imageGenerator)
    {
        self.imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:_videoAsset];
    }
    self.imageGenerator.appliesPreferredTrackTransform = YES;
}
// LOAD
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        ///self.assetURL = ppath name + assetid.file ext
        self.sceneNumber = [aDecoder decodeIntegerForKey:@"sceneNumber"];
        //NSLog(@"take number %@", self.takeNumber)
        self.assetID = [aDecoder decodeObjectForKey:@"assetID"];
        //self.timeStamp = [aDecoder decodeObjectForKey:@"timeStamp"];
        //[self createGeneratorFromItemInFilePathURL];
        //self.selected = [aDecoder decodeBoolForKey:@"selected"];
        //NSData *imageData = [aDecoder decodeObjectForKey:@"thumbnailImgData"];
//        NSData *imageData = [aDecoder decodeObjectForKey:@"thumbnail"];
//        self.thumbnail = [UIImage imageWithData:imageData];
//        NSLog(@"\n\n\n\n>>>>%@\n\n\n\n\n\n", [aDecoder decodeObjectForKey:@"assetFileURL"]);
//        

            
        
    }
    return self;
}
// SAVE
- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.sceneNumber forKey:@"sceneNumber"];
    [aCoder encodeObject:self.assetID forKey:@"assetID"];
    //[aCoder encodeObject:self.timeStamp forKey:@"timeStamp"];
    //[aCoder encodeBool:self.selected forKey:@"selected"];
    //[aCoder encodeObject:UIImagePNGRepresentation(self.thumbnail) forKey:@"thumbnail"];
}
//
//- (NSArray*) videoaAssetTracks
//{
//    
//    AVAssetTrack *assetVideoTrack = nil;
//    AVAssetTrack *assetAudioTrack = nil;
//    // Check if the asset contains video and audio tracks
//    if ([[self.asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
//        assetVideoTrack = [self.asset tracksWithMediaType:AVMediaTypeVideo][0];
//    }
//    if ([[self.asset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
//        assetAudioTrack = [self.asset tracksWithMediaType:AVMediaTypeAudio][0];
//    }
//    
//    //AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//    AVAssetTrack *audioAssetTrack = [[self.asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
//    //[audioAssetTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.firstAsset.duration) ofTrack:firstAssetTrack atTime:kCMTimeZero error:nil];
//    AVAssetTrack *videoAssetTrack = [[self.asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
//    NSArray *assetTracks = [NSArray arrayWithObjects:audioAssetTrack, videoAssetTrack, nil];
//    return assetTracks;
//}
//

//Load the first frame of the video for a thumbnail
- (UIImage*)loadThumbnailWithCompletionHandler:(void (^)(UIImage*))completionHandler
{
   [self createGeneratorFromItemInFilePathURL];
    __weak __block Take *weakSelf = (Take *)self;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
    ^{
        
        [weakSelf.imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:kCMTimeZero]]completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error)
        {
              if (result == AVAssetImageGeneratorSucceeded)
              {
                  weakSelf.thumbnail = [UIImage imageWithCGImage:image];
                  
                  dispatch_async(dispatch_get_main_queue(),
                  ^{
                      NSLog(@"Loaded thumbnail");
                      
                       completionHandler(weakSelf.thumbnail);
                  });
              }
              else if (result == AVAssetImageGeneratorFailed)
              {
                  NSLog(@"couldn't generate thumbnail, error:%@", error);
              }
        }];
    });
    return self.thumbnail;
}

@end
