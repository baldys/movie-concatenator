//
//  VideoLibrary.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-25.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Scene.h"
#import "Take.h"
@class TakeCollectionViewCell;
@interface VideoLibrary : NSObject <NSCoding>

@property (nonatomic, strong) NSMutableArray *scenes;

+ (instancetype)sharedVideoLibrary;
@property (nonatomic, strong) NSMutableArray *takesToConcatenate;
@property (nonatomic, strong) NSMutableArray *editedVideoURLs;

@property (nonatomic, strong) NSMutableArray *videoCompositions;

+ (instancetype)libraryWithFilename:(NSString*)filename;

-(void)saveToFilename:(NSString *)filename;
-(void) addScene:(Scene*)newScene;
-(NSArray *)listFileAtPath:(NSString *)path;
- (void) deleteTake:(Take*)take fromSceneAtIndex:(NSInteger)sceneIndex;
- (NSString*) documentsDirectory;

- (void) addURLToEditedVideos:(NSURL*)url;

- (void) addVideoCompositionWithURL:(NSURL*)url;
@property (nonatomic, copy) void (^completionBlock)(BOOL);

- (NSMutableArray*)selectedTakes;
@end
