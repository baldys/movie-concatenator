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
  
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = CGSizeMake(130, 120);
    //flowLayout.collectionViewContentSize
      NSLog(@"self.bounds.size.width = %f, .height = %f",self.bounds.size.width ,self.bounds.size.height);
    
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    // Register the colleciton cell
    [_collectionView registerNib:[UINib nibWithNibName:@"TakeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:CollectionViewCellIdentifier];
    //[self addSubview:self.collectionView];
    //self.bounds = self.collectionView.frame;

}


#pragma mark - Getter/Setter overrides
- (void)setCollectionData:(Scene*)collectionData {
    NSLog(@"Hai! I'm ContainerCellView and I am attempting to set a scene :)");
    _collectionData = collectionData;
    [_collectionView setContentOffset:CGPointZero animated:NO];
    [_collectionView reloadData];
}


#pragma mark - UICollectionViewDataSource methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.collectionData.takes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TakeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];

    collectionView.tag = indexPath.item;

    Take *take = self.collectionData.takes[indexPath.row];
  
    NSLog(@"assset id: %@", take.assetID );
    
    [cell cellWithTake:take];

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
