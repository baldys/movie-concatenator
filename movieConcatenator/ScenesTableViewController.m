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
#import "CompositionsViewController.h"

#define kHeaderSectionHeight 48
#define kTableCellHeight     136
// cell dimensions: 136x136
// image in cell dimensions: 128x128
@interface ScenesTableViewController () <TakeCellDelegate, UITabBarControllerDelegate>
{
    UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, strong) NSMutableArray *scenes;
@property (weak, nonatomic) IBOutlet UITableView *_tableView;
@property (nonatomic, strong) PlaybackViewController *playbackViewController;
@property (nonatomic, strong) CompositionsViewController *editedVideosVC;
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
    
    VideoLibrary *library = [VideoLibrary libraryWithFilename:@"VideoDatalist.plist"];
    
    if (!library)
    {
        NSLog(@"no library");
        library = [[VideoLibrary alloc] init];
        [library saveToFilename:@"VideoDatalist.plist"];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showVideoCamera:) name:@"showVideoCamera" object:nil];
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
    [self.tabBarController.tabBar setHidden:NO];
    [self.tabBarItem setSelectedImage:[UIImage imageNamed:@"Clapper-Board-48-10_white.png"]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TabBarController Delegate
- (void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSLog(@" %@, %ld",viewController.tabBarItem.title,(long)viewController.tabBarItem.tag);

    if (viewController.tabBarItem.tag == 0)
    {
        [viewController.tabBarItem setSelectedImage:[UIImage imageNamed:@"Clapper-Board-48-10_white.png"]];
    }
    else if (viewController.tabBarItem.tag == 1)
    {
        [viewController.tabBarItem setSelectedImage:[UIImage imageNamed:@"Favorites-48.png"]];
        
        UINavigationController *nc = (UINavigationController*)viewController;
        self.bestTakesVC = [nc.viewControllers firstObject];
        if (self.bestTakesVC.takesToConcatenate == nil && !self.bestTakesVC.isViewLoaded)
        {
            self.bestTakesVC.takesToConcatenate = [[NSMutableArray alloc] initWithArray:self.takesToConcatenate];
        }
    }
    else if (viewController.tabBarItem.tag == 2)
    {
        [viewController.tabBarItem setSelectedImage:[UIImage imageNamed:@"Film-Reel-01-48-4.png"]];
        UINavigationController *nc = (UINavigationController*)viewController;
        self.editedVideosVC = [nc.viewControllers firstObject];
        
        //(EditedVideosViewController*)viewController;
        if (self.editedVideosVC.videoCompositions == nil && !self.editedVideosVC.isViewLoaded)
        {
            if (self.library.videoCompositions.count > 0)
            {
            
            self.editedVideosVC.videoCompositions = [[NSMutableArray alloc] initWithArray:self.library.videoCompositions];
//                [self.editedVideosVC setVideoCompositions:self.library.videoCompositions];
            //}
            }
        }
        
    
    }
    
    
    
    
    //UINavigationController *nc = (UINavigationController*)viewController;
    //if ([nc.viewControllers[0] isKindOfClass:[self.bestTakesVC class]])
    
    //self.bestTakesVC = (BestTakesViewController*)viewController;
    

    
    
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
        
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       Scene *scene = self.scenes[indexPath.section];
                       scene.libraryIndex = indexPath.section;
                       dispatch_async(dispatch_get_main_queue(), ^{
                           //cell.scene = scene;
                           //cell.tag = indexPath.section;
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

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = CGRectGetWidth(screenRect);
    
    //UIImage *buttonImage = [UIImage imageNamed:@"disclosure-white"];
    
    //Headerview
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0.0,0.0,tableView.frame.size.width,kHeaderSectionHeight)];
    

    headerView.backgroundColor = [UIColor clearColor];
    //[UIColor colorWithRed:0.123 green:0.7583 blue:1.0 alpha:0.4];
    
    //headerView.backgroundColor = [UIColor blackColor];
    UIButton *sceneHeaderButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, screenWidth , kHeaderSectionHeight)];
    
    //[sceneHeaderButton setImage:buttonImage forState:UIControlStateNormal];
    sceneHeaderButton.backgroundColor = [UIColor clearColor];
    sceneHeaderButton.tag = section;
    
    [sceneHeaderButton addTarget:self action:@selector(showTakesInScene:) forControlEvents:UIControlEventTouchUpInside];
    
    //sceneHeaderButton.showsTouchWhenHighlighted = YES;
    
    // these compress and stretch the button accordingly:
    [sceneHeaderButton setImageEdgeInsets:UIEdgeInsetsMake(5,12,5,12)];

    
 
    //sceneHeaderButton.backgroundColor =
    //UIColor *bg2 = [UIColor colorWithRed:0 green:greenLevel2 blue:1.0 alpha:1.0];
    //headerView.layer.borderColor = [UIColor colorWithRed:0.2510 green:0 blue:1.0 alpha:1.0].CGColor;
    [headerView addSubview:sceneHeaderButton];
    

    //// borders for section header.


    headerView.layer.borderColor = [UIColor colorWithRed:0 green:0.7176 blue:1.0 alpha:1.0].CGColor;
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
    UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(12,0,self.tableView.frame.size.width,kHeaderSectionHeight)];
    Scene *sectionData = self.library.scenes[section];

    
    headerLabel.text = sectionData.title;
    
    headerLabel.font = [UIFont boldSystemFontOfSize:20];
    //headerLabel.textColor = [UIColor colorWithRed:0 green:0.7176 blue:1.0 alpha:1.0];
    headerLabel.textColor = [UIColor colorWithRed:0.0 green:0.827 blue:1.0 alpha:1.0];
    
    [headerView addSubview:headerLabel];
    //[sceneHeaderButton addSubview:headerLabel];
    return headerView;
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, kHeaderSectionHeight)];
    footerView.backgroundColor = [UIColor clearColor];
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
//            [weakSelf.library saveToFilename:@"VideoDatalist.plist"];
//        }
//        [weakSelf.tableView reloadData];
//        
//    };

