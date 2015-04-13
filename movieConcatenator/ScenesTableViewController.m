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

#define kHeaderSectionHeight 32
#define kTableCellHeight     90

@interface ScenesTableViewController () <TakeCellDelegate>
{
    UIActivityIndicatorView *activityIndicator;
}
@property (nonatomic, strong) NSMutableArray *scenes;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) UIButton *addTakeButton;
@property (nonatomic) NSInteger currentSceneIndex;



@end

@implementation ScenesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // self.navigationItem.leftBarButtonItem = self.editButtonItem;
    /// self.library =
    /// self.library = [VideoLibrary libraryWithFilename:@:videolibrary.plist];
    /// if (!self.library)
    ///{
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
        selector:@selector(didSelectItemFromCollectionView:)
            name:@"didSelectItemFromCollectionView" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didSelectStarButtonInCell:) name:@"didSelectStarButtonInCell" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishRecordingVideoToURL:) name:@"didFinishRecordingVideoToURL" object:nil];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishJoiningVideos:) name:@"didFinishJoiningVideos" object:nil];
    
    if (!self.takesToConcatenate)
    {
        self.takesToConcatenate = [NSMutableArray array];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"didSelectItemFromCollectionView" object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"didSelectStrButtonInCell" object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
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

    //Scene *scene = self.scenes[indexPath.section];
    //[cell setCollectionData:scene];
    ///////>>>>>>>>>>>>>>>>>>>>>
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        Scene *scene = self.scenes[indexPath.section];
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell setCollectionData:scene];
        });
        
    });

    return cell;
}

//// Dark blue RGB % 12.9, 12.9, 51
///
///


#pragma mark - UITableView Delegate methods

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
   // UIEdgeInsets buttonPadding = UIEdgeInsetsMake(2,8,2,8);
    
    UIImage *buttonImage = [UIImage imageNamed:@"disclosure"];
    
    //Headerview
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0.0,0.0,tableView.frame.size.width,kHeaderSectionHeight)];
    headerView.backgroundColor = [UIColor colorWithRed:0.129 green:0.129 blue:0.51 alpha:1.0];
    
     UIButton *sceneHeaderButton = [[UIButton alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width-40, 0, 40, kHeaderSectionHeight)];
    // img 25 width 40 height. make buttons 40x40 clickable portion).
    [sceneHeaderButton setImage:buttonImage forState:UIControlStateNormal];
    
    sceneHeaderButton.tag = section;
    
    [sceneHeaderButton addTarget:self action:@selector(showTakesInScene:) forControlEvents:UIControlEventTouchUpInside];
    
    sceneHeaderButton.showsTouchWhenHighlighted = YES;
    // these compress and stretch the button accordingly:
    [sceneHeaderButton setImageEdgeInsets:UIEdgeInsetsMake(5,12,5,12)];
    
    //UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"white-disclosure-indicator-64.png"] highlightedImage:[UIImage imageNamed:@"highlighted-white-disclosure-indicator-64"]];
    //[sceneHeaderButton addSubview:imageView];
    
    
                                                                              
    
    //[sceneHeaderButton setImage:[UIImage imageNamed:@"highlighted-white-disclosure-indicator-64"] forState:UIControlStateSelected];
    //[sceneHeaderButton.imageView setFrame:CGRectMake(self.tableView.frame.size.width-32, 0, 32, 32)];
    //sceneHeaderButton.adjustsImageWhenHighlighted = YES;
    
    
    
    
    
    //sceneHeaderButton.backgroundColor = [UIColor colorWithRed:0 green:0.7583 blue:1.0 alpha:1.0];

    [headerView addSubview:sceneHeaderButton];
    
    //UIColor *bg2 = [UIColor colorWithRed:0 green:greenLevel2 blue:1.0 alpha:1.0];
   //headerView.layer.borderColor = [UIColor colorWithRed:0.2510 green:0 blue:1.0 alpha:1.0].CGColor;
    
    //// borders for section header.
    //headerView.layer.borderColor = [UIColor blackColor].CGColor;
    //headerView.layer.cornerRadius = 2.0;
    //headerView.layer.borderWidth = 5.0;
   
    
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
    //[self.addTakeButton setFrame:CGRectMake(self.tableView.frame.size.width-40,0,40,kHeaderSectionHeight)];
    //[self.addTakeButton setImageEdgeInsets:UIEdgeInsetsMake(2,5,2,5)];
    //self.addTakeButton.tag = section;
    //self.addTakeButton.hidden = NO;
    //[self.addTakeButton setBackgroundColor:[UIColor purpleColor]];
    //[self.addTakeButton addTarget:self action:@selector(addTakeButtonPressed:) //forControlEvents:UIControlEventTouchUpInside];
    //[headerView addSubview:self.addTakeButton];
    
    // title
    UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(12,0,self.tableView.frame.size.width-40,kHeaderSectionHeight)];
    Scene *sectionData = self.library.scenes[section];
    headerLabel.text = sectionData.title;
    //headerLabel.minimumScaleFactor = 1.2;
    [headerLabel.font fontWithSize:22];
    headerLabel.textColor = [UIColor blackColor];
    
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (IBAction)showTakesInScene:(UIButton*)sender
{
   // [sender setSelected:YES];
    [sender setHighlighted:YES];
 
    self.currentSceneIndex = sender.tag;
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectHeaderButtonInScene" object:scene];
    //[self.navigationController pushViewController:takesVC animated:YES];
    [self performSegueWithIdentifier:@"ShowTakesViewController" sender:sender];
    

}
/////
- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, 0, 0)];
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
    return 0;
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

