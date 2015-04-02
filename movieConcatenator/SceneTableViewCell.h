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
#import "ContainerCellView.h"

@class Scene;


@interface SceneTableViewCell : UITableViewCell

@property (nonatomic, strong) Scene *scene;
@property (nonatomic) NSInteger index;

@property (strong, nonatomic) ContainerCellView *containerCellView;

- (void)setCollectionData:(Scene *)collectionData;


@end
