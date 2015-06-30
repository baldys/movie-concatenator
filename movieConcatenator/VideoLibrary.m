//
//  MediaLibrary.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-25.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "VideoLibrary.h"

@interface VideoLibrary ()

//- (void) buildMediaLibrary;
//- (void) buildAssetLibrary;
//- (void) buildApplicationBundleLibrary;
//
//- (void)addURL:(NSURL *)url;


//@property(nonatomic, strong) NSMutableArray *assetItems;
//@property(readonly, unsafe_unretained) dispatch_queue_t assetItemsQueue;
//
//@property(readonly, unsafe_unretained) dispatch_group_t libraryGroup;
//@property(readonly, unsafe_unretained) dispatch_queue_t libraryQueue;

@end

@implementation VideoLibrary

+ (instancetype)sharedVideoLibrary
{
    static dispatch_once_t pred;
    static VideoLibrary *foo = nil;
    
    dispatch_once(&pred, ^{
        foo = [[self alloc] init];
    });
    return foo;
}
//+(VideoLibrary *)videoLibrary{
//    static dispatch_once_t pred;
//    static VideoLibrary *sharedVideoLibrary = nil;
//    dispatch_once(&pred, ^{
//        sharedVideoLibrary = [[self alloc] init];
//    });
//    return sharedVideoLibrary;
//}


//+(VideoLibrary *)sharedLibrary {
//    static dispatch_once_t pred;
//    static VideoLibrary *videoLibrary = nil;
//    dispatch_once(&pred, ^{
//        videoLibrary = [[VideoLibrary alloc] init];
//        videoLibrary.takesToConcatenate = [[NSMutableArray alloc]init];
//    });
//    return videoLibrary;
//}


// use a shared scenes array instead (make it a singleton)
-(instancetype)init {
    if (self = [super init])
    {
    
        if (!self.scenes)
        {
            self.scenes = [NSMutableArray array];
        }
        if (!self.editedVideoURLs)
        {
            self.editedVideoURLs = [NSMutableArray array];
        }
       
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
        self.editedVideoURLs = [[aDecoder decodeObjectForKey:@"editedVideoURLs"]mutableCopy];
        
        
        
    }
    return self;
}

// SAVE
- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.scenes forKey:@"scenes"];
    [aCoder encodeObject:self.editedVideoURLs forKey:@"editedVideoURLs"];
}

- (void) addURLToEditedVideos:(NSURL*)url
{
    [self.editedVideoURLs addObject:url];
    // __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            [self saveToFilename:@"VideoDatalist.plist"];
    });
    
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

- (void) addScene:(Scene*)newScene
{
    NSLog(@" adding a scene with title: %@", newScene.title);
    // __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        [self.scenes addObject:newScene];
        newScene.libraryIndex = self.scenes.count;
        [self saveToFilename:@"VideoDatalist.plist"];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completionBlock(YES);
        });
        
        
    });
}





-(NSArray *)listFileAtPath:(NSString *)path
{
    //-----> LIST ALL FILES <-----//
    NSLog(@"LISTING ALL FILES FOUND");
    
    int count;
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    }
    
    return directoryContent;
}


- (NSMutableArray*) selectedTakes
{
    //NSMutableArray *selectedTakes = [NSMutableArray array];
    if (!_takesToConcatenate)
    {
        _takesToConcatenate = [[NSMutableArray alloc] init];
    }
    
    for (Scene *scene in self.scenes)
    {
        for (Take *take in scene.takes)
        {
            if (take.isSelected)
            {
                NSLog(@"TAKE URL %@ ", [take getFileURL]);
                [_takesToConcatenate addObject:take];
            }
        }
    }
    
    
    return _takesToConcatenate;
}


- (void) deleteTake:(Take*)take fromSceneAtIndex:(NSInteger)sceneIndex
{
    for (Scene *scene in self.scenes)
    {
        NSLog(@"SCENES IN LIBRARY Scene title: %@", scene.title );
    }

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
//                   ^{
//
//        
//    })
    NSLog(@"delete take was called");
    if ([[NSFileManager defaultManager] fileExistsAtPath:[take getFileURL].path])
    {
        NSLog(@"Take to delete: %@", [take getFileURL].path);
        NSError *error = nil;
        if (![[NSFileManager defaultManager]removeItemAtURL:[take getFileURL] error:nil])
        {
            NSLog(@"Error deleting file: %@",error);
        }
        else
        {
            NSLog(@"removed take - scene number: %ld", (long)take.sceneNumber);
            Scene *scene = [self.scenes objectAtIndex:take.sceneNumber];
            [scene.takes removeObject:take];
            //[[self.scenes objectAtIndex:take.sceneNumber].takes removeObject:take];
            [self saveToFilename:@"VideoDatalist.plist"];
        }
        //[[NSFileManager defaultManager] removeItemAtPath:[take getPathURL].path error:&error];
//
//        if (error)
//        {
//            NSLog(@"Error deleting file: %@",error);
//            
//        }
        
        
    }

}


////////////////
// // TODO: put into video model class so that for each video, you can retrieve the url path that

/*
- (NSURL*) getPathURL
{
    // 4 - Get path
    // generate a random filename for the movie
    
    NSString *myPathDocs =  [[self documentsDirectory ]stringByAppendingPathComponent:[NSString stringWithFormat:@"take-%d.mov",arc4random() % 1000]];
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    return url;
}
*/

/*
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
*/


@end
