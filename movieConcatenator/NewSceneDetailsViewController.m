//
//  NewSceneDetailsViewController.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-04-01.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "NewSceneDetailsViewController.h"

@interface NewSceneDetailsViewController () <UITextFieldDelegate>
{
    
}
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
    //self.delegate = self;
    self.scene = [[Scene alloc] init];
}

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    return YES;
//}

// It is important for you to hide the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)keyboardDismiss:(id)sender {
    
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

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if (sender != self.saveButton) return;
    
    if (self.titleField.text.length > 0)
    {
        self.scene.title = self.titleField.text;
        //self.scene.description = self.descriptionField.text;
        
    }
    else if (self.titleField.text.length == 0)
    {
        self.scene.title = [NSString stringWithFormat:@"Scene %i", self.scene.libraryIndex];
    }
    self.scene.libraryIndex = [self.numberField.text integerValue]+1;
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
