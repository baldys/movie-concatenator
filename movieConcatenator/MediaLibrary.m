//
//  MediaLibrary.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-25.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "MediaLibrary.h"
#import "Scene.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>


@interface MediaLibrary ()

- (void) buildMediaLibrary;
- (void) buildAssetLibrary;
- (void) buildApplicationBundleLibrary;

- (void)addURL:(NSURL *)url;


//@property(nonatomic, strong) NSMutableArray *assetItems;
@property(readonly, unsafe_unretained) dispatch_queue_t assetItemsQueue;

@property(readonly, unsafe_unretained) dispatch_group_t libraryGroup;
@property(readonly, unsafe_unretained) dispatch_queue_t libraryQueue;

@end

@implementation MediaLibrary

-(instancetype)init {
    if (self = [super init]) {
        ///
        self.scenes = [[NSMutableArray alloc] init];
        ///
    }
    return self;
}

// LOAD
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.scenes = [[aDecoder decodeObjectForKey:@"scenes"] mutableCopy];
        if (!self.scenes) {
            self.scenes  = [[NSMutableArray alloc] init];
        }
        
    }
    return self;
}

// SAVE
- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.scenes forKey:@"scenes"];
}

+ (instancetype)libraryWithFilename:(NSString*)filename
{
    // 4 - Get path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs = [documentsDirectory stringByAppendingPathComponent:filename];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:myPathDocs];
}


-(void)saveToFilename:(NSString *)filename
{
    NSString *myPathDocs =  [[self documentsDirectory] stringByAppendingPathComponent:filename];
    [NSKeyedArchiver archiveRootObject:self toFile:myPathDocs];
}


- (NSString*) documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

// // TODO: put into video model class so that for each video, you can retrieve the url path that 
- (NSURL*) getPathURL
{
    // 4 - Get path
    // generate a random filename for the movie
    
    NSString *myPathDocs =  [[self documentsDirectory ]stringByAppendingPathComponent:[NSString stringWithFormat:@"take-%d.mov",arc4random() % 1000]];
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    return url;
}



+ (BOOL)saveMovieAtPathToAssetLibrary:(NSURL *)path withCompletionHandler:(void (^)(NSError *))completionHandler
{
    // Write a movie back to the asset library so it can be viewed by other apps
    BOOL success = YES;
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    [assetLibrary writeVideoAtPathToSavedPhotosAlbum:path completionBlock:^(NSURL *assetURL, NSError *error){
        if (error != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(error);
            });
        }
        else
        {
            NSError *removeError = nil;
            [[NSFileManager defaultManager] removeItemAtURL:path error:&removeError];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(error);
            });
        }
    }];
    
    return success;
}



@end
