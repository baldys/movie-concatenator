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
#import "NewSceneDetailsViewController.h"
#import "TakesViewController.h"
#import "PlaybackViewController.h"

#define kHeaderSectionHeight 32
#define kTableCellHeight     98

@interface ScenesTableViewController () <TakeCellDelegate, UITabBarControllerDelegate>
{
    UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, strong) NSMutableArray *scenes;
@property (weak, nonatomic) IBOutlet UITableView *_tableView;
@property (nonatomic, strong) PlaybackViewController *playbackViewController;
@property (nonatomic) NSInteger currentSceneIndex;

@end

@implementation ScenesTableViewController

#pragma mark - UIView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setToolbarHidden:YES];
    
    self.tabBarController.delegate = self;
    
    if (self.takesToConcatenate == nil)
    {
        self.takesToConcatenate = [[NSMutableArray alloc] init];
    }
    
    UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.tableView.frame.size.width,kHeaderSectionHeight)];
    tableHeader.backgroundColor = [UIColor blackColor];
    self._tableView.tableHeaderView = tableHeader;
    
    VideoLibrary *library = [VideoLibrary libraryWithFilename:@"videolibrary.plist"];
    
    if (!library)
    {
        NSLog(@"no library");
        library = [[VideoLibrary alloc] init];
        [library saveToFilename:@"videolibrary.plist"];
    }
    self.library = library;
    self.scenes = library.scenes;
    
    // Register the table cell
    /// only use if you did not put an identifier in the storyboard.
    [self.tableView registerClass:[SceneTableViewCell class] forCellReuseIdentifier:@"SceneTableViewCell"];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
        selector:@selector(didSelectItemForPlayback:)
            name:@"didSelectItemForPlayback" object:nil];
    [[NSNotificationCenter defaultCenter]
    addObserver:self
       selector:@selector(didSelectStarButtonInCell:)
           name:@"didSelectStarButtonInCell" object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
        selector:@selector(didFinishRecordingVideoToURL:) name:@"didFinishRecordingVideoToURL" object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
        selector:@selector(shouldDeleteTake:)
            name:@"shouldDeleteTake" object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
        selector:@selector(clearTakesToConcatenate:) name:@"videoMergingCompletedNotification" object:nil];
    
    [library listFileAtPath:[library documentsDirectory]];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    ///***
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"shouldDeleteTake" object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"didSelectStrButtonInCell" object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self.library listScenesAndTakes];
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self._tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TabBarController Delegate
- (void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
    
    //self.bestTakesVC = (BestTakesViewController*)viewController;
    
    UINavigationController *nc = (UINavigationController*)viewController;
    self.bestTakesVC = [nc.viewControllers firstObject];
    if (self.bestTakesVC.takesToConcatenate == nil && !self.bestTakesVC.isViewLoaded)
    {
        self.bestTakesVC.takesToConcatenate = [[NSMutableArray alloc] initWithArray:self.takesToConcatenate];
    }
    
    
}



#pragma mark - TableView data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.library.scenes count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return 1;
}

#pragma mark - TableView delegate

// each table view cell represents a scene in the video library's scenes array
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableViewCellIdentifier = @"SceneTableViewCell";
    
    SceneTableViewCell *cell=
    [tableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier forIndexPath:indexPath];

    if (!cell)
    {
        cell = [[SceneTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableViewCellIdentifier];
        cell.tag = indexPath.section;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       Scene *scene = self.scenes[indexPath.section];
                       scene.libraryIndex = indexPath.section;
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [cell setCollectionData:scene];
                       });
                   });
    return cell;
}

//// Dark blue RGB % .129, .129, .51
///
///

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{

    UIImage *buttonImage = [UIImage imageNamed:@"disclosure-white"];
    
    //Headerview
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0.0,0.0,tableView.frame.size.width,kHeaderSectionHeight)];
    
    //headerView.backgroundColor = [UIColor colorWithRed:0.129 green:0.129 blue:0.51 alpha:1.0];
    headerView.backgroundColor = [UIColor blackColor];
    UIButton *sceneHeaderButton = [[UIButton alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width-40, 0, 40, kHeaderSectionHeight)];
    [sceneHeaderButton setImage:buttonImage forState:UIControlStateNormal];
    
    sceneHeaderButton.tag = section;
    
    [sceneHeaderButton addTarget:self action:@selector(showTakesInScene:) forControlEvents:UIControlEventTouchUpInside];
    
    sceneHeaderButton.showsTouchWhenHighlighted = YES;
    // these compress and stretch the button accordingly:
    [sceneHeaderButton setImageEdgeInsets:UIEdgeInsetsMake(5,12,5,12)];

    //[sceneHeaderButton setImage:[UIImage imageNamed:@"highlighted-white-disclosure-indicator-64"] forState:UIControlStateSelected];
    
    //sceneHeaderButton.backgroundColor = [UIColor colorWithRed:0 green:0.7583 blue:1.0 alpha:1.0];
    //UIColor *bg2 = [UIColor colorWithRed:0 green:greenLevel2 blue:1.0 alpha:1.0];
    //headerView.layer.borderColor = [UIColor colorWithRed:0.2510 green:0 blue:1.0 alpha:1.0].CGColor;
    [headerView addSubview:sceneHeaderButton];
    

    //// borders for section header.

