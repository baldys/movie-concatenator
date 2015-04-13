////  SceneTableViewCell.m//  movieConcatenator////  Created by Veronica Baldys on 2015-03-08.//  Copyright (c) 2015 Veronica Baldys. All rights reserved.//#import "Scene.h"#import "Take.h"#import "RecordVideoViewController.h"#import "VideoLibrary.h"#import "SceneTableViewCell.h"@interface SceneTableViewCell ()@property (nonatomic, strong) VideoLibrary *library;@end@implementation SceneTableViewCell- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;    self.containerCellView = [[NSBundle mainBundle] loadNibNamed:@"ContainerCellView" owner:self options:nil][0];    _containerCellView.frame = self.bounds;    [self.contentView addSubview:_containerCellView];    return self;}//- (void) didSelectStarButtonInCell:(TakeCollectionViewCell *)takeCell//{//    if (takeCell.take.isSelected && ![self.selectedItems containsObject:takeCell.take])//    {//        [self.selectedItems addObject:takeCell.take];//        NSLog(@"take is selected but does not contain object");//    }//    ////    else if (!takeCell.take.isSelected && [self.selectedItems containsObject:takeCell.take])//    {//        [self.selectedItems removeObject:takeCell.take];//        NSLog(@"take is DEselected but contains object");//    }//}- (void)setSelected:(BOOL)selected animated:(BOOL)animated{    [super setSelected:selected animated:animated];    // Configure the view for the selected state}- (void)setCollectionData:(Scene*)collectionData{    [_containerCellView setCollectionData:collectionData];       }@end