//
//  MediaLibrary.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-25.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Scene.h"
#import "Take.h"

@interface VideoLibrary : NSObject <NSCoding>

@property (nonatomic, strong) NSMutableArray *scenes;

+ (instancetype)libraryWithFilename:(NSString*)filename;

-(void)saveToFilename:(NSString *)filename;
-(void) addScene:(Scene*)newScene;
-(NSArray *)listFileAtPath:(NSString *)path;
- (void) deleteTake:(Take*)take fromSceneAtIndex:(NSInteger)sceneIndex;
- (NSString*) documentsDirectory;
@property (nonatomic, copy) void (^completionBlock)(BOOL);


@end
