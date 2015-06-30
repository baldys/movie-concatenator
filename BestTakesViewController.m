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
#import "EditingOptionsViewController.h"
@interface BestTakesViewController () <UINavigationControllerDelegate>
{
    UIActivityIndicatorView *loadingIndicator;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *concatenateButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) VideoLibrary *videoLibrary;
@property (nonatomic) TransitionTypes transitionType;

@end

@implementation BestTakesViewController


- (void)viewDidLoad {
    [super viewDidLoad];

//    if (self.takesToConcatenate == nil)
//    {
//        self.takesToConcatenate = [NSMutableArray array];
//    }
    self.titleSlidesEnabled = NO;

    [self.tabBarItem setSelectedImage:[UIImage imageNamed:@"blue-star-32.png"]];

    // Do any additional setup after loading the view.
    [self setUpToolbar];
 
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    [self.editButtonItem setAction:@selector(editButtonTapped:)];
    
    ///[self.editButtonItem setAction:@selector(editList:)];
    
    self.videoMerger = [[VideoMerger alloc] init];
    self.transitionType = TransitionTypeNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addTakeToTakesToConcatenate:) name:@"didSelectStarButtonInCell" object:nil];
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

#pragma mark - toolbar

- (void) setUpToolbar
{
    
    if (loadingIndicator ==nil)
    {
        loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        loadingIndicator.hidesWhenStopped = YES;
    }
    [self.navigationController.toolbar setHidden:NO];
    
    [self showConcatenatorButtonInToolbar];
    // uncomment later - testing purposes only
//    if (self.takesToConcatenate.count <= 1)
//    {
//        [self.navigationController.toolbar.items[0] setEnabled:NO];
//    }
}

/////*
- (void) showConcatenatorButtonInToolbar
{
    if ([loadingIndicator isAnimating] && loadingIndicator != nil)
        return;
    [self.concatenateButton setEnabled:YES];
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *items = [NSArray arrayWithObjects:flexItem, self.concatenateButton, flexItem, nil];
    [self.navigationController.toolbar setItems:items animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
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
    
    cell.textLabel.text = take.sceneTitle;
    

//    AVAsset *asset = [AVURLAsset assetWithURL:take.getFileURL];
//    [take loadDurationOfAsset:asset withCompletionHandler:(CMTime time)^{
//        
//        dispatch_async(dispatch_get_main_queue(),^{
//            
//        
//    });
//                       }];
//   
    
    
    if (take.thumbnail == nil)
    {
        [take loadThumbnailWithCompletionHandler:^(UIImage* image)
         {
             dispatch_async(dispatch_get_main_queue(),
                            ^{
                            
                                cell.imageView.image = image;
                            });
         }];
    }
    else
    {
        cell.imageView.image = take.thumbnail;
    }
    return cell;
}

#pragma mark - editing

- (IBAction)editButtonTapped:(id)sender
{
    if (self.tableView.isEditing)
    {
        [self.tableView setEditing:NO animated:YES];
        [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStyleDone];
    }
    else {
        [self.tableView setEditing:YES animated:YES];
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
    }
}

#pragma mark - deleting

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
        Take *take = self.takesToConcatenate[indexPath.row];
        [take setSelected:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectStarButtonInCell" object:take];
        //[self.takesToConcatenate removeObject:self.takesToConcatenate[indexPath.row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
    }
    
}

#pragma mark - reordering

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    Take *take = self.takesToConcatenate[fromIndexPath.row];
    
    [self.takesToConcatenate removeObjectAtIndex:fromIndexPath.row];
    [self.takesToConcatenate insertObject:take atIndex:toIndexPath.row];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (IBAction)concatenateSelectedTakes:(id)sender
{
    
    self.videoMerger.transitionType = _transitionType;
    NSLog(@"Number of items in array: %lu",(unsigned long)[_takesToConcatenate count]);
    // uncomment later - testing 
    //if (self.takesToConcatenate.count > 1)
    //{
        //[merger exportVideoComposition:[merger spliceAssets:self.takesToConcatenate]];
    //}
    //else
    //{
      //  NSLog(@"Please select more than one video.");
    //}
    
    //[self.videoMerger exportVideoComposition:[self.videoMerger buildCompositionObjects:self.takesToConcatenate]];
    self.videoMerger.titleSlidesEnabled = self.titleSlidesEnabled;
    [self.videoMerger buildCompositionObjects:self.takesToConcatenate];
    
}

#pragma mark - NSNotificationCenter

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
    
    //NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:self.navigationController.toolbar.items];
    //[toolbarItems replaceObjectAtIndex:0 withObject:item];
    
    NSArray *items = [NSArray arrayWithObject:item];
    // show activity indicator in the toolbar instead
   [self.navigationController.toolbar setItems:items animated:YES];
    
}

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
    [self.takesToConcatenate removeAllObjects];
    //self.takesToConcatenate = nil;
    [self.tableView reloadData];
    
    
}


- (IBAction)unwindSegueFromEditingOptions:(UIStoryboardSegue*)segue
{
     EditingOptionsViewController *editingOptionsVC = (EditingOptionsViewController*)[segue sourceViewController];
    self.transitionType = editingOptionsVC.transitionType;
    self.titleSlidesEnabled = editingOptionsVC.titleSlideEnabled;
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
