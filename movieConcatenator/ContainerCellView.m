//
//  ContainerCellView.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-13.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "ContainerCellView.h"
#import "TakeCollectionViewCell.h"
#import "VideoLibrary.h"

@interface ContainerCellView ()  <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) Scene *collectionData;
@property (strong, nonatomic) VideoLibrary *library;

@end

@implementation ContainerCellView

- (void)awakeFromNib
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    flowLayout.sectionInset = UIEdgeInsetsMake(8,10,8,10);
    flowLayout.itemSize = CGSizeMake(130, 120);
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"TakeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CollectionViewCell"];
    
}

- (void) didSelectStarButtonInCell:(TakeCollectionViewCell *)takeCell
{
    
    if (takeCell.take.isSelected && ![self.library.selectedVideos containsObject:takeCell.take])
    {
        [self.library.selectedVideos addObject:self.library.scenes[takeCell.starTake.tag]];
        [self.library.selectedVideos addObject:takeCell.take];
        NSLog(@"take is selected but does not contain object");
    }
    //
    else if (!takeCell.take.isSelected && [self.library.selectedVideos containsObject:takeCell.take])
    {
        [self.library.selectedVideos removeObject:takeCell.take];
        NSLog(@"take is DEselected but contains object");
    }
}

#pragma mark - Getter/Setter overrides
- (void)setCollectionData:(Scene*)collectionData
{
    _collectionData = collectionData;
    [_collectionView setContentOffset:CGPointZero animated:NO];
  
    [_collectionView reloadData];
    
}


#pragma mark - UICollectionViewDataSource methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.collectionData.takes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CollectionViewCellIdentifier = @"CollectionViewCell";
    TakeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    cell.starTake.tag = indexPath.item;
    
    //collectionView.tag = indexPath.item;

    Take *take = self.collectionData.takes[indexPath.row];
  
    NSLog(@"assset id: %@", take.assetID );
    //cell.delegate = self;
    
    
    [take getThumbnailImage];

    
    [cell cellWithTake:take];

   
    //[collectionView reloadData];
    

    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Take *cellData = self.collectionData.takes[indexPath.item];
    
    // When collection view item is selected it plays the video for the selected take cell
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectItemFromCollectionView" object:[cellData getPathURL]];
}

@end
