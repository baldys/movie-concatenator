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
//#import "TakeTableViewCell.h"
@interface TakesViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playTakeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteTakeButton;

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
    
    
    // Do any additional setup after loading the view.
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didSelectHeaderButtonInScene:)name:@"didSelectHeaderButtonInScene" object:nil];

}

- (void) didSelectHeaderButtonInScene:(NSNotification*)notification
{
    self.scene = [notification object];
    self.sceneTitleLabel = [notification object];
    self.sceneNumberLabel.text = [NSString stringWithFormat:@"SCENE #%li", (long)self.scene.libraryIndex];
    self.sceneDescriptionLabel.text = @"scene description goes here!!";
    
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

#pragma mark - Table View delegate

// each table view cell represents a scene in the video library's scenes array

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
    cell.imageView.image = take.thumbnail;
    
    cell.textLabel.text = [NSString stringWithFormat:@"Take # %lu", (unsigned long)self.scene.takes.count];
    //[cell setImage: [UIImage imageNamed:@"vid-1.png"]];
    //cell.imageView.image = self.takes[indexPath.row].thumbnail;
    return cell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    
}


//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//
//    if (editingStyle == UITableViewCellEditingStyleDelete)
//    {
//        //add code here for when you hit delete
//        [self.library.scenes removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//        // NSFileMAnager... delete all of the videos in that section......
//    }
//
//
//
//    //UITableViewCellEditingStyleDelete
//
//}


//- (IBAction)editScene:(id)sender
//{
//    [self.tableView setEditing:YES animated:YES];
//
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
