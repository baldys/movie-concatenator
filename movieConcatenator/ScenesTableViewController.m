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
    
    VideoLibrary *library = [VideoLibrary
                             libraryWithFilename:@"videolibrary.plist"];
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

//-(void) viewDidAppear:(BOOL)animated
//{
//    NSLog(@"viewDidAppear trying to recursively log some views!!!");
//    
//    [self recursivelyLogViews:self.view];
//}

//-(void) recursivelyLogViews:(UIView*) view
//{
//    NSLog(@"%@ frame: (%f, %f, %f, %f)", view.class, view.frame.origin.x,
//       view.frame.origin.y, view.frame.size.width, view.frame.size.height);
//    for (UIView* subview in view.subviews)
//    {
//        if (subview.hidden)
//            {
//                NSLog(@"ishidden!");
//            }
//        [self recursivelyLogViews:subview];
//    }
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
    [tableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier
                                    forIndexPath:indexPath];

    /// try cahangeing this
    Scene *scene = self.library.scenes[indexPath.section];
    // to this
    // Scene *scene = self.scenes[indexPath.section];
    [cell setCollectionData:scene];
    
    return cell;
}

/*
-(void)tableView:(UITableView *)tableView 
 willDisplayCell:(SceneTableViewCell *)cell 
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

//-(void)tableView:(UITableView *)tableView 
 didEndDisplayingCell:(SceneTableViewCell *)cell 
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
}
*/

#pragma mark - UITableView Delegate methods

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    //Headerview
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0.0,0.0,300.0,30.0)];
    headerView.backgroundColor = [UIColor blackColor];
    headerView.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:1.0].CGColor;
    headerView.layer.borderWidth = 1.5;
    
    // button
    self.addTakeButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    //[self.addTakeButton setImage:[UIImage imageNamed:@"tape-64.png"] forState:UIControlStateNormal];
    self.addTakeButton.titleLabel.text = @"Add Take";
    [self.addTakeButton setFrame:CGRectMake(275,5,50,30)];
    self.addTakeButton.tag = section;
    self.addTakeButton.hidden = NO;
    [self.addTakeButton setBackgroundColor:[UIColor clearColor]];
    [self.addTakeButton addTarget:self action:@selector(addTakeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [headerView addSubview:self.addTakeButton];
    
    // title
    UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,5,200,30)];
    Scene *sectionData = self.library.scenes[section];
    headerLabel.text = sectionData.title;
    headerLabel.textColor = [UIColor whiteColor];
    
    [headerView addSubview:headerLabel];
    
    return headerView;
}
/////
- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];
    footerView.backgroundColor = [UIColor blackColor];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}
/////
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
        [self presentViewController:videoPlayerVC animated:YES completion:^{
            NSLog(@"Presented videoPlayerVC!!!");
        }];
    }
}

- (IBAction)addScene:(id)sender
{
    // TO DO
    //present new view controller "ADD SCENE VIEW CONTROLLER:"
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        Scene *newScene = [[Scene alloc]init];
        newScene.title = @"New Scene";
        [self.library.scenes addObject:newScene];
        
        // do this on background thread while scene details are being added.
        //[self.library saveToFilename:@"videolibrary.plist"];
        
    });
    // do this on main queue in block above
    [self.tableView reloadData];
}

- (void) didSelectStarButtonInCell:(NSNotification*)notification
{
    if (!self.takesToConcatenate)
    {
        self.takesToConcatenate = [NSMutableArray array];
    }

    Take *take = [notification object];
    
    if (take.isSelected && ![self.takesToConcatenate containsObject:take])
    {
        /// 1
       // [self.takesToConcatenate addObject:self.collectionData.takes[takeCell.starTake.tag]];
        /// 2
        [self.takesToConcatenate addObject:take];
        NSLog(@"take is selected but does not contain object");
    }
    //
    else if (!take.isSelected && [self.takesToConcatenate containsObject:take])
    {
        [self.takesToConcatenate removeObject:take];
        NSLog(@"take is DEselected but contains object");
    }
    
}


- (IBAction)ConcatenateSelectedTakes:(id)sender
{
    VideoMerger *merger = [[VideoMerger alloc]init];
    
    NSLog(@"################# number of items in  %lu",(unsigned long)[self.takesToConcatenate count]);
    if (self.takesToConcatenate.count > 1)
    {
        [merger exportVideoComposition:[merger spliceAssets:self.takesToConcatenate]];
    }
    else
    {
        NSLog(@"cant concatenate one video");
    }
    
}

# pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
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

}

- (IBAction)unwindToScenesView:(UIStoryboardSegue*)segue
{
    NSLog(@"unwind segue callled");
    // add take stuff goes HERE!> get the file output url from the source view controller
//    Scene *currentScene = self.library.scenes[self.segue.destinationViewController.sceneIndex];
//    Take *newTake = [[Take alloc] initWithURL:segue.destinatiooutputFileURL];
//    [currentScene.takes insertObject:newTake atIndex:0];
//    [self.library saveToFilename:@"videolibrary.plist"];
    //[self.tableView reloadData];
    RecordVideoViewController *recordViewController = segue.sourceViewController;
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





@end

