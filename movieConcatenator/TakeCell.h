//
//  TakeCell.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-26.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Take.h"
#import "Scene.h"

//TODO: make a delegate for the cell's superview.

@interface TakeCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *selectTakeButton;
@property (strong, nonatomic) NSURL* assetURL;
@property (strong, nonatomic) AVAsset *videoAsset;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (nonatomic) NSInteger *takeCellTag;
@property (strong, nonatomic) Take* take;

-(void)cellWithTake:(Take*)take;


@end
