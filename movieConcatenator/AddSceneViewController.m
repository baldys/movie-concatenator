//
//  AddSceneViewController.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-31.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "AddSceneViewController.h"
#import "VideoLibrary.h"



//static NSString *cell3 = @"SceneTitleCell";

@interface AddSceneViewController() 


@property (strong, nonatomic) IBOutlet UITableViewCell *titleCell;
@property (strong, nonatomic) UITableViewCell *orderCell;
@property (strong, nonatomic) UITableViewCell *descriptionCell;
@property (nonatomic, strong) IBOutlet UITextField *sceneTitleField;
@property (nonatomic, strong) IBOutlet UITextField *sceneNumberField;
@property (nonatomic, strong) IBOutlet UITextField *sceneDescriptionField;



@end

@implementation AddSceneViewController


- (void)loadView
{
    [super loadView];
    
    // set the title
    self.title = @"Edit Scene Properties";
    
    // construct first name cell, section 0, row 0
    //self.titleCell = [[UITableViewCell alloc] init];
    //self.titleCell.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f];
    
    //self.sceneNumberField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //self.sceneTitleField.enabled = YES;
    
//self.sceneTitleField = [[UITextField alloc]initWithFrame:CGRectInset(self.titleCell.contentView.bounds, 15, 0)];
    //self.sceneTitleField.placeholder = @"Title";
    //[self.titleCell.contentView addSubview:self.sceneTitleField];
    //self.sceneTitleField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
//    // construct scene number cell, section 0, row 1
//    self.orderCell = [[UITableViewCell alloc] init];
//    self.orderCell.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f];
//    self.sceneNumberField.enabled = YES;
//    self.sceneNumberField = [[UITextField alloc]initWithFrame:CGRectInset(self.orderCell.contentView.bounds, 15, 0)];
//    
//    self.sceneNumberField.placeholder = @"Scene #";
//    [self.orderCell.contentView addSubview:self.sceneNumberField];
//    
//    
//    // construct description cell with text field., section 1, row 00
//    self.descriptionCell = [[UITableViewCell alloc]init];
//    self.descriptionCell.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f];
//    
//    self.sceneDescriptionField = [[UITextField alloc] initWithFrame:CGRectInset(self.descriptionCell.contentView.bounds, 15, 0)];
//    self.sceneDescriptionField.placeholder = @"Description";
//    self.sceneDescriptionField.enabled = YES;
//    self.sceneDescriptionField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
   // [self.descriptionCell.contentView addSubview:self.sceneDescriptionField];
    
    
    //self.sceneTitleField.delegate = self;
    //self.sceneNumberField.delegate = self;
    
    //[self.titleCell.contentView bringSubviewToFront:self.sceneTitleField];
    
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    
//    
//    self.sceneData = [[Scene alloc] init];
//    
//
//    if (textField == self.sceneTitleField)
//    {
//    
//        [self.sceneData setTitle:self.sceneTitleField.text];
//        
//    }
//
//    else if (textField == self.sceneNumberField)
//    {
//      [self.sceneData setLibraryIndex:[self.sceneNumberField.text integerValue]];
//        
//    }
//    else if (textField == self.sceneDescriptionField)
//    {
//        //[self.sceneData setDescription:self.sceneDescriptionField.text];
//        
//    }
    [self.sceneTitleField resignFirstResponder];
    return YES;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
    
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellid0 = @"SceneTitleCell";
    static NSString *cellid1 = @"SceneOrderCell";
    static NSString *cellid2 = @"SceneDescriptionCell";


    
         //UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid0];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid1];
        
        

    return cell;
}

// Customize the section headings for each section
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    switch(section)
//    {
//        case 0: return @"Title";
//        case 1: return @"Index";
//        case 2: return @"Description";
//    }
//    return nil;
//}
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section == 0)
//    {
//        
//        
//    }
//    else if (indexPath.section == 1)
//    {
//       
//    }
//    else if(indexPath.section == 2)
//    {
//        
//        
//        
//          //[self textFieldShouldBeginEditing:self.sceneDescriptionField];
//    }
//}
////
//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    NSLog(@"%s:(textField.tag:%d)", __FUNCTION__, textField.tag);
//    [textField resignFirstResponder];
//    if(textField.tag == 0) {
//        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:0];
//        UITextField *nextTextField = (UITextField *)[cell viewWithTag:1];
//        NSLog(@"(nextTextField.tag:%d)", nextTextField.tag);
//        NSLog(@"canBecomeFirstResponder returned %d", [nextTextField canBecomeFirstResponder]);
//        NSLog(@"becomeFirstResponder returned %d", [nextTextField becomeFirstResponder]);
//
//    }
//    return YES;
//}


@end
