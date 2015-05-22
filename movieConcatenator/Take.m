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

- (void)loadDurationOfAsset:(AVAsset*)asset
{
    
    NSString *durationKey = @"duration";
    __weak __block Take *weakSelf = (Take *)self;
    [asset loadValuesAsynchronouslyForKeys:@[durationKey] completionHandler:
     ^{
         NSError *error = nil;
         switch ([asset statusOfValueForKey:@"duration" error:&error])
         {
                 
             case AVKeyValueStatusLoaded:
                 // duration is now known, so we can fetch it without blocking
                 //CMTime duration = [asset valueForKey:@"duration"];
                 //CMTime duration = [asset duration];
                 
                 weakSelf.duration = [asset duration];
                 
                 float seconds = _duration.value/_duration.timescale;
                 
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     NSLog(@"duration of take loaded: time in seconds:%f", seconds);
                 });
                 
                 break;
             default:
                 _duration = kCMTimeInvalid;
                 break;
         }
         //// completion block
         
     }];
    
    
    float seconds = _duration.value/_duration.timescale;
    int minutes = 0;
    
    

    while (seconds-60 > 0)
    {
        minutes++;
        seconds = seconds-60;
    }
        
    
    NSLog(@"Minutes:seconds = %i:%f", minutes, seconds);
    self.durationInSeconds = [NSString stringWithFormat:@"%i:%f",minutes, seconds];
    
}
- (instancetype) initWithURL:(NSURL*)url
{
    self = [super init];
    if(self)
    {
        // create a unique identifier for the take so
        // it can be stored in the file system and retreived
        self.assetID = [[NSUUID UUID] UUIDString];
        
        _assetURL = [self getFileURL];
        
        NSError *error = nil;
        if (![[NSFileManager defaultManager]moveItemAtURL:url toURL:self.assetURL error:&error])
        {
            NSLog(@"file copy error %@", error);
        }
        self.videoOrientation = @"unknown";
        self.videoRecordingPosition = @"unknown";
        
       NSDictionary *options = @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES };
        _videoAsset = [[AVURLAsset alloc] initWithURL:self.assetURL options:options];
        
        _selected = NO;
        
        //_imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:_videoAsset];
    
        [self loadDurationOfAsset:_videoAsset];
        
        self.timeRange = CMTimeRangeMake(kCMTimeZero, self.duration);
        
        [self loadThumbnailWithCompletionHandler:^(UIImage *image)
        {
            self.thumbnail = [image imageByScalingProportionallyToSize:CGSizeMake(120, 80)];
            CGFloat screenScale = [UIScreen mainScreen].scale;
            NSLog(@"scale: %f", screenScale);
            //screenRect.size.
            self.thumbnail = image;
        }];
            
        
        if (_thumbnail == nil)
        {
            _thumbnail = [UIImage imageNamed:@"vid.png"];
        }
    }
    return self;
}





//- (BOOL) videoOrientationLandscapeLeft
//{
//    if ([self.videoOrientation isEqualToString:@"Landscape Left"])
//    {
//        return YES;
//    }
//    return NO;
//}
//
//- (BOOL) videoCameraFacingBack
//{
//    if ([self.videoRecordingPosition isEqualToString:@"Back"])
//    {
//        return YES;
//    }
//    return NO;
//}

- (AVAsset*) createAssetItem
{
    if (!self.assetItem)
    {
        self.assetURL = [self getFileURL];
        self.assetItem = [AVAsset assetWithURL:self.assetURL];
        
    }
    return self.assetItem;
}


// get the file url of the take or create one if it doesn't exist in the documents directory named by its randomly generated uuid.
- (NSURL*) getFileURL
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
        _videoAsset = [[AVURLAsset alloc] initWithURL:[self getFileURL] options:nil];
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
        self.videoOrientationAndPosition = [aDecoder decodeIntegerForKey:@"videoOrientationAndPosition"];
        self.sceneTitle = [aDecoder decodeObjectForKey:@"sceneTitle"];
        self.title = [aDecoder decodeObjectForKey:@"title" ];
        self.duration = [aDecoder decodeCMTimeForKey:@"duration"];
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
    [aCoder encodeInteger:self.videoOrientationAndPosition forKey:@"videoOrientationAndPosition"];
    [aCoder encodeObject:self.sceneTitle forKey:@"sceneTitle"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeCMTime:self.duration forKey:@"duration"];
    [aCoder encodeCMTimeRange:self.timeRange forKey:@"timeRange"];
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
