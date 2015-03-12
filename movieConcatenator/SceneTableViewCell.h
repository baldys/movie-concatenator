//
//  SceneTableViewCell.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-08.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TakeCollectionViewCell.h"

@class Scene;

static NSString *CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";


@interface SceneTableViewCell : UITableViewCell 
@property (weak, nonatomic) IBOutlet UILabel *sceneTitleLabel;
@property (nonatomic, strong) Scene *scene;
@property (weak, nonatomic) IBOutlet UIButton *addTakeButton;


@property (nonatomic, strong) UICollectionView *collectionView; // Takes

//
//-(void)setCollectionViewDataSourceDelegate:(id <UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index;

@end
