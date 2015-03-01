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

@interface TakeCell : UICollectionViewCell


@property (strong, nonatomic) NSURL* assetURL;
@property (strong, nonatomic) AVAsset *videoAsset;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;

-(void)cellWithTake:(Take*)take;


@end