- (void) didSelectItemFromCollectionView:(NSNotification*)notification
{
    PlayVideoViewController *videoPlayerVC = [[PlayVideoViewController alloc]init];

   videoPlayerVC.takeURL = [notification object];
    if (videoPlayerVC.takeURL)
    {
        //UINavigationController *navcont = [[UINavigationController alloc] initWithRootViewController:self];
        [self presentViewController:videoPlayerVC animated:YES completion:^{
            NSLog(@"Presented videoPlayerVC!!!");
        }];
    }
}

- (void) didSelectStarButtonInCell:(NSNotification*)notification
{
    Take *take = [notification object];

    if (take.isSelected && ![self.takesToConcatenate containsObject:take])
    {
        [self.takesToConcatenate addObject:take];
        NSLog(@"take is selected but does not contain object %@", take.assetID);
                
    }
    else if (!take.isSelected && [self.takesToConcatenate containsObject:take])
    {
        [self.takesToConcatenate removeObject:take];
    }


}

- (IBAction)ConcatenateSelectedTakes:(id)sender
{
    
    VideoMerger *merger = [[VideoMerger alloc]init];
    
    NSLog(@"################# number of items in  %lu",(unsigned long)[self.takesToConcatenate count]);
    if (self.takesToConcatenate.count > 1)
    {
        
        [merger exportVideoComposition:[merger spliceAssets:self.takesToConcatenate]];
        self.takesToConcatenate = nil;
        [self showActivityIndicator];
        
    }
    else
    {
        NSLog(@"one or fewer videos were selected");

    }
    
    
    
}

- (void) showActivityIndicator
{
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator startAnimating];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    NSArray *items = [[NSArray alloc] initWithObjects:item, nil];
    [self.navigationController.toolbar setItems:items];
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
        
        
        
        //[takesVC configureTableViewWithScene:scene];

        
        //asvc.sceneData = sceneToAdd;
        //asvc.sceneNumberField.text: self.scenes.count;

//        else if ([segue.identifier isEqualToString:@"recordATake"])
//        {
//        }
    }
    
       // UIButton *addTakeButton = (UIButton*)sender;
        //NSLog(@"buttontag = %li", (long)addTakeButton.tag);
        //self.sceneIndexForNewTake = addTakeButton.tag;
    
    
    
    

    //Scene *currentScene = self.library.scenes[addTakeButton.tag];

    //RecordVideoViewController *recordViewController = segue.destinationViewController;
    //[recordViewController setSceneIndex:addTakeButton.tag];
    //[recordViewController setLibrary:self.library];
    //[recordViewController setScene:currentScene];

    //NSLog(@"recordViewController.scene has been set to %@", currentScene.title);

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
        NSLog(@"completion block called!");
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf.tableView reloadSectionIndexTitles];
        });
        
        
    };
    
    
    
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
    
}

- (void) didFinishRecordingVideoToURL:(NSNotification*)notification
{
    __weak __typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
       ^{
           Take *newTake = [[Take alloc] initWithURL:notification.object];
           newTake.sceneNumber = _currentSceneIndex;
           
        
           [[weakSelf.library.scenes[_currentSceneIndex] takes] addObject:newTake];
           [weakSelf.library saveToFilename:@"videolibrary.plist"];
          
           dispatch_async(dispatch_get_main_queue(), ^{
               [weakSelf.tableView reloadData];
           });
       });
    // after presenting the record view controller with a modal segue instead of storyboard, dismiss the view controller here.

}
@end

