//
//  ContainerCellView.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-13.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Scene.h"
#import "Take.h"
#import "TakeCollectionViewCell.h"


@class TakeCollectionViewCell;
@class Take;

@interface ContainerCellView : UIView <TakeCellDelegate>

- (void)setCollectionData:(Scene*)collectionData;

@end
