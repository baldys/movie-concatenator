//
//  SceneTableViewCell.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-08.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "Scene.h"
#import "Take.h"
#import "RecordVideoViewController.h"
#import "VideoLibrary.h"
#import "SceneTableViewCell.h"
//#import "TakeCollectionViewCell.h"


@interface SceneTableViewCell ()


@property (nonatomic, strong) VideoLibrary *library;
//@property NSMutableArray *selectedItems;

@end

@implementation SceneTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;

    // Initialization code
    self.containerCellView = [[NSBundle mainBundle] loadNibNamed:@"ContainerCellView" owner:self options:nil][0];
    
    
    [self.contentView addSubview:self.containerCellView];
    
    CGFloat height = CGRectGetHeight(self.contentView.frame);
    
    
    return self;
    
    
}

    
//    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
//    layout.sectionInset = UIEdgeInsetsMake(10, 10, 9, 10);
//    layout.itemSize = CGSizeMake(44, 44);
//    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
//    [self.collectionView registerClass:[TakeCollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellIdentifier];
//    self.collectionView.backgroundColor = [UIColor whiteColor];
//    self.collectionView.showsHorizontalScrollIndicator = NO;
//    [self.contentView addSubview:self.collectionView];
//
///
//-(void)layoutSubviews
//{
//    [super layoutSubviews];
//    self.collectionView.frame = self.contentView.bounds;
//    
//}
///

//
//
//
//- (void) didSelectStarButtonInCell:(TakeCollectionViewCell *)takeCell
//{
//    if (takeCell.take.isSelected && ![self.selectedItems containsObject:takeCell.take])
//    {
//        [self.selectedItems addObject:takeCell.take];
//        NSLog(@"take is selected but does not contain object");
//    }
//    //
//    else if (!takeCell.take.isSelected && [self.selectedItems containsObject:takeCell.take])
//    {
//        [self.selectedItems removeObject:takeCell.take];
//        NSLog(@"take is DEselected but contains object");
//    }
//}
//
///
//-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index
//{
//    self.collectionView.dataSource = dataSourceDelegate;
//    self.collectionView.delegate = dataSourceDelegate;
//    self.collectionView.tag = index;
//    self.addTakeButton.tag = index;
//    NSLog(@"index: %ld", (long)index);
//    //self.collectionView.rowIndexInTableView = index;
//    
//    [self.collectionView reloadData];
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setCollectionData:(Scene*)collectionData
{
    [self.containerCellView setCollectionData:collectionData];
}



@end
