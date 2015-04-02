//
//  NewSceneDetailsViewController.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-04-01.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "NewSceneDetailsViewController.h"

@interface NewSceneDetailsViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *numberField;
@property (weak, nonatomic) IBOutlet UITextField *roleField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionField;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@end

@implementation NewSceneDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.scene = [[Scene alloc] init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (NSString *)description


//- (IBAction)didEditTitle:(id)sender
//{
//    
//}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (sender != self.saveButton) return;
    
    if (self.titleField.text.length > 0)
    {
        self.scene.title = self.titleField.text;
        //self.scene.description = self.descriptionField.text;
        self.scene.libraryIndex = [self.numberField.text integerValue];
        
        
        
        
        
    }
    
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
