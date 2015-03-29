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
    
    if (self.starTake.isSelected)
    {
        self.take.selected = YES; // by default all cells are not selected
        NSLog(@" asset id of selected take: %@" , self.take.assetID);
        NSLog(@"SELECTED %ld ", (long)self.starTake.tag);

        //[_delegate didSelectStarButtonInCell:self];
    }
    else if (!self.starTake.isSelected)
    {
        self.take.selected = NO;
        //[_delegate didDeselectStarButtonInCell:self];
        
    }
    //[_delegate didSelectStarButtonInCell:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectStarButtonInCell" object:self];

}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.thumbnail.image = nil;
    NSLog(@"reuse");
    //self.videoAsset = [[AVURLAsset alloc]initWithURL:self.assetURL options:nil];
    
}


-(void)cellWithTake:(Take*)take
{
    if (!take)
    {
        NSLog(@"take is nil");
    }
    [self setTake:take];
    
    self.sceneNumber = take.sceneNumber;
    //self.takeNumber = take.takeNumber;
    
    // set a thumbnail image to the image of the first frame of that video
    //self.assetURL = [take getPathURL];
    //[self.take getThumbnailImage];



    self.thumbnail.image = take.thumbnail;
  

}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.layer.borderColor = [[UIColor blueColor] CGColor];
    self.layer.borderWidth = 1.0;
}

@end
