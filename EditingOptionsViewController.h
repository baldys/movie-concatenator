//
//  EditingOptionsViewController.h
//  DemoReel
//
//  Created by Veronica Baldys on 2015-05-16.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "VideoMerger.h"

@class AVURLAsset;

@interface EditingOptionsViewController : UITableViewController
{
  
    
    NSInteger _currentlyChoosingClipForSection;
    NSArray *_indexPathsToInsert;
  
    NSMutableArray *_videoClips;
    NSMutableArray *_clipThumbnails;
    NSMutableArray *_clipTimeRanges;
    
    BOOL _transitionsEnabled;
    float _transitionDuration;
    
    BOOL _titlesEnabled;
    NSString *_titleText;
    
    
}

@property (nonatomic, strong) VideoMerger *videoMerger;
@property (nonatomic) TransitionTypes transitionType;
@property (nonatomic, readonly) float projectDuration;

@property (nonatomic, retain) NSString *titleText;

-(IBAction)toggleTransitionsEnabled:(UISwitch*)sender;
@end

