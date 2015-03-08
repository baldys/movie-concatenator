//
//  RecordVideoViewController.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-21.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "RecordVideoViewController.h"
#import "VideoController.h"
#import "VideoLibrary.h"
#import "Scene.h"


@interface RecordVideoViewController ()
@property (weak, nonatomic) IBOutlet UITextField *sceneTitleField;

@end

@implementation RecordVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"hey im here");
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.scene.title)
    {
        self.navigationItem.title = self.sceneTitleField.text;
        //self.scene.title = self.sceneTitleField.text;
    }
    
}
// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker
{
    
    NSLog(@"did cance;");
    
    [self.parentViewController dismissViewControllerAnimated: YES completion:nil];
    if (picker.isMovingToParentViewController) NSLog(@"yup");
    [picker dismissViewControllerAnimated:YES completion:nil];
   /// [self popToRootViewControllerAnimated:YES animated:YES];
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)UIInterfacerientationLandscapeRight
{
    return YES;
}
*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(BOOL)startCameraControllerFromViewController:(UIViewController*)controller usingDelegate:(id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate
{
    self.scene.title = self.sceneTitleField.text;
     NSLog(@"hey im here 222222");
    // 1 - Validattions
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
    {
        return NO;
    }
    
    // 2 - Get image picker
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    // Displays a control that allows the user to choose movie capture
    cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = delegate;
    
    // 3 - Display image picker
    // Use presentViewController:animated:completion: instead
   [controller presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    // Handle a movie capture
    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo)
    {
        
        NSURL *movieUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        NSString *moviePath = [(NSURL *)[info objectForKey:UIImagePickerControllerMediaURL] path];
        
        // create a new take instance. the url property of the take will be set to moviePath
        // get the index path of the current section (the section whose add button was pressed in within the collection vc. pass this from the collection vc. 
        // call method on video controller to insert a new take to the shared videos array.
        
        [self dismissViewControllerAnimated:NO completion:nil];
        NSLog(@"moviePath: %@", moviePath);
        
        //VideoLibrary *ml = [[VideoLibrary alloc] init];
        // add take to array passed from the collection view controller (via video controller)
        NSLog(@"is thisevne being called?");
        
        Take *newVideo = [[Take alloc] initWithURL:movieUrl];
        
        [self.scene.takes insertObject:newVideo atIndex:0];
        
        if (self.completionBlock != nil)
        {
            self.completionBlock(YES);
        }
    
    }
}

-(void)                    video:(NSString*)videoPath
        didFinishSavingWithError:(NSError*)error
                     contextInfo:(void*)contextInfo
{
    if (error)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
                  delegate:self
         cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}



- (IBAction)recordAndPlay:(id)sender
{
    [self startCameraControllerFromViewController:self usingDelegate:self];
}
- (IBAction)backToRootVC:(id)sender
{
    
    [self.navigationController popViewControllerAnimated:YES];

    
    
}
@end
