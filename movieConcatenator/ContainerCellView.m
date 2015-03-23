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

- (void)awakeFromNib {
    if (!self.collectionData)
    {
        NSLog(@"scene is nil");
    }
  ///////
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsMake(8,10,8,10);
    flowLayout.itemSize = CGSizeMake(130, 120);
    [self.collectionView setCollectionViewLayout:flowLayout];
    [_collectionView registerNib:[UINib nibWithNibName:@"TakeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CollectionViewCell"];
}

#pragma mark - Getter/Setter overrides
- (void)setCollectionData:(Scene*)collectionData
{
    _collectionData = collectionData;
    [_collectionView setContentOffset:CGPointZero animated:YES];
    [_collectionView reloadData];
}


#pragma mark - UICollectionViewDataSource methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"self.collectionData.takes.count:%lu",(unsigned long)self.collectionData.takes.count);
    return self.collectionData.takes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CollectionViewCellIdentifier = @"CollectionViewCell";
    TakeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    //collectionView.tag = indexPath.item;

    Take *take = self.collectionData.takes[indexPath.row];
  
    NSLog(@"assset id: %@", take.assetID );
    
    [cell cellWithTake:take];
    //UIImageView *image = [[[UIImage alloc] init ];
    //[take.imageGenerator initWithAsset:[AVAsset assetWithURL:[take.thumbailImg getPathURL]]];

   // NSDictionary *cellData = self.collectionData[indexPath.row];
    //cell.articleTitle.text = [cellData objectForKey:@"title"];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    /// instantiate the video player view controller here.
    //NSDictionary *cellData = [self.collectionData objectAtIndex:[indexPath row]];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectItemFromCollectionView" object:cellData];
}

@end
