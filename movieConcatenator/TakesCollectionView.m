//
//  TakesCollectionView.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-08.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

//#import "TakesCollectionView.h"
//#import "Scene.h"
//#import "Take.h"
//#import "RecordVideoViewController.h"
//#import "PlayVideoViewController.h"
//#import "TakeCell.h"
//#import "VideoLibrary.h"
//#import "SceneCollectionResuableView.h"
//#import "VideoMerger.h"
//

//@interface TakesCollectionView ()

//@property (nonatomic, strong) NSMutableArray *takes;
//@property (nonatomic, strong) NSMutableArray *selectedItems;
//@property Scene *scene;
//@end

//@implementation TakesCollectionView
//
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
//{
//    
//    return 1 ;
//}
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    return self.scene.takes.count;
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString* cellIdentifier = @"TakeCollectionViewCell";
//    TakeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
//    Take *take = self.takes[indexPath.item];
//    
//    [cell cellWithTake:take];
//    
//    cell.delegate = self;
//    return cell;
//}
//
//-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    SceneCollectionResuableView *sceneSection = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"SceneHeader" forIndexPath:indexPath];
//    NSLog(@"index path %@", indexPath);
//    
//    sceneSection.scene = self.library.scenes[indexPath.section];
//    sceneSection.addTake.tag = indexPath.section;
//    sceneSection.sceneTitleLabel.text = sceneSection.scene.title;
//    
//    return sceneSection;
//    
//    
//}
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
//    
//
//}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

// you can get the scroll position of the collection view. use this index path when clicking a button to play the video
/// (UICollectionViewScrollPosition)scrollPosition;
//- (NSArray *)visibleCells;
//- (NSArray *)indexPathsForVisibleItems;
//// Interacting with the collection view.

//- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;
/// register cell class with reuse identifier
/// register cellclass for supplementary view



//@end
