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

- (IBAction)happybutton:(UIButton*)sender
{
    self.selectTakeButton.selected = !self.selectTakeButton.selected;
    NSLog(@"select take %ld", (long)sender.tag);
    
    self.take.selected = YES;
    
    
}
- (void) configureCell
{
    self.selectTakeButton.enabled = YES;
    if (self.take.selected)
    {
        self.selectTakeButton.selected = YES;
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
    // self.take = take;
    
    // sets a thumbnail image to the image of the first frame of that video
    self.assetURL = [take getPathURL];
    
    self.thumbnail.image = [take loadThumbnailWithCompletionHandler:^(UIImage *image)
    {
        
        self.thumbnail.image = image;
    }];
   
}
@end
