//
//  VideoController.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-24.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.

// Responsible for
// 1. saving takes (videos) to either: the assets library &&/|| a managed file library created in the documents directory (saved to the disk)
// not sure if it should store the takes themseves with their assets/video stuff
// or whether just their url filepath/filename/directory name need to be saved
// TODO get some clarification
////  reminder to me:
//// video controller allows new take/scene data to be accessed by evertyhing. if a new take is added to the shared array the otehr view controllers can update itself with the new data in response to that change
// DocumentsDirectory/takeFilePath<RANDOM NUMBER>.mov

#import "VideoController.h"
#import "Scene.h"

@interface VideoController ()



@end

@implementation VideoController


+ (NSMutableArray *)sharedInstance
{
    static dispatch_once_t onceToken;
    static NSMutableArray *sharedArray = nil;
    dispatch_once(&onceToken,
    ^{
        sharedArray = [[NSMutableArray alloc] init];
    });
    return sharedArray;
}

-(void) addTake:(Take *)take
{
    NSMutableArray *array = [VideoController sharedInstance];
    // adds new take to the shared videos array
    [array insertObject:take atIndex:0];
    // save take to the documents directory;
    
    
}




@end




//- (void) insertObject:(Take *)object inSharedVideoArrayAtIndex:(NSIndexPath)sectionIndex;

