//
//  MediaLibrary.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-25.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Take;

@interface VideoLibrary : NSObject <NSCoding>

@property (nonatomic, strong) NSMutableArray *scenes;

+ (instancetype)libraryWithFilename:(NSString*)filename;

-(void)saveToFilename:(NSString *)filename;

@property (nonatomic, strong) NSMutableArray *selectedVideos;

//- (id)initWithLibraryChangedHandler:(void (^)(void))libraryChangedHandler;

//- (void)loadLibraryWithCompletionBlock:(void (^)(void))completionHandler;

//+ (BOOL)saveMovieAtPathToAssetLibrary:(NSURL *)path withCompletionHandler:(void (^)(NSError *))completionHandler;

//- (NSURL*) getPathURL;

@end
