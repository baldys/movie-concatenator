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

@interface TakesViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playTakeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteTakeButton;

@property (nonatomic, strong) NSMutableArray *takes;
@property (weak, nonatomic) IBOutlet UILabel *sceneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *sceneTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *sceneDescriptionLabel;

@end

@implementation TakesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sceneTitleLabel.text = self.scene.title;
    self.sceneNumberLabel.text = [NSString stringWithFormat:@"%i", self.scene.libraryIndex];
    self.sceneDescriptionLabel.text = @"scene description goes here!!";
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.takes count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

#pragma mark - Table View delegate

// each table view cell represents a scene in the video library's scenes array
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableViewCellIdentifier = @"TakeTableViewCell";
    
    UITableViewCell *cell=
    [tableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier forIndexPath:indexPath];
    //cell.titleLabel = [self.takes[indexPath.row] takeNumber];
    cell.imageView.image = [UIImage imageNamed:@"vid-1.png"];
    // cell.imageView.image = self.takes[indexPath.row].thumbnail;
    return cell;
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
