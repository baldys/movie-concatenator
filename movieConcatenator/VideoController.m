//
//  VideoController.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-24.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "VideoController.h"

@interface VideoController ()

@property (nonatomic, strong) NSMutableArray *videoArray;

@end

@implementation VideoController

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        self.videoArray = [[NSMutableArray alloc] init];
    }
    return self;
    
}

+ (VideoController*) sharedVideoManager
{
    static VideoController *videoManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
    ^{
        //sharedVideoController = [[self alloc] init];
      });
    return videoManager;


}

@end

