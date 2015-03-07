//
//  ScenesViewController.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-25.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoLibrary.h"

@interface RootViewController : UICollectionViewController

@property (nonatomic, strong) VideoLibrary *library;

@property (nonatomic, strong) NSMutableArray *selectedItems;

- (IBAction)addScene:(id)sender;

- (IBAction)MergeAllVideos:(id)sender;

//- (IBAction)toggleStarButton:(id)sender
@end
