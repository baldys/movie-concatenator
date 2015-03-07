//
//  TakeCell.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-26.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "TakeCell.h"

@interface TakeCell ()



@end

@implementation TakeCell

- (IBAction)starButtonSelectedForCell:(UIButton*)sender
{
    // the sender/button tag = index of the item in the array of takes to be added to the list of takes to merge (this will just be an array of int values (section, index) that correspond to their positions in that array. when the user presses merge, those items at those indexes will be concatenated/spliced


    
    self.starTake.selected = !self.starTake.selected;
    if (self.starTake.selected)
    {
        self.take.selected = YES; // by default all cells are not selected.
        

        self.takeCellTag = sender.tag;
        NSLog(@"SELECTED %ld ", (long)sender.tag);
    }

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
