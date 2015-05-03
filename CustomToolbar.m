//
//  CustomToolbar.m
//  DemoReel
//
//  Created by Veronica Baldys on 2015-04-23.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "CustomToolbar.h"

@interface CustomToolbar()

@property (nonatomic, strong) UIBarButtonItem *deleteButton;
@property (nonatomic, strong) UIBarButtonItem *starButton;
@property (nonatomic, strong) UIBarButtonItem *otherButton;

@property (nonatomic, strong) NSMutableArray *barButtonItems;

@end

@implementation CustomToolbar



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTranslucent:YES];
        [self setTintColor:[UIColor blackColor]];
        // add buttons
        //[self.playMovieButton setEnabled:NO];
        //[self.deleteTakeButton setEnabled:NO];
        //[self.favouriteTakeButton setEnabled:NO];
        //[self.actionButton setEnabled:YES];
        
        //[self.deleteTakeButton setAction:@selector(delete:)];
        //[self.playMovieButton setAction:@selector(playMovie:)];
       
        self.deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(delete:)];
        
        
        self.starButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"white-outline-star-32"] landscapeImagePhone:[UIImage imageNamed:@"white-outline-star-24"] style:UIBarButtonItemStylePlain target:self action:@selector(addToFavourites:)];
        
    
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc ] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        // add buttons to the array
        NSArray *items = [NSArray arrayWithObjects:self.starButton, flexibleSpace, self.deleteButton, nil];
        
        [self setItems:items];
    }
    return self;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
