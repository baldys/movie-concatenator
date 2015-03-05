//
//  TakeCell.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-26.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "TakeCell.h"

@implementation TakeCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.thumbnail.image = nil;
    NSLog(@"reuse");
    self.videoAsset = [[AVURLAsset alloc]initWithURL:self.assetURL options:nil];
}


-(void)cellWithTake:(Take*)take
{
    // sets a thumbnail image to the image of the first frame of that video
    self.assetURL = [take getPathURL];
    
    self.thumbnail.image = [take loadThumbnailWithCompletionHandler:^(UIImage *image)
    {
        
        self.thumbnail.image = image;
    }];
   
}
@end
