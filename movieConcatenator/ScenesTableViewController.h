//
//  ScenesTableViewController.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-08.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoLibrary.h"
#import "TakeCollectionViewCell.h"
#import "ContainerCellView.h"
#import "SceneTableViewCell.h"
#import "RecordVideoViewController.h"

@class RecordVideoViewController;
@class TakeCollectionViewCell;
@class Take;

@interface ScenesTableViewController:UITableViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) VideoLibrary *library;
@property (nonatomic, strong) NSMutableArray *takesToConcatenate;
- (IBAction)ConcatenateSelectedTakes:(id)sender;
- (IBAction)unwindToScenesView:(UIStoryboardSegue*)segue;
- (IBAction)addTakeButtonPressed:(id)sender;
@end