//}

- (void)showTakesInScene:(UIButton*)sender
{
    // [sender setSelected:YES];
    [sender setHighlighted:YES];
    
    
    
    [self performSegueWithIdentifier:@"ShowTakesViewController" sender:sender];
    
}

- (void)showVideoCamera:(NSNotification*)notification
{
    Scene *sceneToAddTake = [notification object];
    self.currentSceneIndex = sceneToAddTake.libraryIndex;
    NSLog(@"current scene index: %i", self.currentSceneIndex);
    [self performSegueWithIdentifier:@"showVideoCamera" sender:sceneToAddTake];
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
    Take *take = notification.object;
    
    
    
    self.currentSceneIndex = take.sceneNumber;
    
    NSLog(@"did select item for playback: currentSceneIndex: %i", self.currentSceneIndex);
  

    
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
    NSString *badgeValue = [NSString stringWithFormat:@"%lu", (unsigned long)self.takesToConcatenate.count];
    [[[self.tabBarController.viewControllers objectAtIndex:1] tabBarItem] setBadgeValue:badgeValue];
}

- (void)clearTakesToConcatenate:(NSNotification*)notification
{
    [self.takesToConcatenate removeAllObjects];
    [self updateBadgeValue];
    
}

- (void) didFinishRecordingVideoToURL:(NSNotification*)notification
{
    
    __weak __typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       Take *newTake = [[Take alloc] initWithURL:notification.object];
                       newTake.sceneNumber = _currentSceneIndex;
                       
                       NSString *videoOrientationString = [[notification userInfo] objectForKey:@"videoOrientation"];
                       NSString *videoPositionString = [[notification userInfo] objectForKey:@"videoPosition"];
                       if ([videoOrientationString isEqualToString:@"LandscapeLeft"]&&[videoPositionString isEqualToString:@"Back"])
                       {
                           newTake.videoOrientationAndPosition = LandscapeLeft_Back;
                       }
                       else if ([videoOrientationString isEqualToString:@"LandscapeLeft"]&&[videoPositionString isEqualToString:@"Front"])
                       {
                           newTake.videoOrientationAndPosition = LandscapeLeft_Front;
                           
                       }
                       else if ([videoOrientationString isEqualToString:@"LandscapeRight"] && [videoPositionString isEqualToString:@"Back"])
                       {
                           newTake.videoOrientationAndPosition = LandscapeRight_Back;
                           
                       }
                       else if ([videoOrientationString isEqualToString:@"LandscapeRight"]&&[videoPositionString isEqualToString:@"Front"])
                       {
                           newTake.videoOrientationAndPosition = LandscapeRight_Front;
                       }
                       else
                       {
                           //newTake.videoOrientationAndPosition = None;
                           NSLog(@"something is wrong wtf!!");
                       }

                       [[weakSelf.library.scenes[_currentSceneIndex] takes] addObject:newTake];
                       
                       newTake.sceneTitle = [weakSelf.library.scenes[_currentSceneIndex]title];
                       NSLog(@"new take is in scene with title: %@", newTake.sceneTitle);
                       
                       
                       [weakSelf.library saveToFilename:@"VideoDatalist.plist"];
                       
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
 
    else if ([segue.identifier isEqualToString:@"showPlayback"])
    {

        PlaybackViewController *playbackVC = (PlaybackViewController*)segue.destinationViewController;
        ///// later: set it to play the collection of takes in a scene (array of AVPlayerItems)
        [playbackVC setTakeToPlay:sender];
        Scene *sceneContainingTakeForPlayback = self.library.scenes[self.currentSceneIndex];
        [playbackVC setTakeQueue:sceneContainingTakeForPlayback.takes];
        
    }
    else if ([segue.identifier isEqualToString:@"showVideoCamera"])
    {
        [self.tabBarController.tabBar setHidden:YES];
    }
}

- (IBAction)unwindToScenesView:(UIStoryboardSegue*)segue
{
    NSLog(@"unwind segue callled");

    NewSceneDetailsViewController *nsdvc = (NewSceneDetailsViewController*)[segue sourceViewController];
    
    if (nsdvc.scene.title == nil) return;
    
    [self.library addScene:nsdvc.scene];
    __weak __typeof(self) weakSelf = self;
    self.library.completionBlock = ^void (BOOL success)
    {
        if (success)
        {
            //NSLog(@"saving video");
            [weakSelf.library saveToFilename:@"VideoDatalist.plist"];
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

- (IBAction)unwindFromVideoCamera:(UIStoryboardSegue*)segue
{
    [self.tabBarController.tabBar setHidden:NO];
}


// TO DO:
////

//    Scene *currentScene = self.library.scenes[self.segue.destinationViewController.sceneIndex];
    
//    Take *newTake = [[Take alloc] initWithURL:segue.destinatiooutputFileURL];
//    [currentScene.takes insertObject:newTake atIndex:0];
//    [self.library saveToFilename:@"VideoDatalist.plist"];
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
//                [weakSelf.library saveToFilename:@"VideoDatalist.plist"];
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
//        [self.library saveToFilename:@"VideoDatalist.plist"];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableView reloadData];
//        });
//    });
//
    
//    };
    


//
// // Override to support conditional editing of the table view.




@end

