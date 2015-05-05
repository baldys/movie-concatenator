//
//  BestTakesViewController.m
//  DemoReel
//
//  Created by Veronica Baldys on 2015-05-04.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "BestTakesViewController.h"
#import "VideoMerger.h"
#import "VideoLibrary.h"

@interface BestTakesViewController ()
{
    UIActivityIndicatorView *loadingIndicator;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *concatenateButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//@property (strong, nonatomic) NSMutableArray *takesToConcatenate;

@end

@implementation BestTakesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!self.takesToConcatenate)
    {
        self.takesToConcatenate = [NSMutableArray array];
    }
    
    // Do any additional setup after loading the view.
    [self setUpToolbar];
 
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didStartConcatenatingVideos:) name:@"videoMergingStartedNotification" object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didFinishConcatenatingVideos:) name:@"videoMergingCompletedNotification" object:nil];
    VideoLibrary *library = [VideoLibrary libraryWithFilename:@"videolibrary.plist"];
    [library listFileAtPath:[library documentsDirectory]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addTakeToTakesToConcatenate:) name:@"didSelectStarButtonInCell" object:nil];
    
     [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addTakeToTakesToConcatenate:(NSNotification*)notification
{
    if (!self.takesToConcatenate)
    {
        self.takesToConcatenate = [NSMutableArray array];
    }
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.takesToConcatenate count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableViewCellIdentifier = @"BestTakeTableViewCell";
    //NSInteger takeNumber = indexPath.row;
    UITableViewCell *cell=
    [tableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier forIndexPath:indexPath];
    
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
// // Return NO if you do not want the specified item to be editable.

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
