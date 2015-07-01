//
//  TakesViewController.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-04-06.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "TakesViewController.h"
#import "Scene.h"
#import "Take.h"
//#import "PlayVideoViewController.h"
//#import "TakeTableViewCell.h"
@interface TakesViewController ()

@property (strong, nonatomic) NSMutableArray *selectedItems;

@property (strong, nonatomic) Take *currentSelection;

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playMovieButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteTakeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *starButton;
- (IBAction)delete:(id)sender;
- (IBAction)playMovie:(id)sender;
- (IBAction)addAsFavourite:(id)sender;

@property (nonatomic, strong) NSMutableArray *takes;

@property (weak, nonatomic) IBOutlet UILabel *sceneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *sceneTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *sceneDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *sceneRoleLabel;

@end

@implementation TakesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureTableView];
    
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    [self.navigationItem setTitle:[NSString stringWithFormat:@"%@", self.scene.title]];
    
    [self.playMovieButton setEnabled:NO];
    [self.deleteTakeButton setEnabled:NO];
    [self.starButton setEnabled:NO];
    //[self.actionButton setEnabled:YES];
    
    [self.deleteTakeButton setAction:@selector(delete:)];
    [self.playMovieButton setAction:@selector(playMovie:)];
    [self.starButton setAction:@selector(addAsFavourite:)];
    // Do any additional setup after loading the view.
    
//    self.sceneTitleLabel.text = self.scene.title;
//    [self.tableView.tableHeaderView addSubview:self.sceneTitleLabel];
//    self.tableView.tableHeaderView add
    
    
}

- (void) configureTableView
{
    //self.scene = [[Scene alloc] init];
    //self.scene = scene;
    self.takes = self.scene.takes;
    [self.sceneTitleLabel setText:self.scene.title];
    
    NSLog(@"TITLE: %@", self.scene.title);
    //self.sceneRoleLabel.text = scene.role;
    self.sceneNumberLabel.text = [NSString stringWithFormat:@"Scene # %li",(long)self.scene.libraryIndex];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.scene.takes count];
}

//-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    // 1. The view for the header
//    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 60)];
//    
//    // 2. Set a custom background color and a border
//    headerView.backgroundColor = [UIColor colorWithRed:0 green:0.6788 blue:1.0 alpha:1.0];
//    //headerView.layer.borderColor = [UIColor colorWithRed:0 green:0.6788 blue:1.0 alpha:0.8f].CGColor;
//    
//    headerView.layer.borderWidth = 2.0;
//    
//    // 3. Add a label
//    UILabel* headerLabel = [[UILabel alloc] init];
//    headerLabel.frame = CGRectMake(5, 2, tableView.frame.size.width - 5,30);
//    headerLabel.backgroundColor = [UIColor clearColor];
//    headerLabel.textColor = [UIColor whiteColor];
//    headerLabel.font = [UIFont boldSystemFontOfSize:24.0];
//    headerLabel.text = self.scene.title;
//    headerLabel.textAlignment = NSTextAlignmentLeft;
//    
//    // 4. Add the label to the header view
//    [headerView addSubview:headerLabel];
//    
//    // 5. Finally return
//    return headerView;
//}


#pragma mark - Table View delegate


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableViewCellIdentifier = @"TakeTableViewCell";
    
    UITableViewCell *cell=
    [tableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableViewCellIdentifier];
    }
    Take *take = self.scene.takes[indexPath.row];
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [take convertSecondsToString:take.duration]];
    
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





- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [[self.tableView cellForRowAtIndexPath:indexPath] setSelectionStyle:UITableViewCellSelectionStyleBlue];
    [self.navigationController setToolbarHidden:NO animated:NO];
    [self.deleteTakeButton setEnabled:YES];
    [self.playMovieButton setEnabled:YES];
    [self.starButton setEnabled:YES];
    
    self.currentSelection = self.scene.takes[indexPath.row];
    
    
    
    
}



- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.deleteTakeButton setEnabled:NO];
    [self.playMovieButton setEnabled:NO];
    [self.starButton setEnabled:NO];
    //Take *take = self.scene.takes[indexPath.row];
    
    self.currentSelection = nil;
    
    
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Take *take = self.scene.takes[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        
        //NSIndexPath *index = self.tableView.indexPathForSelectedRow;
//        if (index == nil)
//        {
//            return;
//        }
        //Take *selectedTake = self.scene.takes[index.row];
        // add code here for when you hit delete
        [self.scene.takes removeObject:take];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldDeleteTake" object:indexPath];
       // add code here for when you hit delete
        //[self.library.scenes removeObjectAtIndex:indexPathFor];
//        NSError *error = nil;
//        if ([[NSFileManager defaultManager] fileExistsAtPath:[take getPathURL].path])
//        {
//            
//            [[NSFileManager defaultManager] removeItemAtURL:[take getPathURL] error:&error];
//        
//        }
//        if (!error)
//        {
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
//        }
    
    }
    

}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// Selects and deselects rows. These methods will not call the delegate methods (-tableView:willSelectRowAtIndexPath: or tableView:didSelectRowAtIndexPath:), nor will it send out a notification.
//- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;
//- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
//- (NSIndexPath *)indexPathForSelectedRow;
// returns nil or index path representing section and row of selection.
/*
 @property (nonatomic, retain) UIView *tableHeaderView;                           // accessory view for above row content. default is nil. not to be confused with section header
 @property (nonatomic, retain) UIView *tableFooterView;                           // accessory view below content. default is nil. not to be confused with section footer
*/
- (IBAction)delete:(id)sender
{
    NSIndexPath *index = self.tableView.indexPathForSelectedRow;
    if (index == nil)
    {
        return;
    }
    Take *selectedTake = self.scene.takes[index.row];
    // add code here for when you hit delete
    [self.scene.takes removeObject:selectedTake];

    [self.tableView deleteRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationRight];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldDeleteTake" object:selectedTake];
    
}

- (IBAction)playMovie:(id)sender
{
    NSIndexPath *index = self.tableView.indexPathForSelectedRow;
  
    Take *take = self.scene.takes[index.row];
    NSLog(@"library index:>>>> %ld", (long)self.scene.libraryIndex);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectItemForPlayback" object:take];
}

- (IBAction)addAsFavourite:(id)sender
{
    // if the take has not been selected to be put in the list of videos to concatenate
    //self.takeToPlay.selected = !self.takeToPlay.selected;
    NSIndexPath *index = self.tableView.indexPathForSelectedRow;
    
    Take *take = self.scene.takes[index.row];
    NSLog(@"library index:>>>> %ld", (long)self.scene.libraryIndex);
    
    if (![take isSelected])
    {
        [self.starButton setImage:[UIImage imageNamed:@"blue-star-32"]];
        [self.starButton setLandscapeImagePhone:[UIImage imageNamed:@"blue-star-24"]];
        [take setSelected:YES];
    }
    else{
        [self.starButton setImage:[UIImage imageNamed:@"white-outline-star-32"]];
        [self.starButton setLandscapeImagePhone:[UIImage imageNamed:@"white-outline-star-24"]];
        [take setSelected:NO];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectStarButtonInCell" object:take];
    
    
}

- (IBAction)unwindFromRecordVideoVC:(UIStoryboardSegue *)segue
{
    NSLog(@"unwind segue callled");
    [self.tabBarController.tabBar setHidden:NO];
    [self.tabBarController setHidesBottomBarWhenPushed:NO];
    
}
//if ([self.takeToPlay isSelected])
//{
//    [self.starButton setImage:[UIImage imageNamed:@"blue-star-32"]];
//    [self.starButton setLandscapeImagePhone:[UIImage imageNamed:@"blue-star-24"]];
//}
//else
//{
//    [self.starButton setLandscapeImagePhone:[UIImage imageNamed:@"white-outline-star-24"]];
//}
//
//[self.starButton setAction:@selector(star:)];

@end
