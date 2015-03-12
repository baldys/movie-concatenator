//
//  TakesCollectionViewController.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-11.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "TakesCollectionView.h"
#import "TakeCollectionViewCell.h"
#import "VideoLibrary.h"

@interface TakesCollectionView()

@end

@implementation TakesCollectionView


//static NSString * const reuseIdentifier = @"TakeCell";
/*
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
/*
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.takes.count;
}
*/
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    TakeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
//    
//    [cell cellWithTake:self.takes[indexPath.item]];
//    cell.starTake.tag = indexPath.item;
//    
//    return cell;
//}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/



//// Override to support conditional editing of the table view.
//
//
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    Scene *scene = [self.library.scenes objectAtIndex:indexPath.section];
//    Take *take = [scene.takes objectAtIndex:indexPath.item];
//    //if (![self.selectedItems containsObject:take]) {
//    //    [self.selectedItems addObject:take];
//    //}
//    //[self.selectedItems addObject:take];
//    
//    PlayVideoViewController *videoPlayerVC = [[PlayVideoViewController alloc] init];
//    videoPlayerVC.take = take;
//    
//    //MPMoviePlayer is nil, perhaps in the initializer, alloc init the player.
//    //TODO: present videoPlayerVC
//    ////////////
//    [self presentViewController:videoPlayerVC animated:YES completion:^{
//        NSLog(@"Presented videoPlayerVC!!!");
//        //TODO: videoPlayerVC should start playing some video...
//        
//    }];
//    ////////////
//}






//
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
//{
//    return 1;
//}
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    Scene *scene = self.library.scenes[section];
//    NSLog(@"scene.takes.count %lu", (unsigned long)scene.takes.count);
//    return scene.takes.count;
//}
////
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString* cellIdentifier = @"TakeCollectionViewCell";
//    TakeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
//    Scene *scene = self.library.scenes[indexPath.section];
//    Take *take = scene.takes[indexPath.item];
//    
//    NSLog(@"TakeCollectionViewCell");
//    [cell cellWithTake:take];
//    
//    //cell.delegate = self;
//    return cell;
//}
//
//


@end
