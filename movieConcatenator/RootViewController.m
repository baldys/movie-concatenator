//
//  ScenesViewController.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-25.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "RootViewController.h"
#import "Scene.h"
#import "Take.h"
#import "RecordVideoViewController.h"
#import "PlayVideoViewController.h"
#import "MergeVideoViewController.h"
#import "TakeCell.h"

@interface RootViewController ()


@end

@implementation RootViewController

static NSString * const reuseIdentifier = @"TakeCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    
    
    
    MediaLibrary *myScenes = [MediaLibrary libraryWithFilename:@"medialibrary.plist"];
    
    
    if (!myScenes) {
        myScenes = [[MediaLibrary alloc] init];
        [myScenes saveToFilename:@"medialibrary.plist"];
    }
    
    self.library = myScenes;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.library.scenes count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  
    Scene *scene = [self.library.scenes objectAtIndex:section];
    return [scene.takes count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    TakeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    Scene *scene = [self.library.scenes objectAtIndex:indexPath.section];

    Take *take = [scene.takes objectAtIndex:indexPath.item];
    NSLog(@"displaying cell for take %@", take);
    
//    
//    AVAsset *myAasset = [take loadAsset];
//    
//    [cell showThumbnailForAsset:myAsset];
    
    // Configure the cell
    
    return cell;
}


-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

     UICollectionReusableView *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"SceneHeader" forIndexPath:indexPath];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    //MPMoviePlayer
    
}

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


- (IBAction)addScene:(id)sender {
    
    Scene *newScene = [[Scene alloc] init];
    [self.library.scenes addObject:newScene];
    [self.library saveToFilename:@"medialibrary.plist"];
    
    [self.collectionView reloadData];
}

- (IBAction)recordTake:(id)sender
{
    RecordVideoViewController *recordVideoVC = [[RecordVideoViewController alloc] init];
    [self presentViewController:recordVideoVC animated:YES completion:nil];
//        //
//        recordVideoVC.view.backgroundColor = [UIColor orangeColor];
//    }];
//    

    


    
}



 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
    NSLog(@"PREPARE");
    
    
}

- (IBAction)unwindToRootViewController:(UIStoryboardSegue*)segue
{
    
}


@end
