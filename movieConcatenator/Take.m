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

- (void)loadDurationOfAsset:(AVAsset*)asset withCompletionHandler:(void (^)(void))completionHandler
{
    NSString *durationKey = @"duration";
    __weak __block Take *weakSelf = (Take *)self;
    [asset loadValuesAsynchronouslyForKeys:@[durationKey] completionHandler:
     ^{
         NSError *error = nil;
         if ([asset statusOfValueForKey:durationKey error:&error] == AVKeyValueStatusLoaded)
         {
             
                 //CMTime duration = [asset duration];
                 
            
             weakSelf.duration = [asset duration];
             
             
                 //Float64 seconds = weakSelf.duration.value/weakSelf.duration.timescale;
             double seconds = CMTimeGetSeconds(weakSelf.duration);
                 
            
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSLog(@"duration of take loaded: time in seconds:%.002f", seconds);
                 
                 completionHandler();
            });
         }
         else
         {
             NSLog(@"FAAAAAAIIILLLLLLLLLL");
         }
     }];
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
    
        [self loadDurationOfAsset:_videoAsset withCompletionHandler:^{
            
            float seconds = _duration.value/_duration.timescale;
            
            self.durationString = [self convertSecondsToString:_duration];
//            int minutes = 0;
//            while (seconds-60 > 0)
//            {
//                minutes++;
//                seconds = seconds-60;
//            }
//            
//            NSLog(@"Minutes:seconds = %i:%f", minutes, seconds);
//            self.durationString = [NSString stringWithFormat:@"%i:%.02f",minutes, seconds];
            self.timeRange = CMTimeRangeMake(kCMTimeZero, self.duration);
            
        }];
        
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


/// NONONONO THIS IS WRONG
- (NSString*)convertSecondsToString:(CMTime)seconds
{
    Float64 fseconds = _duration.value/_duration.timescale;
    
    CMTimeMakeWithSeconds(fseconds, NSEC_PER_MSEC);
    
    int minutes = 0;
    while (fseconds-60 > 0)
    {
        minutes++;
        fseconds = fseconds-60;
    }
    
    NSLog(@"Minutes:seconds = %i:%f", minutes, fseconds);
    return [NSString stringWithFormat:@"%i:%.02f",minutes, fseconds];
    
}


- (void)createTrimmedTakeWithCompletionHandler:(void (^)(NSURL* trimmedTakeURL))completionHandler
{
    // 1. create and name a url url in temp directory to put the copied video clip
//    NSString *filePath = NSTemporaryDirectory();
//    NSString *extension = @"mov";
//    NSString *fileNameNoExtension = [NSString stringWithFormat:@"trimmedTake%i", arc4random() % 1000];
//    filePath = [filePath stringByAppendingPathComponent:fileNameNoExtension];
//    filePath = [filePath stringByAppendingPathExtension:extension];
    //      NSURL *trimmedTakeURL = [NSURL fileURLWithPath:filePath];
    

    NSURL *tempURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"trimmedTake-%i.mov", arc4random() % 1000]]];

  
    // 2. copy the contents of this take at its url to save in a temp folder
//    NSError *error = nil;
//    [[NSFileManager defaultManager] copyItemAtURL:self.getFileURL toURL:trimmedTakeURL error:&error];
//
    // asset that will be a trimmed verson of the takes asset at its url
    AVAsset *assetToBeTrimmed = [AVURLAsset assetWithURL:self.getFileURL];
    
    // 4. export the new trimmed video with completion handler. on successful completion alloc and init a new take with its url set to the temp url
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:assetToBeTrimmed presetName:AVAssetExportPreset1920x1080];
    exporter.outputURL = tempURL;
    exporter.timeRange = self.timeRange;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    
    __weak __block Take* weakSelf = (Take*)self;
    __block BOOL success = NO;
    [exporter exportAsynchronouslyWithCompletionHandler:
     ^{
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            //[self exportDidFinish:exporter];
                            
                            if (exporter.status ==AVAssetExportSessionStatusCompleted)
                            {
                                success = YES;
                                
//                                Take *trimmedTake = [[Take alloc] initWithURL:exporter.outputURL];
//                                trimmedTake.sceneTitle = weakSelf.sceneTitle;
//                                trimmedTake.sceneNumber = weakSelf.sceneNumber;
//                                trimmedTake.videoOrientationAndPosition = weakSelf.videoOrientationAndPosition;
                                
                                //[[NSNotificationCenter defaultCenter] postNotificationName:@"trimmedVideoAtURL" object:exporter.outputURL];
                                completionHandler(exporter.outputURL);
                                
                                
                                
//                                NSError *error = nil;
//                                NSURL *oldURL = take.getFileURL;
//                                NSLog(@"take url: %@", take.getFileURL);
//                                NSURL *outputURL = exporter.outputURL;
//                                [[NSFileManager defaultManager] replaceItemAtURL:[take getFileURL] withItemAtURL:outputURL backupItemName:nil options:NSFileManagerItemReplacementUsingNewMetadataOnly resultingItemURL:&oldURL error:&error];
                                
                                
                            }
                        });
                        
//                                if (error)
//                                {
//                                    NSLog(@"%@", error);
//                                }
//                            else{
//                                    dispatch_async(dispatch_get_main_queue(),^{
//                                        completionHandler();
//                                        NSLog(@"Video has been trimmed and exported?");
//                                    });
                            
                            
                                
                                
                            
                            
                }];
    

    
    
    
}


// set some of its properties that need to be the same as the old one: like videoOrientation&position, scene number, scene title.
// return the new trimmed copied version of the take!
// now put the take into the correct scene and into the video library.. it has its scene index set as a property so do maybe do this in some other class
//

/* ON SUCCESSFUL/COMPLETE EXPORT OF TRIMMED ASSET:

 Take *trimmedTake = [Take alloc] initWithURL:exporter.outputURL
 
 */



- (AVAsset*) createAssetItem
{
    if (!self.assetItem)
    {
        self.assetURL = [self getFileURL];
        NSDictionary *options = @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES };
        self.assetItem = [[AVURLAsset alloc] initWithURL:self.assetURL options:options];
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
