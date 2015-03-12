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
#import "TakesCollectionView.h"
#import "TakeCollectionViewCell.h"


@interface ScenesTableViewController ()

@property (nonatomic, strong) NSMutableArray *scenes;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;

@end

@implementation ScenesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = YES;
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    VideoLibrary *library = [VideoLibrary libraryWithFilename:@"videolibrary.plist"];
    
    if (!library)
    {
        library = [[VideoLibrary alloc] init];
        [library saveToFilename:@"videolibrary.plist"];
    }
    
    self.library = library; // For reading and writing video
    
    if (!self.selectedItems)
    {
        self.selectedItems = [NSMutableArray array];
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView registerClass:[SceneTableViewCell class] forCellReuseIdentifier:@"SceneTableViewCell"];
    [self.tableView reloadData];
    
}
//-(void) viewDidAppear:(BOOL)animated
//{
//    NSLog(@"viewDidAppear trying to recursively log some views!!!");
//    
//    [self recursivelyLogViews:self.view];
//}

//// Debugging purposes only
//-(void) recursivelyLogViews:(UIView*) view
//{
//    NSLog(@"%@ frame: (%f, %f, %f, %f)", view.class, view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
//    for (UIView* subview in view.subviews)
//    {
//        if ([subview isKindOfClass:[TakeCollectionViewCell class]])
//        {
//            NSLog(@"HEY");
//            if (subview.hidden)
//            {
//                NSLog(@"ishidden!");
//                
//            }
//            
//        }
//        [self recursivelyLogViews:subview];
//    
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
///////////////////////          \\\\\\\\\\\\\\\\\\\\\\\\\\
//////////////////////TABLE VIEW\\\\\\\\\\\\\\\\\\\\\\\\\\\\

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.library.scenes.count;
}

#pragma mark - Table View DataSOurce

// each table view cell represents a scene in the video library's scenes array
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    SceneTableViewCell *cell = (SceneTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[SceneTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;
//    cell.collectionView.tag = indexPath.row;
//    cell.addTakeButton.tag = indexPath.row;
//    Scene *scene =  self.library.scenes[indexPath.row];
//    cell.scene = self.library.scenes[indexPath.row];
//    cell.sceneTitleLabel.text = cell.scene.title;
////    if (!cell.collectionView)
////    {
////        cell.collectionView = [[TakesCollectionView alloc] init];
////    }
//
//    cell.collectionView.takes = [NSMutableArray arrayWithArray:scene.takes];
//    for (Take *take in cell.collectionView.takes)
//    {
//        
//       // TakeCollectionViewCell *cell = (TakeCollectionViewCell*)[cell.collectionView re]
//    }
//    NSLog(@"showing scene in table view: %@", cell.scene.title);
//    NSLog(@"showing scene %@", cell.scene);
//    NSLog(@"showing sceneat index: %d", indexPath.row);
//    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(SceneTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [cell setCollectionViewDataSourceDelegate:self index:indexPath.row];
    
    NSInteger index = cell.collectionView.tag;
    
    NSLog(@"Displaying tableview cell #%d", index);
    //
    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}

//-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(SceneTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    CGFloat horizontalOffset = cell.collectionView.contentOffset.x;
//    NSInteger index = cell.collectionView.rowIndexInTableView;
//    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
//}
#pragma mark - UITableViewDelegate Methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 250;
}



//////////////////////           \\\\\\\\\\\\\\\\\\\\\\\\\\\\

//////////////////////Collection View\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#pragma mark - collection view data source

-(NSInteger)collectionView:(TakesCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    Scene *scene = self.library.scenes[collectionView.tag];
    return scene.takes.count;
}

#pragma mark - collection view data source
-(UICollectionViewCell *)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TakeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    NSLog(@"index path: %@", indexPath);
    Scene *scene = self.library.scenes[collectionView.tag];

    Take *take = scene.takes[indexPath.item];
    
    
    NSLog(@"collectionView.tag: %d", collectionView.tag);
    NSLog(@"number of takes in scene.takes array = %d", scene.takes.count);
    NSLog(@"number of scenes in self.library.scenes array = %d", self.library.scenes.count);
    NSLog(@"Take : %@", take);
    
    
    //Take *take = [self.library.scenes[collectionView.tag] takes][indexPath.item];

    
    if (take)
    {
        NSLog(@"YAY TAKE IS NOT NIL      ^__^      take = %@", take);
        
        NSLog(@"YAY TAKE IS NOT NIL  /\\__ __//\   take = %@", take);
        NSLog(@"YAY TAKE IS NOT NIL  \ ''vVv'' /   take = %@", take);
        NSLog(@"YAY TAKE IS NOT NI   { <0> <0> }   take = %@", take);
        NSLog(@"YAY TAKE IS NOT NI   ={=> v <=}=   take = %@", take);
        NSLog(@"YAY TAKE IS NOT NI     \[-A-]/     take = %@", take);
        NSLog(@"YAY TAKE IS NOT NI                 take = %@", take);
    }
    
    
    [cell cellWithTake:take];
    
    return cell;
}
#pragma mark - UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isKindOfClass:[TakesCollectionView class]]) return;
    
    CGFloat horizontalOffset = scrollView.contentOffset.x;
    
    TakesCollectionView *collectionView = (TakesCollectionView *)scrollView;
    NSInteger index = collectionView.tag;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}
//////////////////////           \\\\\\\\\\\\\\\\\\\\\\\\\\\\

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
    NSLog(@"====== ScenesTableViewController.prepareForSegue()");
    
    UIButton *addTakeButton = (UIButton*)sender;
    NSLog(@"buttontag = %li", (long)addTakeButton.tag);
    
    Scene *currentScene = self.library.scenes[addTakeButton.tag];
    
    NSLog(@"currentScene is now '%@'", currentScene.title);
    
    RecordVideoViewController *recordViewController = segue.destinationViewController;
        
    recordViewController.scene = currentScene;
    
    
    NSLog(@"recordViewController.scene has been set to %@", currentScene.title);
    
    
    __weak __typeof(self) weakSelf = self;
    recordViewController.completionBlock = ^void (BOOL success)
    {
        NSLog(@"recordViewController.completionBlock()");
        if (success)
        {
            NSLog(@"saving video");
            /// dispatch to priority queue
            [weakSelf.library saveToFilename:@"videolibrary.plist"];
        }
    };

        

}



@end
