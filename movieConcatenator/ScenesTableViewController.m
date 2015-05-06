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
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *concatenateButton;
@property (nonatomic, strong) PlaybackViewController *playbackViewController;
@property (nonatomic) NSInteger currentSceneIndex;

@end

@implementation ScenesTableViewController

/////****
//- (void) setUpToolbar
//{
//    //- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass
//    
//    if (activityIndicator ==nil)
//    {
//        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//        activityIndicator.hidesWhenStopped = YES;
//    }
//    [self.navigationController.toolbar setHidden:NO];
//    
//    //UIBarButtonItem *concatenatingActivityButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
//    //[concatenatingActivityButton setEnabled:NO];
//    
//    [self showConcatenatorButtonInToolbar];
//    if (self.takesToConcatenate.count <= 1)
//    {
//        [self.navigationController.toolbar.items[0] setEnabled:NO];
//    }
//}

///////*
//- (void) showConcatenatorButtonInToolbar
//{
//    if ([activityIndicator isAnimating] && activityIndicator != nil)
//        return;
//    [self.concatenateButton setEnabled:YES];
//    NSArray *items = [NSArray arrayWithObject:self.concatenateButton];
//    [self.navigationController.toolbar setItems:items animated:YES];
//}
//
//

//////////////

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self setUpToolbar];
    [self.navigationController setToolbarHidden:YES];
    self.tabBarController.delegate = self;
    if (self.takesToConcatenate == nil)
    {
        self.takesToConcatenate = [[NSMutableArray alloc] init];
    }
    
    [self tableHeader];
    
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
    
    // Register the table cell
    /// only use if you did not put an identifier in the storyboard.
    [self.tableView registerClass:[SceneTableViewCell class] forCellReuseIdentifier:@"SceneTableViewCell"];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
        selector:@selector(didSelectItemForPlayback:)
      name:@"didSelectItemForPlayback" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectStarButtonInCell:) name:@"didSelectStarButtonInCell" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
        selector:@selector(didFinishRecordingVideoToURL:) name:@"didFinishRecordingVideoToURL" object:nil];
    
//    [[NSNotificationCenter defaultCenter]
//    addObserver:self
//       selector:@selector(didStartConcatenatingVideos:) name:@"videoMergingStartedNotification" object:nil];
//    [[NSNotificationCenter defaultCenter]
//     addObserver:self
//        selector:@selector(didFinishConcatenatingVideos:) name:@"videoMergingCompletedNotification" object:nil];
    
    ///// I might be overthinking this but....
    // In the case when BestTakesViewController was not loaded yet and takes have already been selected (items have already been starred) the BestTakesVC will not get the chance to update its data source and will be empty unless it has been registered for "didSelectTake" notifications. It is added as an observer for these "didSelectStarButton..." notifications in viewDidLoad; tIt cannot receive these notifications if it has not been loaded into memory yet (since it is added as an observer in view did load) So and despite having items selected, its array will be empty therefore inconsistent with what was actually selected. so BestTakesVC must inform this view controller (ScenesTableVC) when it has loaded so it (ScenesTableVC) can copy the contents of its array of selected takes (takesToConcatenate) into the BestTakesVC's array of selected takes. This way the selected takes are consistent among all view controllers. Messy but seems like a viable solution for now.
    // alternatively, I might be able to use a shared array or singleton of some sort (maybe located in the VideoLibrary class). notification that a take has been starred -> add this to video library's array. This array can be used as the data source for the best takes view controller. deletions and reordering methods on the array can be implemented in the VideoLibrary class, and used by the bestTakesVC when these events occur.
    ///???????
    ///
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bestTakesVCDidLoad:) name:@"BestTakesVCDidLoad" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(shouldDeleteTake:)
     name:@"shouldDeleteTake" object:nil];
    
    [library listFileAtPath:[library documentsDirectory]];
    
    
    
}

//- (void) bestTakesVCDidLoad:(NSNotification*)notification
//{
//    // if no takes have been selected yet then nothing needs to be done since the selected takes are consistent already.
//    // otherwise:
//    
//    
//    if (!(self.takesToConcatenate.count == 0))
//    {
//        // get a reference to BestTakesViewController
//        self.bestTakesVC = [[self.tabBarController.viewControllers objectAtIndex:1] ];
//        
//        //self.bestTakesVC = [nc topViewController];
//        if (self.bestTakesVC.takesToConcatenate.count == 0)
//        {
//            self.bestTakesVC.takesToConcatenate = self.takesToConcatenate;
//        }
////        for (Take *take in self.takesToConcatenate)
////        {
////            [self.bestTakesVC.takesToConcatenate addObject:[take copy]];
////        }
//        
//        //[notification object].takesToConcatenate = self.takesToConcatenate;
//        
//        
//    }
//}
- (void) tableHeader
{
    UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.tableView.frame.size.width,kHeaderSectionHeight)];
    tableHeader.backgroundColor = [UIColor blackColor];
    self._tableView.tableHeaderView = tableHeader;

}

