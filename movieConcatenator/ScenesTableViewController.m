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
#import "VideoMerger.h"
#import "PlayVideoViewController.h"



@interface ScenesTableViewController ()

@property (nonatomic, strong) NSMutableArray *scenes;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) UIButton *addTakeButton;

@end

@implementation ScenesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    VideoLibrary *library = [VideoLibrary libraryWithFilename:@"videolibrary.plist"];
    
    if (!library)
    {
        NSLog(@"no library");
        library = [[VideoLibrary alloc] init];
        [library saveToFilename:@"videolibrary.plist"];
    }
    self.library = library;
    self.scenes = library.scenes;
    
    if (!self.selectedItems)
    {
        self.selectedItems = [NSMutableArray array];
    }
    
    // Register the table cell
    /// only use if you did not put an identifier in the storyboard.
    [self.tableView registerClass:[SceneTableViewCell class] forCellReuseIdentifier:@"SceneTableViewCell"];
    

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
}
//-(void) viewDidAppear:(BOOL)animated
//{
//    NSLog(@"viewDidAppear trying to recursively log some views!!!");
//    
//    [self recursivelyLogViews:self.view];
//}


//-(void) recursivelyLogViews:(UIView*) view
//{
//    NSLog(@"%@ frame: (%f, %f, %f, %f)", view.class, view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
//    for (UIView* subview in view.subviews)
//    {
//    
//            if (subview.hidden)
//            {
//                NSLog(@"ishidden!");
//                
//            }
//        
//        [self recursivelyLogViews:subview];
//            
//    }
//    
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
    return [self.library.scenes count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return 1;
}

#pragma mark - Table View delegate

// each table view cell represents a scene in the video library's scenes array
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableViewCellIdentifier = @"SceneTableViewCell";
    
    SceneTableViewCell *cell=
    [tableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier];

    Scene *scene = self.library.scenes[indexPath.section];
    
    [cell setCollectionData:scene];
    
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
/*
-(void)tableView:(UITableView *)tableView willDisplayCell:(SceneTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //[cell setCollectionViewDataSourceDelegate:self index:indexPath.row];
    
    NSInteger index = cell.collectionView.tag;
    
    NSLog(@"Displaying tableview cell #%d", index);
    //
    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
    //[cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}

//-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(SceneTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    CGFloat horizontalOffset = cell.collectionView.contentOffset.x;
//    NSInteger index = cell.collectionView.rowIndexInTableView;
//    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
//}
 
*/

#pragma mark - UITableViewDelegate methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //Headerview
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 30.0)];
    headerView.backgroundColor = [UIColor blackColor];
    //headerView.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:1.0].CGColor;
    //headerView.layer.borderWidth = 1.0;
    
    // button
    self.addTakeButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [self.addTakeButton setFrame:CGRectMake(275.0, 0, 30.0, 30.0)];
    self.addTakeButton.tag = section;
    self.addTakeButton.hidden = NO;
    [self.addTakeButton setBackgroundColor:[UIColor clearColor]];
    [self.addTakeButton addTarget:self action:@selector(addTake:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [headerView addSubview:self.addTakeButton];
    
    // title
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 200, 30)];
    Scene *sectionData = self.library.scenes[section];
    headerLabel.text=sectionData.title;
    headerLabel.textColor = [UIColor whiteColor];
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView =  [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 30.0)];
    footerView.backgroundColor = [UIColor blackColor];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 30.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130.0;
}

- (IBAction)addTake:(UIButton*)sender
{
    [self performSegueWithIdentifier:@"ModallyRecordVideoSegue" sender:sender];
}
   
    //RecordVideoViewController *recordVideoVC = [[RecordVideoViewController alloc] init];
   // recordVideoVC.scene = currentScene;
    
   // NSLog(@"recordViewController.scene has been set to %@", currentScene.title);

    
    
    //[self.navigationController presentViewController:self.recordViewController animated:YES completion:^{
        
    //}];
    //[self.navigationController pushViewController:recordVideoVC animated:YES];
    
//    __weak __typeof(self) weakSelf = self;
//    self.recordViewController.completionBlock = ^void (BOOL success)
//    {
//        NSLog(@"recordViewController.completionBlock()");
//        if (success)
//        {
//            NSLog(@"saving video");
//            /// dispatch to priority queue
//            [weakSelf.library saveToFilename:@"videolibrary.plist"];
//        }
//        [weakSelf.tableView reloadData];
//        
//    };

//}


//- (void) didSelectItemFromCollectionView:(NSNotification *)notification
//{
//    NSDictionary *cellData = [notification object];
//    if (cellData)
//    {
//        if (!self.detailViewController)
//        {
//            self.detailViewController = [[ORGDetailViewController alloc] initWithNibName:@"ORGDetailViewController" bundle:nil];
//        }
//        self.detailViewController.detailItem = cellData;
//        [self.navigationController pushViewController:self.detailViewController animated:YES];
//    }
//}
//#pragma mark - UIScrollViewDelegate Methods

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if (![scrollView isKindOfClass:[UICollectionView class]]) return;
//    
//    CGFloat horizontalOffset = scrollView.contentOffset.x;
//    
//    UICollectionView *collectionView = (UICollectionView *)scrollView;
//    NSInteger index = collectionView.tag;
//    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
//}
////////////////////////           \\\\\\\\\\\\\\\\\\\\\\\\\\\\

- (IBAction)addScene:(id)sender
{
    // present a new view controller
    Scene *newScene = [[Scene alloc] init];
    newScene.title = @"New Scene";
    [self.library.scenes insertObject:newScene atIndex:0];
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
        
    [recordViewController setScene:currentScene];
    
    
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
        [self.tableView reloadData];
        
    };

}

@end
