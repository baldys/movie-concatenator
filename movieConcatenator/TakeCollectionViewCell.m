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
    
    if (self.starTake.selected)
    {
        self.take.selected = YES; // by default all cells are not selected
        ///self.takeCellTag = sender.tag;
        /// NSLog(@"SELECTED %ld ", (long)sender.tag);
    }
    else
    {
        self.take.selected = NO;
    }
    [_delegate didSelectStarButtonInCell:self];
    
}


- (void) configureCell
{
    self.starTake.enabled = YES;
    self.starTake.selected = NO;
    if (self.take.selected)
    {
        self.starTake.selected = YES;
    }
    
    
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.thumbnail.image = nil;
    NSLog(@"reuse");
    self.videoAsset = [[AVURLAsset alloc]initWithURL:self.assetURL options:nil];
    
}


-(void)cellWithTake:(Take*)take
{
    if (!take)
    {
        
    }
    
    self.take = take;
    self.sceneNumber = take.sceneNumber;
    //self.takeNumber = take.takeNumber;
    // sets a thumbnail image to the image of the first frame of that video
    self.assetURL = [take getPathURL];
    
    self.thumbnail.image = [take loadThumbnailWithCompletionHandler:^(UIImage *image)
                            {
                                
                                self.thumbnail.image = image;
                            }];
    
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
