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
//@property (strong, nonatomic) VideoLibrary *library;

@end

@implementation ContainerCellView

- (void)awakeFromNib
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    flowLayout.sectionInset = UIEdgeInsetsMake(0,0,0,0);
    flowLayout.itemSize = CGSizeMake(125, 75);
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"TakeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CollectionViewCell"];
    

   
    
}



- (void) didSelectStarButtonInCell:(TakeCollectionViewCell *)takeCell
{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectStarButtonInCell" object:takeCell.take];
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

    Take *take = self.collectionData.takes[indexPath.item];
  
    NSLog(@"assset id: %@", take.assetID );
    cell.delegate = self;
    

//    if (take.thumbnail == nil)
//    {
        [take loadThumbnailWithCompletionHandler:^ (UIImage *image){
            //self.thumbnail = [image imageByScalingProportionallyToSize:CGSizeMake(110, 90)];
            take.thumbnail = image;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [cell cellWithTake:take];
                
            });
            
            
        }];
//    }
    
   

    
    
    

   
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
