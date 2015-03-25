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
    
    if (!self.library.selectedVideos)
    {
        self.library.selectedVideos = [NSMutableArray array];
    }
    
    // Register the table cell
    /// only use if you did not put an identifier in the storyboard.
    [self.tableView registerClass:[SceneTableViewCell class] forCellReuseIdentifier:@"SceneTableViewCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectItemFromCollectionView:) name:@"didSelectItemFromCollectionView" object:nil];
    

}
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didSelectItemFromCollectionView" object:nil];
//}

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
    [tableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier forIndexPath:indexPath];

    Scene *scene = self.library.scenes[indexPath.section];
    
    [cell setCollectionData:scene];
    

    return cell;

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
    self.addTakeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.addTakeButton setImage:[UIImage imageNamed:@"tape-64.png" ] forState:UIControlStateNormal];
    //self.addTakeButton.titleLabel.text = @"add Take";
    [self.addTakeButton setFrame:CGRectMake(275.0, 5, 50.0, 30.0)];
    self.addTakeButton.tag = section;
    self.addTakeButton.hidden = NO;
    [self.addTakeButton setBackgroundColor:[UIColor clearColor]];
    [self.addTakeButton addTarget:self action:@selector(addTakeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
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
    UIView *footerView =  [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];
    footerView.backgroundColor = [UIColor blackColor];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150.0;
}

- (IBAction)addTakeButtonPressed:(UIButton*)sender
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
//            [weakSelf.library saveToFilename:@"videolibrary.plist"];
//        }
//        [weakSelf.tableView reloadData];
//        
//    };

//}

- (void) didSelectItemFromCollectionView:(NSNotification *)notification
{

   // MPMoviePlayerViewController *mpvc = [[MPMoviePlayerViewController alloc] initWithContentURL:[notification object]];
    //[self presentMoviePlayerViewControllerAnimated:mpvc];
//    
    
    PlayVideoViewController *videoPlayerVC = [[PlayVideoViewController alloc] init];
   videoPlayerVC.takeURL = [notification object];
    if (videoPlayerVC.takeURL)
    {
        [self presentViewController:videoPlayerVC animated:YES completion:^{
            NSLog(@"Presented videoPlayerVC!!!");
        }];
    }


}

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

//release the controller.


- (IBAction)addScene:(id)sender
{
    // TO DO
    //present new view controller "ADD SCENE VIEW CONTROLLER:"
    Scene *newScene = [[Scene alloc] init];
    newScene.title = @"New Scene";
    [self.library.scenes insertObject:newScene atIndex:0];
    // do this on background thread while scene details are being added.
    [self.library saveToFilename:@"videolibrary.plist"];
    
    
    [self.tableView reloadData];
}

- (IBAction)ConcatenateSelectedTakes:(id)sender
{
    VideoMerger *merger = [[VideoMerger alloc] init];
    
    NSLog(@"################# %lu",(unsigned long)[self.library.selectedVideos count]);
    
    [merger exportVideoComposition:[merger spliceAssets:self.library.selectedVideos]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"====== ScenesTableViewController.prepareForSegue()");
    
    UIButton *addTakeButton = (UIButton*)sender;
    NSLog(@"buttontag = %li", (long)addTakeButton.tag);
    
    Scene *currentScene = self.library.scenes[addTakeButton.tag];
 
    
    RecordVideoViewController *recordViewController = segue.destinationViewController;
    [recordViewController setSceneIndex:addTakeButton.tag];
    [recordViewController setLibrary:self.library];
    [recordViewController setScene:currentScene];
    
    
    NSLog(@"recordViewController.scene has been set to %@", currentScene.title);
    
    
    __weak __typeof(self) weakSelf = self;
    recordViewController.completionBlock = ^void (BOOL success)
    {
        NSLog(@"recordViewController.completionBlock()");
        if (success)
        {
            NSLog(@"saving video");
            
            [weakSelf.library saveToFilename:@"videolibrary.plist"];
            
            
        }
        
        [self.tableView reloadData];
        
    };

}
- (IBAction)unwindToScenesView:(UIStoryboardSegue*)segue
{
    // add take stuff goes HERE!> get the file output url from the source view controller
   
    [self.tableView reloadData];
    //segue.sourceViewController.take =
    
}





@end

