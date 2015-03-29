//
//  TakeCollectionViewCell.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-08.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Take.h"
#import "Scene.h"
#import "VideoLibrary.h"
@class TakeCollectionViewCell;

//@protocol TakeCellDelegate
//
//-(void)didSelectStarButtonInCell:(TakeCollectionViewCell*)takeCell;
//-(void)didDeselectStarButtonInCell:(TakeCollectionViewCell*)takeCell;
//
//@end

@interface TakeCollectionViewCell : UICollectionViewCell

@property (nonatomic) NSInteger sceneNumber;
@property (nonatomic) NSInteger takeNumber;
@property (weak, nonatomic) IBOutlet UIButton *starTake;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
//@property (strong, nonatomic) NSURL* assetURL;
//@property (strong, nonatomicv) AVAsset *videoAsset;
@property (strong, nonatomic) VideoLibrary *library;
@property (strong, nonatomic) Take* take;
//@property (nonatomic, weak) id <TakeCellDelegate> delegate;

-(void)cellWithTake:(Take*)take;

- (IBAction)starButtonPressed:(UIButton*)sender;

@end

