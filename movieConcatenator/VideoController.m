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



+(VideoController *)videoController {
    static dispatch_once_t pred;
    static VideoController *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[VideoController alloc] init];
        shared.videos = [[NSMutableArray alloc]init];
    });
    return shared;
}

-(void)addVideo:(id)video
{
    //VideoController *vc = [VideoController videoController];
    // adds new take to the shared videos array
    [self.videos addObject:video];
    // save take to the documents directory;
    
   NSLog(@"%@",[VideoController videoController].videos);
}

//- (void) insertObject:(Take *)object inSharedVideoArrayAtIndex:(NSIndexPath)sectionIndex;




@end




