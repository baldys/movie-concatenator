//
//  SceneTableViewCell.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-08.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "SceneTableViewCell.h"
#import "Scene.h"
#import "Take.h"
#import "RecordVideoViewController.h"
#import "VideoLibrary.h"
#import "SceneTableViewCell.h"
//#import "TakesCollectionView.h"

@interface SceneTableViewCell ()


@property (nonatomic, strong) VideoLibrary *library;
@property NSMutableArray *selectedItems;
@end

@implementation SceneTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.itemSize = CGSizeMake(150, 100);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[TakesCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView registerClass:[TakeCollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellIdentifier];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:self.collectionView];
    
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = self.contentView.bounds;
    
}



- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.collectionView reloadData];
}

//
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

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index
{
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.tag = index;
   
    
    //self.collectionView.rowIndexInTableView = index;
    
    [self.collectionView reloadData];
}




@end
