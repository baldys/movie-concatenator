//
//  BestTakesViewController.m
//  DemoReel
//
//  Created by Veronica Baldys on 2015-05-04.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "BestTakesViewController.h"
#import "VideoMerger.h"
#import "ScenesTableViewController.h"
#import "VideoLibrary.h"
#import "Take.h"
@interface BestTakesViewController () <UINavigationControllerDelegate>
{
    UIActivityIndicatorView *loadingIndicator;
}
//@property (weak, nonatomic) ScenesTableViewController *scenesTableVC;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *concatenateButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) VideoLibrary *videoLibrary;
//@property (strong, nonatomic) NSMutableArray *takesToConcatenate;

@end

@implementation BestTakesViewController


- (void)viewDidLoad {
    [super viewDidLoad];

//    if (self.takesToConcatenate == nil)
//    {
//        self.takesToConcatenate = [NSMutableArray array];
//    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addTakeToTakesToConcatenate:) name:@"didSelectStarButtonInCell" object:nil];

    //NSArray *viewControllers = [self.tab]
    
    // populate the array with selected takes from the video library if items have been selected prior to loading the current view controller into memory
//    self.videoLibrary = [VideoLibrary libraryWithFilename:@"videolibrary.plist"];
//    [self.videoLibrary listScenesAndTakes];
//    NSLog(@"COUNT !!!!! %lu", (unsigned long)[self.videoLibrary.takesToConcatenate count]);
//    for (Scene *scene in self.videoLibrary.scenes)
//    {
//        for (Take *take in scene.takes)
//        {
//            if (take.isSelected)
//            {
//                NSLog(@"Take is selected with path url : %@", [take getPathURL]);
//                [self.takesToConcatenate addObject:[take copy]];
//                NSLog(@"COUNT2: %lu", (unsigned long)[[self.videoLibrary selectedTakes] count]);
//            }
//        }
//    }
//    
//    NSLog(@"COUNT2: %lu", (unsigned long)[self.videoLibrary.takesToConcatenate count]);
    //NSMutableArray *selectedTakesArray = [[self.videoLibrary selectedTakes] copy];
//    for (Take *take in [self.videoLibrary selectedTakes])
//    {
//        [self.takesToConcatenate addObject:take];
//    }
    //self.takesToConcatenate = [NSMutableArray arrayWithArray:[vl selectedTakes]];
    
    
//    for (int i=0; i<[[self.videoLibrary selectedTakes] count]; i++)
//    {
//       NSLog(@"%lu", (unsigned long)[self.videoLibrary selectedTakes].count);
//    }
    //[self.videoLibrary selectedTakes];
    
//    UINavigationController *nc = (UINavigationController*)[self.tabBarController selectedViewController];
//    UINavigationController *nc = (UINavigationController*)[[self.tabBarController.viewControllers objectAtIndex:0] childViewControllers];
    
    
//    ScenesTableViewController *scenesTVC = (ScenesTableViewController*)[nc visibleViewController];
    
    // if there are takes selected before the view has been loaded into memory, then get the contents of the "takesToConcatenate" array from the ScenesTableViewController (which is also registered for notifications each time a take is selected and also will also contain an array of selected takes) and add them to the takesToConcatenate array here so that it doesnt show an empty table view if the user clicked on the tab after selecting takes in other view controllers. Keeps data consistent among view controllers before dequeing cells.
    //In the case where the user has selected takes (clicked star buttons for a take/takes in other view controllers) before selecting the "best takes" tab bar item leading to the current view controller, there would not be any items showing in the current view controller since it did not register for "didSelectStarButtonInCell" notifications until the view gets loaded into memory. the following addresses that issue by getting a reference to the "ScenesTableViewController" from the tab bar and retreiving those selected takes so they can be copied into the current view controllers "takesToConcatenate" array before dequeing cells. now this view controller is updated with the selected items as soon as it loads so its table view can display the items that were starred.
    
   
    // if there are no items existing in the
//    if (scenesTVC.takesToConcatenate)
//    {
//        for (Take *take in scenesTVC.takesToConcatenate)
//        {
//            NSLog(@"Take with Asset ID: %@", [take getPathURL]);
//            NSLog(@" COPY Take with Asset ID: %@", [[take getPathURL] copy]);
//            [self.takesToConcatenate addObject:take];
//        }
//    }
//    
    [self.tabBarItem setSelectedImage:[UIImage imageNamed:@"blue-star-32.png"]];
    
//    if (!self.takesToConcatenate)
//    {
//        self.takesToConcatenate = [NSMutableArray array];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"BestTakesVCDidLoad" object:self];
//    }
//    
    
    
    // Do any additional setup after loading the view.
    [self setUpToolbar];
 
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    [self.editButtonItem setAction:@selector(editList:)];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didStartConcatenatingVideos:) name:@"videoMergingStartedNotification" object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didFinishConcatenatingVideos:) name:@"videoMergingCompletedNotification" object:nil];
    
    
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





