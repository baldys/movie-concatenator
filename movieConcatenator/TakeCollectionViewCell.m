//
//  TakeCollectionViewCell.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-08.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "TakeCollectionViewCell.h"
#import "SceneTableViewCell.h"

#import <QuartzCore/QuartzCore.h>

@implementation TakeCollectionViewCell




- (IBAction)starButtonPressed:(UIButton *)sender
{
    self.starTake.selected = !self.starTake.selected;
    self.starTake.tag = sender.tag;
    
    if (self.starTake.selected)
    {
        self.take.selected = YES; // by default all cells are not selected
        NSLog(@" asset id of selected take: %@" , self.take.assetID);
        NSLog(@"SELECTED %ld ", (long)self.starTake.tag);

        
    }
    else
    {
        self.take.selected = NO;
        
        
    }
    // set delegate to cell in  collection view...
    
    //
    // try sending a scene index instead
    
    [_delegate didSelectStarButtonInCell:self];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectStarButtonInCell" object:self];

}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.thumbnailImageView.image = nil;
    NSLog(@"reuse");
    //self.videoAsset = [[AVURLAsset alloc]initWithURL:self.assetURL options:nil];
    
}


-(void)cellWithTake:(Take*)take
{
    
    [self setTake:take];

    // set a thumbnail image to the image of the first frame of that video
    //self.assetURL = [take getPathURL];
    //[self.take getThumbnailImage];

    if (take.isSelected)
    {
        self.starTake.selected = YES;
    }
    else if (!take.isSelected)
    {
        self.starTake.selected = NO;
    }


    self.thumbnailImageView.image = take.thumbnail;

  
    ////
//    
//        if (self.imageArray == nil)
//        {
//                self.imageArray = [NSMutableDictionary dictionaryWithContentsOfFile:];
//        }
//            [self.imageArray addObject:take.thumbnail];
//        }

}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
    }
    return self;
}

- (UIColor*)darkBlueWithPurp
{
    return [UIColor colorWithRed:0.1333 green:0 blue:0.6588 alpha:1.0];
}
/// red 0.1333
/// green 0
/// blue 0.6588

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
   
    self.layer.borderColor = [[self darkBlueWithPurp] CGColor];
    self.layer.borderWidth = 2.0;
    //self.layer.cornerRadius = 2.0;
}

@end
