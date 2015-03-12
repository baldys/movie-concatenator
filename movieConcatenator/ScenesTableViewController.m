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
#import "VideoLibrary.h"
#import "SceneTableViewCell.h"
#import "VideoMerger.h"
#import "PlayVideoViewController.h"
#import "RecordVideoViewController.h"

@interface ScenesTableViewController ()
@property (nonatomic, strong) NSMutableArray *scenes;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;

@end

@implementation ScenesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = YES;
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    VideoLibrary *library = [VideoLibrary libraryWithFilename:@"videolibrary.plist"];
    
    if (!library)
    {
        library = [[VideoLibrary alloc] init];
        [library saveToFilename:@"videolibrary.plist"];
    }
    
    self.library = library; // For reading and writing video
    
    if (!self.selectedItems)
    {
        self.selectedItems = [NSMutableArray array];
    }
    

}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
}
-(void) viewDidAppear:(BOOL)animated
{
//    NSLog(@"viewDidAppear trying to recursively log some views!!!");
    [self recursivelyLogViews:self.view];
}

// Debugging purposes only
-(void) recursivelyLogViews:(UIView*) view{
//    NSLog(@"%@ frame: (%f, %f, %f, %f)", view.class, view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
//    for (UIView* subview in view.subviews) {
//        [self recursivelyLogViews:subview];
//    }
}

- (void)didReceiveMemoryWarning {
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
    return self.library.scenes.count;
}






- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SceneTableViewCell";
    
    SceneTableViewCell *cell = (SceneTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[SceneTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.addTakeButton.tag = indexPath.row;
    cell.scene =  self.library.scenes[indexPath.row];
    cell.sceneTitleLabel.text = cell.scene.title;
    
    
//    
//    NSLog(@"Before: %@ vs %@", cell.scene, self.library.scenes[indexPath.row]);
//    cell.scene.title = @"10000000";
//    NSLog(@"set cell.scene.title to 1000000");
//    NSLog(@"Before: %@ vs %@", cell.scene, self.library.scenes[indexPath.row]);
    
    
    
    NSLog(@"showing scene in table view: %@", cell.scene.title);
    return cell;
}





















-(void)tableView:(UITableView *)tableView willDisplayCell:(SceneTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [cell setCollectionViewDataSourceDelegate:self index:indexPath.row];
    
//    NSInteger index = cell.collectionView.tag;
    
//    NSLog(@"Displaying tableview cell #%d", index);
//
//    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
//   [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}









- (IBAction)addScene:(id)sender
{
    Scene *newScene = [[Scene alloc] init];
    newScene.title = @"Scene!";
    [self.library.scenes addObject:newScene];
    [self.library saveToFilename:@"videolibrary.plist"];
    [self.tableView reloadData];
}



- (IBAction)ConcatenateSelectedTakes:(id)sender
{
    VideoMerger *merger = [[VideoMerger alloc] init];
    NSLog(@"################# %lu",(unsigned long)[self.selectedItems count]);
    [merger exportVideoComposition:[merger spliceAssets:self.selectedItems]];
}





- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    

    NSLog(@"prepareForSegue");
    UIButton *addTakeButton = (UIButton*)sender;
    NSLog(@"buttontag = %li", (long)addTakeButton.tag);
    
    Scene *currentScene = self.library.scenes[addTakeButton.tag];
    
    NSLog(@"currentScene is now '%@'", currentScene.title);
    
    

        
    RecordVideoViewController *recordViewController = segue.destinationViewController;
        
    recordViewController.scene = currentScene;
    
    
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
    };

        

}



@end
