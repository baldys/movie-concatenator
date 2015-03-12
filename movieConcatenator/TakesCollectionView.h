//
//  TakesCollectionViewController.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-11.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoLibrary.h"
#import "Scene.h"

@interface TakesCollectionView : UICollectionView

@property (nonatomic, strong) VideoLibrary *library;
@property (nonatomic, strong) Scene *scene;
@property NSInteger rowIndexInTableView;
@property (nonatomic, strong) NSMutableArray *takes;
@end
