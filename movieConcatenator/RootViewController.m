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
//#import "MergeVideoViewController.h"
#import "TakeCell.h"
#import "VideoLibrary.h"
#import "SceneCollectionResuableView.h"
#import "VideoMerger.h"

@interface RootViewController ()
//- (IBAction)starButtonClicked:(id)sender;

//@property (nonatomic,strong) NSMutableArray *scenesArray;

@end

@implementation RootViewController

//static NSString * const reuseIdentifier = @"TakeCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes

    VideoLibrary *myScenes = [VideoLibrary libraryWithFilename:@"videolibrary.plist"];
    
    if (!myScenes)
    {
        myScenes = [[VideoLibrary alloc] init];
        [myScenes saveToFilename:@"videolibrary.plist"];
    }
    
    self.library = myScenes;
    
    if (!self.selectedItems)
    {
        self.selectedItems = [NSMutableArray array];
    }
    
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


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  
    Scene *scene = self.library.scenes[section];
    return [scene.takes count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"reusableTakeCell";
    TakeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.starTake.tag = indexPath.item;
    if (cell.starTake.selected)
    {
        NSLog(@"cell indexPath selected");
        
    }

    Scene *scene = self.library.scenes[indexPath.section];
    
    Take *take = scene.takes[indexPath.row];
    
    [cell cellWithTake:take];
    cell.delegate = self;
//    if (take.isSelected)
//    {
//        [self.selectedItems insertObject:take atIndex:indexPath.section];
//    }
//    
    
    //cell.takeCellTag = indexPath;
    //[cell addTarget:self action:<#(SEL)#> forControlEvents:UIControlEventTouchUpInside]


    //NSLog(@"self.take.selected %d", cell.starTake.tag);
    //Take *take = scene.takes[cell.starTake.tag];
  
//    for (Scene *scene in self.library.scenes)
//    {
//        for (Take* take in scene.takes)
//        {
//            if (take.isSelected)
//            {
////                
//            }
//               
//                
//                
//        }
//    }
//      
//        
    
    
    NSLog(@"self.take.selected %ld", (long)cell.takeCellTag);
    
   // NSLog(@"displaying cell for take %@", take.assetFileURL);
    
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
    NSLog(@"index path %@", indexPath);
    
    sceneSection.scene = self.library.scenes[indexPath.section];
    sceneSection.addTake.tag = indexPath.section;
    
    sceneSection.sceneTitleLabel.text = sceneSection.scene.title;
    
    //take.sceneNumber = indexPath.item;
    //NSLog(@"index path. item in the suppplementary view ::::: %ld", (long)indexPath.section);
    
    return sceneSection;
}

- (void) didSelectStarButtonInCell:(TakeCell *)takeCell
{
    //NSIndexPath *indexPath = [self.collectionView indexPathForCell:takeCell];
    // toggle selection:
    if (takeCell.take.isSelected && ![self.selectedItems containsObject:takeCell.take])
    {
        [self.selectedItems addObject:takeCell.take];
        
    }
    else if (!takeCell.take.isSelected && [self.selectedItems containsObject:takeCell.take])
    {
        [self.selectedItems removeObject:takeCell.take];
    }
    
    //Scene *scene = self.library.scenes[indexPath.section];
    //Take *take = scene.takes[indexPath.row];
    //if ((take.selected)&&(![self.selectedItems containsObject:take]))
    //{
    
        
    //}
}
#pragma mark <UICollectionViewDelegate>
/// video plays when selected
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Scene *scene = [self.library.scenes objectAtIndex:indexPath.section];
    Take *take = [scene.takes objectAtIndex:indexPath.item];
    //if (![self.selectedItems containsObject:take]) {
    //    [self.selectedItems addObject:take];
    //}
    //[self.selectedItems addObject:take];
    
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

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
	
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/


- (IBAction)addScene:(id)sender {
    
    Scene *newScene = [[Scene alloc] init];
    newScene.title = @"Scene!";
    [self.library.scenes addObject:newScene];
    // ** c
    [self.library saveToFilename:@"videolibrary.plist"];
    
    [self.collectionView reloadData];
}

- (IBAction)MergeAllVideos:(id)sender
{

    VideoMerger *merger = [[VideoMerger alloc] init];
    
/////////////////////////////////////////////////
//    for (Scene *scene in self.library.scenes)
//    {
//        for (Take *take in scene.takes)
//        {
//            if ((take.selected)&&(![self.selectedItems containsObject:take]))
//            {
//                
//                NSLog(@"ZOMGGGG");
//            
//                [self.selectedItems addObject:take];
//            }
//            
//        }
//    }
    /////////////////////////////////

    NSLog(@"5################# %lu",(unsigned long)[self.selectedItems count]);
    [merger exportVideoComposition:[merger spliceAssets:self.selectedItems]];
    
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
    NSLog(@"PREPARE");
    
    UIButton *addTakeButton = (UIButton*)sender;
    NSLog(@"buttontag = %li", (long)addTakeButton.tag);
    
    Scene *currentScene = self.library.scenes[addTakeButton.tag];
    
    
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
                [weakSelf.library saveToFilename:@"videolibrary.plist"];
            }
        };
        /// add completion
        
    }
}


@end