- (void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
    
    //self.bestTakesVC = (BestTakesViewController*)viewController;
    
    UINavigationController *nc = (UINavigationController*)viewController;
    self.bestTakesVC = [nc.viewControllers firstObject];
    if (self.bestTakesVC.takesToConcatenate == nil)
    {
        self.bestTakesVC.takesToConcatenate = [[NSArray alloc] initWithArray:self.takesToConcatenate copyItems:YES];
    }
    
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //[self.library listScenesAndTakes];
//    BestTakesViewController *bestTakesVC = [self.tabBarController.viewControllers objectAtIndex:1];
//    if (bestTakesVC.takesToConcatenate == nil)
//    {
//        bestTakesVC.takesToConcatenate = [[NSArray alloc] initWithArray:self.takesToConcatenate copyItems:YES];
//         UINavigationController *nc = (UINavigationController*)[self.tabBarController.viewControllers objectAtIndex:0];
//    }
    ///***
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"shouldDeleteTake" object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"didSelectStrButtonInCell" object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self.library listScenesAndTakes];
    
    [self._tableView reloadData];
}

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

    if (!cell)
    {
        cell = [[SceneTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableViewCellIdentifier];
        cell.tag = indexPath.section;
    }
    
    //Scene *scene = self.scenes[indexPath.section];
    //[cell setCollectionData:scene];
    ///////>>>>>>>>>>>>>>>>>>>>>

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


#pragma mark - UITableView Delegate methods

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
//    headerView.layer.borderColor = [UIColor whiteColor].CGColor;
//    headerView.layer.cornerRadius = 2.0;
//    headerView.layer.borderWidth = 3.0;
   
    
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
    headerLabel.textColor = [UIColor whiteColor];
    
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (void)showTakesInScene:(UIButton*)sender
{
   // [sender setSelected:YES];
    [sender setHighlighted:YES];
 
    self.currentSceneIndex = sender.tag;

    [self performSegueWithIdentifier:@"ShowTakesViewController" sender:sender];

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


/////****
//- (IBAction)ConcatenateSelectedTakes:(id)sender
//{
//    VideoMerger *merger = [[VideoMerger alloc]init];
//    NSLog(@"Number of items in array: %lu",(unsigned long)[self.takesToConcatenate count]);
//    if (self.takesToConcatenate.count > 1)
//    {
//        [merger exportVideoComposition:[merger spliceAssets:self.takesToConcatenate]];
//    }
//    else
//    {
//        NSLog(@"Please select more than one video.");
//    }
//}

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
///////******
- (void) didSelectStarButtonInCell:(NSNotification*)notification
{
//    if (!self.takesToConcatenate)
//    {
//        self.takesToConcatenate = [NSMutableArray array];
//    }
//    if (self.takesToConcatenate.count >= 2)
//    {
//        NSLog(@"self.takesToConcatenate = %lu", (unsigned long)[self.takesToConcatenate count]);
//        [self.concatenateButton setEnabled:YES];
//        //[self.navigationController.toolbar.items[0] setEnabled:YES];
//    }
//    else if (self.takesToConcatenate.count < 2)
//    {
//        [self.concatenateButton setEnabled:NO];
//        [self.navigationController.toolbar.items[0] setEnabled:NO];
//    }
//   
    
    
    Take *take = [notification object];
    
    if (take.isSelected && ![self.takesToConcatenate containsObject:take])
    {
        [self.takesToConcatenate addObject:take];
    }
    else if (!take.isSelected && [self.takesToConcatenate containsObject:take])
    {
        [self.takesToConcatenate removeObject:take];
    }
}
//////*****
//- (void) didStartConcatenatingVideos:(NSNotification*)notification
//{
//    NSLog(@"video merging starting?");
//    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    // if concatenation finished successfully, stop animating the view, hide it from the toolbar and re-enable the concatenate button so another video can be merged.
//    if (activityIndicator.isAnimating == YES) return;
//    
//    [activityIndicator startAnimating];
//    
//    // right now only the concatenator button should be showing in the toolbar
//    // so disable it
//    [self.concatenateButton setEnabled:NO];
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
//    NSArray *items = [NSArray arrayWithObject:item];
//    // show activity indicator in the toolbar instead
//    [self.navigationController.toolbar setItems:items animated:YES];
//    
//}
//////*****
//- (void) didFinishConcatenatingVideos:(NSNotification*)notification
//{
//    if (activityIndicator.isAnimating==NO) return;
//    
//    NSLog(@"Will be stopping animation");
//    
//    [activityIndicator stopAnimating];
//
//    [self showConcatenatorButtonInToolbar];
//    //[self.navigationController.toolbarItems[0] setHidden:NO];
//    
//    for (int i=0; i<self.takesToConcatenate.count; i++)
//    {
//        [self.takesToConcatenate[i] setSelected:NO];
//    }
//    
//    
//    //[self.takesToConcatenate removeAllObjects];
//    self.takesToConcatenate = nil;
//}

- (void) didFinishRecordingVideoToURL:(NSNotification*)notification
{
    ///[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_currentSceneIndex] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    __weak __typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       Take *newTake = [[Take alloc] initWithURL:notification.object];
                       newTake.sceneNumber = _currentSceneIndex;
                       
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

