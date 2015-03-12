//
//  SceneTableViewCell.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-08.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

// each table view cell represents a scene. scenes have a takes property which will be represented by the takes collection view.

#import <UIKit/UIKit.h>
#import "TakeCollectionViewCell.h"
#import "TakesCollectionView.h"

@class Scene;


static NSString *CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";


@interface SceneTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *sceneTitleLabel;
@property (nonatomic, strong) Scene *scene;
@property (weak, nonatomic) IBOutlet UIButton *addTakeButton;

@property (strong, nonatomic) TakesCollectionView *collectionView;


-(void)setCollectionViewDataSourceDelegate:(id <UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index;

@end
