//
//  ScenesViewController.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-25.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaLibrary.h"

@interface RootViewController : UICollectionViewController


@property (nonatomic, strong) MediaLibrary *library;

- (IBAction)addScene:(id)sender;

- (IBAction)MergeAllVideos:(id)sender;

@end
