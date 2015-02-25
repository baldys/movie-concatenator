//
//  VideoController.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-24.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "VideoController.h"

@implementation VideoController

+ (VideoController *)sharedInstance {
    
    static VideoController *instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[VideoController alloc] init];
    });
    return instance;
}

@end