//    headerView.layer.borderColor = [UIColor colorWithRed:0 green:0.7176 blue:1.0 alpha:1.0].CGColor;
//  headerView.layer.cornerRadius = 2.0;
//    headerView.layer.borderWidth = 0.3;
//   
    
    //camera2-4.png    simple vid camera icon
    // camera2.png
    // ffffff-clapperboard-48.png
    //video-camera-1.png  vid camera with more deatils
    //noun_101983.png 
    // button
    //self.addTakeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //[self.addTakeButton setImage:[UIImage imageNamed:@"video-camera2d.png"] forState:UIControlStateNormal];
    //[self.addTakeButton setTintColor:[UIColor whiteColor]];
    //[self.addTakeButton setTitle:@"Add Take" forState:UIControlStateNormal];
    //[self.addTakeButton setTintColor:[UIColor yellowColor]];
    //[self.addTakeButton title:[UIColor colorWithRed:0.0 green:0.7176 blue:1.0]];

    
    //self.addTakeButton.hidden = NO;
    //[self.addTakeButton setBackgroundColor:[UIColor purpleColor]];
    //[self.addTakeButton addTarget:self action:@selector(addTakeButtonPressed:) //forControlEvents:UIControlEventTouchUpInside];
    //[headerView addSubview:self.addTakeButton];
    
    // title
    UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(12,0,self.tableView.frame.size.width-40,kHeaderSectionHeight)];
    Scene *sectionData = self.library.scenes[section];

    
    headerLabel.text = sectionData.title;
    
    headerLabel.font = [UIFont boldSystemFontOfSize:20];
    headerLabel.textColor = [UIColor colorWithRed:0 green:0.7176 blue:1.0 alpha:1.0];
    
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, kHeaderSectionHeight)];
    footerView.backgroundColor = [UIColor blackColor];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeaderSectionHeight;
}
/////
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kHeaderSectionHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableCellHeight;
}



//- (IBAction)addTakeButtonPressed:(UIButton*)sender
//{
//    
//    self.sceneIndexForNewTake =sender.tag;
//    NSLog(@"sender.tag = %ld", (long)sender.tag);
//    [self performSegueWithIdentifier:@"recordATake" sender:sender];
//    
//}

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

- (void)showTakesInScene:(UIButton*)sender
{
    // [sender setSelected:YES];
    [sender setHighlighted:YES];
    
    self.currentSceneIndex = sender.tag;
    
    [self performSegueWithIdentifier:@"ShowTakesViewController" sender:sender];
    
}


#pragma mark - Notifications

- (void)shouldDeleteTake:(NSNotification*)notification
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSLog(@"scene number of take: %ld", (long)[notification.object sceneNumber]);
                       [self.library deleteTake:notification.object fromSceneAtIndex:[notification.object sceneNumber]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self._tableView reloadData];
                       });
                   });
}

- (void) didSelectItemForPlayback:(NSNotification*)notification
{
    [self performSegueWithIdentifier:@"showPlayback" sender:[notification object]];
}

- (void) didSelectStarButtonInCell:(NSNotification*)notification
{
    Take *take = [notification object];
    
    if (take.isSelected && ![self.takesToConcatenate containsObject:take])
    {
        [self.takesToConcatenate addObject:take];
    }
    else if (!take.isSelected && [self.takesToConcatenate containsObject:take])
    {
        [self.takesToConcatenate removeObject:take];
    }
    [self updateBadgeValue];
}

- (void) updateBadgeValue
{
    NSString *badgeValue = [NSString stringWithFormat:@"%d", self.takesToConcatenate.count];
    [[[self.tabBarController.viewControllers objectAtIndex:1] tabBarItem] setBadgeValue:badgeValue];
}

- (void)clearTakesToConcatenate:(NSNotification*)notification
{
    [self.takesToConcatenate removeAllObjects];
    [self updateBadgeValue];
    
}

