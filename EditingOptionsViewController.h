//
//  EditingOptionsViewController.h
//  DemoReel
//
//  Created by Veronica Baldys on 2015-05-16.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//


#import <UIKit/UIKit.h>

//#import "SimpleEditor.h"
//#import "VEMediaPickerViewController.h"

//@class AssetBrowserController;
@class AVURLAsset;

@interface EditingOptionsViewController : UITableViewController//<AssetBrowserAlbumControllerDelegate>
{
    //UINavigationController *_assetBrowser;
    
    NSInteger _currentlyChoosingClipForSection;
    NSArray *_indexPathsToInsert;
    
    //SimpleEditor *_editor;
    
    NSMutableArray *_videoClips;
    NSMutableArray *_clipThumbnails;
    NSMutableArray *_clipTimeRanges;
    
    BOOL _commentaryEnabled;
    AVURLAsset *_commentary;
    float _commentaryStartTime;
    UIImage *_commentaryThumbnail;
    
    BOOL _transitionsEnabled;
    //SimpleEditorTransitionType _transitionType;
    float _transitionDuration;
    
    BOOL _titlesEnabled;
    NSString *_titleText;
    
    BOOL _exporting;
    BOOL _showSavedVideoToAssestsLibrary;
    
}

@property (nonatomic, retain) UINavigationController *assetBrowser;

//@property (nonatomic, retain) SimpleEditor *editor;

@property (nonatomic, retain) NSMutableArray *clips;
@property (nonatomic, retain) NSMutableArray *clipTimeRanges;
@property (nonatomic, retain) NSMutableArray *clipThumbnails;

@property (nonatomic, retain) AVURLAsset *commentary;
@property (nonatomic, retain) UIImage *commentaryThumbnail;

@property (nonatomic, readonly) float projectDuration;

@property (nonatomic, retain) NSString *titleText;

@end

