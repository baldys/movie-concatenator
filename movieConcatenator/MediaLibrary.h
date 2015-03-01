//
//  MediaLibrary.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-25.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaLibrary : NSObject <NSCoding>

@property (nonatomic, strong) NSMutableArray *scenes;


+ (instancetype)libraryWithFilename:(NSString*)filename;

-(void)saveToFilename:(NSString *)filename;

@end
