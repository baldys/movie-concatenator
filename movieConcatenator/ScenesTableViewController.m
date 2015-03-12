//
//  ScenesTableViewController.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-08.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "ScenesTableViewController.h"
#import "Scene.h"
#import "Take.h"
#import "VideoLibrary.h"
#import "SceneTableViewCell.h"
#import "VideoMerger.h"
#import "PlayVideoViewController.h"
#import "RecordVideoViewController.h"
#import "SceneCollectionResuableView.h"

@interface ScenesTableViewController ()
@property (nonatomic, strong) NSMutableArray *scenes;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;

@end

@implementation ScenesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = YES;
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
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
    

}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
}
-(void) viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear trying to recursively log some views!!!");
    [self recursivelyLogViews:self.view];
}

-(void) recursivelyLogViews:(UIView*) view{
    NSLog(@"%@ frame: (%f, %f, %f, %f)", view.class, view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
    for (UIView* subview in view.subviews) {
        [self recursivelyLogViews:subview];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.library.scenes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SceneTableViewCell";
    
    SceneTableViewCell *cell = (SceneTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[SceneTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.addTakeButton.tag = indexPath.row;
    cell.scene =  self.library.scenes[indexPath.row];
    cell.sceneTitleLabel.text = cell.scene.title;
    
    NSLog(@"scene.title: %@", cell.scene.title);
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    Scene *scene = self.library.scenes[section];
    NSLog(@"scene.takes.count %lu", (unsigned long)scene.takes.count);
    return scene.takes.count;
    
}
//
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"TakeCollectionViewCell";
    TakeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    Scene *scene = self.library.scenes[indexPath.section];
    Take *take = scene.takes[indexPath.item];
    
    NSLog(@"TakeCollectionViewCell");
    [cell cellWithTake:take];
    
    //cell.delegate = self;
    return cell;
}
/*
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    SceneCollectionResuableView *sceneSection = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"SceneHeader" forIndexPath:indexPath];
    NSLog(@"index path %@", indexPath);
    
    sceneSection.scene = self.library.scenes[indexPath.section];
    sceneSection.addTake.tag = indexPath.section;
    sceneSection.sceneTitleLabel.text = sceneSection.scene.title;
    
    return sceneSection;
    
    
}
*/

-(void)tableView:(UITableView *)tableView willDisplayCell:(SceneTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewDataSourceDelegate:self index:indexPath.row];
    
    NSInteger index = cell.collectionView.tag;
    
    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
   [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}

// Override to support conditional editing of the table view.


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
    ////////////
    [self presentViewController:videoPlayerVC animated:YES completion:^{
        NSLog(@"Presented videoPlayerVC!!!");
    //TODO: videoPlayerVC should start playing some video...
    
    }];
    ////////////
}
/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

- (IBAction)addScene:(id)sender
{
    Scene *newScene = [[Scene alloc] init];
    newScene.title = @"Scene!";
    [self.library.scenes addObject:newScene];
    [self.library saveToFilename:@"videolibrary.plist"];
    [self.tableView reloadData];
}

- (IBAction)ConcatenateSelectedTakes:(id)sender
{
    VideoMerger *merger = [[VideoMerger alloc] init];
    NSLog(@"################# %lu",(unsigned long)[self.selectedItems count]);
    [merger exportVideoComposition:[merger spliceAssets:self.selectedItems]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
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


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

@end