- (void)addTakeToTakesToConcatenate:(NSNotification*)notification
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
    
    // disable the toolbar button if there are less than two takes
    if (self.takesToConcatenate.count >= 2)
    {
        NSLog(@"self.takesToConcatenate = %lu", (unsigned long)[self.takesToConcatenate count]);
        [self.concatenateButton setEnabled:YES];
        [self.navigationController.toolbar.items[0] setEnabled:YES];
    }
    else if (self.takesToConcatenate.count < 2)
    {
        [self.concatenateButton setEnabled:NO];
        [self.navigationController.toolbar.items[0] setEnabled:NO];
    }
}
- (void) setUpToolbar
{
    if (loadingIndicator ==nil)
    {
        loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        loadingIndicator.hidesWhenStopped = YES;
    }
    [self.navigationController.toolbar setHidden:NO];
    
    [self showConcatenatorButtonInToolbar];
    if (self.takesToConcatenate.count <= 1)
    {
        [self.navigationController.toolbar.items[0] setEnabled:NO];
    }
}

/////*
- (void) showConcatenatorButtonInToolbar
{
    if ([loadingIndicator isAnimating] && loadingIndicator != nil)
        return;
    [self.concatenateButton setEnabled:YES];
    NSArray *items = [NSArray arrayWithObject:self.concatenateButton];
    [self.navigationController.toolbar setItems:items animated:YES];
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.takesToConcatenate count];
}

#pragma mark - UITableViewDelegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableViewCellIdentifier = @"BestTakeTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableViewCellIdentifier];
    }
    Take *take = self.takesToConcatenate[indexPath.row];
    
    if (take.thumbnail == nil)
    {
        NSLog(@"thumbnail image is nil");
        
        [take loadThumbnailWithCompletionHandler:^(UIImage* image)
         {
             dispatch_async(dispatch_get_main_queue(),
                            ^{
                                cell.imageView.image = image;
                                NSLog(@"loaded thumbnail for table view cell");
                            });
         }];
    }
    else
    {
        cell.imageView.image = take.thumbnail;
    }

    return cell;
}

- (void) didStartConcatenatingVideos:(NSNotification*)notification
{
    NSLog(@"video merging starting?");
    loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    // if concatenation finished successfully, stop animating the view, hide it from the toolbar and re-enable the concatenate button so another video can be merged.
    if (loadingIndicator.isAnimating == YES) return;
    
    [loadingIndicator startAnimating];
    
    // right now only the concatenator button should be showing in the toolbar
    // so disable it
    [self.concatenateButton setEnabled:NO];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:loadingIndicator];
    NSArray *items = [NSArray arrayWithObject:item];
    // show activity indicator in the toolbar instead
    [self.navigationController.toolbar setItems:items animated:YES];
    
}
//////*****
- (void) didFinishConcatenatingVideos:(NSNotification*)notification
{
    if (loadingIndicator.isAnimating==NO) return;
    
    NSLog(@"Will be stopping animation");
    
    [loadingIndicator stopAnimating];
    
    [self showConcatenatorButtonInToolbar];
    //[self.navigationController.toolbarItems[0] setHidden:NO];
    
    for (int i=0; i<self.takesToConcatenate.count; i++)
    {
        [self.takesToConcatenate[i] setSelected:NO];
    }
    
    
    //[self.takesToConcatenate removeAllObjects];
    self.takesToConcatenate = nil;
}

- (IBAction)concatenateSelectedTakes:(id)sender
{
    VideoMerger *merger = [[VideoMerger alloc]init];
    NSLog(@"Number of items in array: %lu",(unsigned long)[self.takesToConcatenate count]);
    if (self.takesToConcatenate.count > 1)
    {
        [merger exportVideoComposition:[merger spliceAssets:self.takesToConcatenate]];
    }
    else
    {
        NSLog(@"Please select more than one video.");
    }
}


- (IBAction)editList:(id)sender
{
    if (self.tableView.isEditing)
    {
        [self.tableView setEditing:NO animated:YES];
    }
    else
    {
        [self.tableView setEditing:YES animated:YES];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}



 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
     if (editingStyle == UITableViewCellEditingStyleDelete)
     {
 // Delete the row from the data source
         [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
     }
    
 }


 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
}



 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{

     return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