- (void) didFinishRecordingVideoToURL:(NSNotification*)notification
{
    ///[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_currentSceneIndex] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    __weak __typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       Take *newTake = [[Take alloc] initWithURL:notification.object];
                       newTake.sceneNumber = _currentSceneIndex;
                       
                       newTake.videoLandscapeLeft = (BOOL)[[notification userInfo] objectForKey:@"videoOrientation"];
                       newTake.frontFacingVideo = (BOOL)[[notification userInfo] objectForKey:@"videoDevicePosition"];
                       
                       [[weakSelf.library.scenes[_currentSceneIndex] takes] addObject:newTake];
                       [weakSelf.library saveToFilename:@"videolibrary.plist"];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           [weakSelf._tableView reloadData];
                       });
                   });
}

# pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"ShowTakesViewController"])
    {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        TakesViewController *takesVC = (TakesViewController *)navController.topViewController;
        // set the scene from the index of the header button that was clicked
        Scene *scene = self.library.scenes[self.currentSceneIndex];
        
        NSLog(@"scene title: %@", [self.library.scenes[self.currentSceneIndex] title]);
        
        scene.libraryIndex = self.currentSceneIndex;
        takesVC.scene = [[Scene alloc] init];
        [takesVC setScene:scene];
        

    }
 
    else if ([segue.identifier isEqualToString:@"showVideo"])
    {
        UINavigationController *navController = (UINavigationController*)segue.destinationViewController;
        PlayVideoViewController *playVideoVC = (PlayVideoViewController*)navController.topViewController;
        playVideoVC.takeToPlay = sender;
        
    }
    else if ([segue.identifier isEqualToString:@"showPlayback"])
    {
//        UINavigationController *navController = (UINavigationController*)segue.destinationViewController;
//        PlaybackViewController *playbackVC = (PlaybackViewController*)navController.topViewController;
//        
        PlaybackViewController *playbackVC = (PlaybackViewController*)segue.destinationViewController;
        //playbackVC.takeToPlay = [[Take alloc] init ];
        [playbackVC setTakeToPlay:sender];
        //[playbackVC setURL:[sender getPathURL]];
    }
}

- (IBAction)unwindToScenesView:(UIStoryboardSegue*)segue
{
    NSLog(@"unwind segue callled");
    // add take stuff goes HERE!> get the file output url from the source view controller

    NewSceneDetailsViewController *nsdvc = (NewSceneDetailsViewController*)[segue sourceViewController];
    
    if (nsdvc.scene.title == nil) return;
    
    [self.library addScene:nsdvc.scene];
    __weak __typeof(self) weakSelf = self;
    self.library.completionBlock = ^void (BOOL success)
    {
        if (success)
        {
            NSLog(@"saving video");
            [weakSelf.library saveToFilename:@"videolibrary.plist"];
        }
//            //        [weakSelf.tableView reloadData];
        NSLog(@"completion block called!");
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf._tableView reloadData];
            //[weakSelf._tableView insertSections:[NSIndexSet indexSetWithIndex:weakSelf.library.scenes.count] withRowAnimation:UITableViewRowAnimationAutomatic ];
            //NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:weakSelf.library.scenes.count];
            //[weakSelf._tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
        });
        
        
    };
    
}

// TO DO:
////

//    Scene *currentScene = self.library.scenes[self.segue.destinationViewController.sceneIndex];
    
//    Take *newTake = [[Take alloc] initWithURL:segue.destinatiooutputFileURL];
//    [currentScene.takes insertObject:newTake atIndex:0];
//    [self.library saveToFilename:@"videolibrary.plist"];
    //[self.tableView reloadData];
    

//        RecordVideoViewController *recordViewController = segue.sourceViewController;
//        if (segue.sourceViewController.outputFileURL == nil)
//        {
//            return;
//        }
    
//       __weak __typeof(self) weakSelf = self;
//        recordViewController.completionBlock = ^void (BOOL success)
//        {
//            NSLog(@"recordViewController.completionBlock()");
//            if (success)
//            {
//                NSLog(@"saving video");
//                [weakSelf.library saveToFilename:@"videolibrary.plist"];
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.tableView reloadData];
//                });
//            }
//        };
    
    
    
    // cancel was pressed/ no take should be created. delete item at the url it recorded the video to if it exists.
   
    

//    Take *newTake = [[Take alloc] initWithURL:recordViewController.outputFileURL];
//    [[self.scenes[recordViewController.sceneIndex] takes] addObject:newTake];

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self.library saveToFilename:@"videolibrary.plist"];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableView reloadData];
//        });
//    });
//
    
//    };
    


//
// // Override to support conditional editing of the table view.




@end

