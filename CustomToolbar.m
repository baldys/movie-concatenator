//
//  CustomToolbar.m
//  DemoReel
//
//  Created by Veronica Baldys on 2015-04-23.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//
//
//#import "CustomToolbar.h"
//
//@interface CustomToolbar()
//
//@property (nonatomic, strong) UIBarButtonItem *deleteButton;
//@property (nonatomic, strong) UIBarButtonItem *starButton;
//@property (nonatomic, strong) UIBarButtonItem *otherButton;
//
//@property (nonatomic, strong) NSMutableArray *barButtonItems;
//
//@end
//
//@implementation CustomToolbar
//
//
//
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self setTranslucent:YES];
//        [self setTintColor:[UIColor blackColor]];
//        // add buttons
//        //[self.playMovieButton setEnabled:NO];
//        //[self.deleteTakeButton setEnabled:NO];
//        //[self.favouriteTakeButton setEnabled:NO];
//        //[self.actionButton setEnabled:YES];
//        
//        //[self.deleteTakeButton setAction:@selector(delete:)];
//        //[self.playMovieButton setAction:@selector(playMovie:)];
//       
//        self.deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(delete:)];
//        ///UIBarButtonItem *flexItem = [UIBarButtonItem alloc] in target:<#(id)#> action:<#(SEL)#>
//        
//        self.starButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"white-outline-star-32"] landscapeImagePhone:[UIImage imageNamed:@"white-outline-star-24"] style:UIBarButtonItemStylePlain target:self action:@selector(addAsFavourite:)];
//        
//    
//        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc ] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//        // add buttons to the array
//        NSArray *items = [NSArray arrayWithObjects:self.starButton, flexibleSpace, self.deleteButton, nil];
//        
//        [self setItems:items];
//    }
//    return self;
//}
//
////- (IBAction)addAsFavourite:(id)sender
////{
////    // if the take has not been selected to be put in the list of videos to concatenate
////    //self.takeToPlay.selected = !self.takeToPlay.selected;
////    NSIndexPath *index = self.tableView.indexPathForSelectedRow;
////    
////    Take *take = self.scene.takes[index.row];
////    NSLog(@"library index:>>>> %ld", (long)self.scene.libraryIndex);
////    
////    if (![take isSelected])
////    {
////        [self.starButton setImage:[UIImage imageNamed:@"blue-star-32"]];
////        [self.starButton setLandscapeImagePhone:[UIImage imageNamed:@"blue-star-24"]];
////        [take setSelected:YES];
////    }
////    else{
////        [self.starButton setImage:[UIImage imageNamed:@"white-outline-star-32"]];
////        [self.starButton setLandscapeImagePhone:[UIImage imageNamed:@"white-outline-star-24"]];
////        [take setSelected:NO];
////    }
////    
////    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectStarButtonInCell" object:take];
////    
////    
////}
//
//
//
///*
//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}
//*/
//
//@end
