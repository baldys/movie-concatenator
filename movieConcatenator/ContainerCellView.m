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
#import "UIImage+Extras.h"
#import "AddTakeCell.h"

@interface ContainerCellView ()  <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) Scene *collectionData;
@property (strong, nonatomic) NSMutableArray *dataSource;

@end

#define kGreen1 0.7
#define kGreen2 0.8
#define kGreen3 0.9

#define kCellSpacing 8
#define kCellSize 128
@implementation ContainerCellView

- (void)awakeFromNib
{
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 4.0;
    flowLayout.minimumLineSpacing = 4.0;
    flowLayout.sectionInset = UIEdgeInsetsMake(0,4,0,4);
    flowLayout.itemSize = CGSizeMake(kCellSize,kCellSize);
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"TakeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CollectionViewCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"AddTakeCell" bundle:nil] forCellWithReuseIdentifier:@"AddTakeCell"];
    
    _collectionView.backgroundColor = [UIColor colorWithRed:0.0 green:0.789 blue:1.0 alpha:1.0];

    //_collectionView.layer.borderColor = [UIColor blackColor].CGColor;
    //_collectionView.layer.cornerRadius = 3.0;
    //_collectionView.layer.borderWidth = 0.4;
    
    
    //self.dataSource = [NSMutableArray arrayWithArray:self.collectionData.takes];
    
    //Take *addTake = [[Take alloc] init];
    //[self.dataSource addObject:addTake];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteItem:) name:@"shouldDeleteTake" object:nil];
    

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


-(void)insertItem:(Take*)item
{
    [_collectionData.takes addObject:item];
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:_collectionData.takes.count] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    [_collectionView reloadItemsAtIndexPaths:[self.collectionData.takes lastObject]];
}

-(void)deleteItem:(Take*)item
{
    //[_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[_collectionData.takes indexOfObject:item] inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    [_collectionData.takes removeObject:item];
    [_collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.collectionData.takes.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CollectionViewCellIdentifier = @"CollectionViewCell";
    static NSString *AddTakeCellIdentifier = @"AddTakeCell";
    //NSString *cellID = nil;
    
    if (indexPath.item == self.collectionData.takes.count)
    {
        //cellID = AddTakeCellIdentifier;
        AddTakeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AddTakeCellIdentifier forIndexPath:indexPath];
        if (!cell)
        {
            cell = [[AddTakeCell alloc] init];
        }
       // cell.starTake.hidden = YES;
        return cell;
    }
    else if (indexPath.item < self.collectionData.takes.count)
    {
        NSLog(@"Takes in scene: %i", self.collectionData.takes.count);
        TakeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
        if (!cell)
        {
            cell = [[TakeCollectionViewCell alloc] init];
           
        }
        
        cell.starTake.hidden = NO;
        cell.starTake.tag = indexPath.item;
        Take *take = self.collectionData.takes[indexPath.item];
        cell.delegate = self;
        [cell cellWithTake:take];
        
        if (take.thumbnail == nil)
        {
        
            NSLog(@"thumbnail image is nil");

        
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),^{
            

            
            
                [take loadThumbnailWithCompletionHandler:^(UIImage* image)
             
                {
                 
                    CGFloat imageWidth = image.size.width;
                 
                    CGFloat imageHeight = image.size.height;
                 
                    CGFloat scale = imageHeight/imageWidth;
                 
                 
                    dispatch_async(dispatch_get_main_queue(),^{
                
                        cell.thumbnailImageView.image = image;
                
                     
                        NSLog(@"loaded thumbnail for collection view cell");
                 
                    });
             
                }];

        
            });

       
        }
    
   
        else
        {
        
            cell.thumbnailImageView.image = take.thumbnail;
        }
    
    return cell;

    }
    
    //}

    //    CGRect screenRect = [[UIScreen mainScreen] bounds];
    //    CGFloat screenWidth = CGRectGetWidth(screenRect);
    
    
  
    
    return nil;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // the last item adds a new take, all the others are existing ones
    if (indexPath.item == self.collectionData.takes.count)
    {
        NSLog(@"scene number: %i", self.collectionData.libraryIndex);
       
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showVideoCamera" object:self.collectionData];
    }
    else
    {
        Take *take = self.collectionData.takes[indexPath.item];
        NSLog(@"Take in scene number: %i", take.sceneNumber);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectItemForPlayback" object:take];
        
   
    }
 
}

@end
