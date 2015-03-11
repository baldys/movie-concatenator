//
//  TakeCollectionViewCell.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-08.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "TakeCollectionViewCell.h"
#import "SceneTableViewCell.h"


@implementation TakeCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

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
    //self.thumbnail.image = nil;
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
    self.takeNumber = take.takeNumber;
    // sets a thumbnail image to the image of the first frame of that video
    self.assetURL = [take getPathURL];
    
    self.thumbnail.image = [take loadThumbnailWithCompletionHandler:^(UIImage *image)
                            {
                                
                                self.thumbnail.image = image;
                            }];
    
}



@end
