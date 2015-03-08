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

@class TakeCell;
//TODO: make a delegate for the cell's superview.
@protocol TakeCellDelegate <NSObject>
-(void)didSelectStarButtonInCell:(TakeCell*)takeCell;
@end

@interface TakeCell : UICollectionViewCell

@property (nonatomic) NSInteger takeCellTag;
@property (nonatomic, strong) NSMutableArray *indexesOfStarredItems;

@property (nonatomic) NSInteger sceneNumber;
@property (nonatomic) NSInteger takeNumber;
@property (weak, nonatomic) IBOutlet UIButton *starTake;
@property (strong, nonatomic) NSURL* assetURL;
@property (strong, nonatomic) AVAsset *videoAsset;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;

@property (strong, nonatomic) Take* take;
@property (nonatomic, weak) id <TakeCellDelegate> delegate;
-(void)cellWithTake:(Take*)take;

- (IBAction)starButtonPressed:(UIButton*)sender;
@end