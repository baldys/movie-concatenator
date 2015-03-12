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


@interface SceneTableViewCell : UITableViewCell <TakeCellDelegate>
@property (weak, nonatomic) IBOutlet UILabel *sceneTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *addTakeButton;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) Scene *scene;

-(void)setCollectionViewDataSourceDelegate:(id <UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index;

@end
