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
#import "MediaLibrary.h"
#import "SceneCollectionResuableView.h"
#import "VideoMerger.h"

@interface RootViewController ()

//@property (nonatomic,strong) NSMutableArray *scenesArray;


@end

@implementation RootViewController

//static NSString * const reuseIdentifier = @"TakeCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes

    MediaLibrary *myScenes = [MediaLibrary libraryWithFilename:@"medialibrary.plist"];
    
    if (!myScenes)
    {
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

-(void)viewWillAppear:(BOOL)animated {
    [self.collectionView reloadData];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.library.scenes count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  
    Scene *scene = [self.library.scenes objectAtIndex:section];
    NSLog(@"[scene.takes count] %d", [scene.takes count]);
    return [scene.takes count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"reusableTakeCell";
    
    TakeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Scene *scene = [self.library.scenes objectAtIndex:indexPath.section];

    Take *take = [scene.takes objectAtIndex:indexPath.item];
    
    [cell cellWithTake:take];
    
    NSLog(@"displaying cell for take %@", take.assetFileURL);
    
//    
//    AVAsset *myAasset = [take loadAsset];
//    
//    [cell showThumbnailForAsset:myAsset];
    
    // Configure the cell
    
    return cell;
}


-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{

     SceneCollectionResuableView *sceneSection = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"SceneHeader" forIndexPath:indexPath];
    
    sceneSection.scene = self.library.scenes[indexPath.item];
    sceneSection.addTake.tag = indexPath.section;
    
    return sceneSection;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did select item");
    
    Scene *scene = [[Scene alloc] init];
    
    scene = [self.library.scenes objectAtIndex:indexPath.section];
    Take *take = [scene.takes objectAtIndex:indexPath.item];

    PlayVideoViewController *videoPlayerVC = [[PlayVideoViewController alloc] init];
    videoPlayerVC.take = take;
    
    //MPMoviePlayer is nil, perhaps in the initializer, alloc init the player.
    //TODO: present videoPlayerVC
    
    [self presentViewController:videoPlayerVC animated:YES completion:^{
        //
        NSLog(@"Presented videoPlayerVC!!!");
        //TODO: videoPlayerVC should start playing some video...
        
    }];
    
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
    newScene.title = @"Scene!";
    [self.library.scenes addObject:newScene];
    // ** c
    [self.library saveToFilename:@"medialibrary.plist"];
    
    [self.collectionView reloadData];
}

- (IBAction)MergeAllVideos:(id)sender
{

    VideoMerger *merger = [[VideoMerger alloc] init];
    
    
    Scene *scene = self.library.scenes[0];
    
    Take *take1 = scene.takes[0];
    NSLog(@"TAKE 1: %@", take1);
    NSLog(@" \n\n\n\n\n\n\n\n\n %@ \n\n\n\n\n\n\n\n", take1.assetFileURL);
    if (take1.assetFileURL.isFileURL)
    {
        NSLog(@"yes \n\n\n\n");
    }
    Take *take2 = scene.takes[1];
    take1.asset = [AVAsset assetWithURL:take1.assetFileURL];
    take2.asset = [AVAsset assetWithURL:take2.assetFileURL];
    
    
    
//    for (Scene *scene in self.library.scenes)
//    {
//        for (Take *take in scene.takes)
//        {
//            
//            
//            
//        }
//    }
    [merger appendAsset:take2.asset toPreviousAsset:take1.asset];
    
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
    NSLog(@"PREPARE");
    
    UIButton *button = (UIButton*)sender;
    NSLog(@"buttontag = %li", (long)button.tag);
    
    Scene *currentScene = self.library.scenes[button.tag];
    
    
    if ([segue.identifier isEqualToString:@"showRecordVC"])
    {
        
        RecordVideoViewController *recordViewController = segue.destinationViewController;
        
        recordViewController.scene = currentScene;
        __weak __typeof(self) weakSelf = self;
        recordViewController.completionBlock = ^void (BOOL success)
        {
            NSLog(@"completion block called");
            if (success)
            {
                NSLog(@"saving");
                [weakSelf.library saveToFilename:@"medialibrary.plist"];
            }
        };
        /// add completion
        
    }
}

@end
