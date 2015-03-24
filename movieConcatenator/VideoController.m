//
//  VideoController.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-24.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.

// Responsible for
// 1. saving takes (videos)
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

-(void)addTake:(Take*)take toSceneAtIndex:(NSInteger)sceneNumber
{
    //VideoController *vc = [VideoController videoController];
    // adds new take to the shared videos array
    if (self.videos[sceneNumber])
    {
        [self.videos[sceneNumber] addObject:take];
    }
    else {
        NSLog(@"scene does not exist yet");
    }
    
    
    // save take to the documents directory;
    
   NSLog(@"%@",[VideoController videoController].videos);
}

- (void) addScene:(Scene*)scene
{
    
    
}
//- (void) insertObject:(Take *)object inSharedVideoArrayAtIndex:(NSIndexPath)sectionIndex;




@end




