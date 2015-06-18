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
    
    BOOL _titleSlideEnabled;
    float _titleSlideDuration;
    NSString *_titleSlideText;
    
    
}

@property (nonatomic, strong) VideoMerger *videoMerger;
@property (nonatomic) NSInteger transitionType;
@property (nonatomic, readonly) float projectDuration;


@property (nonatomic) BOOL titlesEnabled;
@property (nonatomic, retain) NSString *titleText;

@property (nonatomic) BOOL transitionsEnabled;
@property (nonatomic) float transitionDuration;
@property (nonatomic) CMTime transitionTime;
@property (nonatomic) BOOL titleSlideEnabled;
@property (nonatomic) float titleSlideDuration;
@property (nonatomic, strong) NSString *_titleSlideText;




-(IBAction)toggleTransitionsEnabled:(UISwitch*)sender;

-(IBAction)toggleTitleSlideEnabled:(UISwitch*)sender;

@end

