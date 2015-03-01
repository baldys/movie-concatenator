//
//  RecordVideoViewController.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-21.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "RecordVideoViewController.h"

@interface RecordVideoViewController ()

@end

@implementation RecordVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"hey im here");
    // Do any additional setup after loading the view.
    
    [self logViews:self.view];
}

-(void)logViews:(UIView*)view {
    NSLog(@"view: %@", view.description);
    NSLog(@"====");
    for (UIView *subView in view.subviews) {
        [self logViews:subView];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear()");
    [super viewDidAppear:animated];
    [self startCameraControllerFromViewController:self usingDelegate:self];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}


// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    NSLog(@"did cance;");
    
    [self.parentViewController dismissViewControllerAnimated: YES completion:nil];
    if (picker.isMovingToParentViewController) NSLog(@"yup");
    [picker dismissViewControllerAnimated:YES completion:nil];
   /// [self popToRootViewControllerAnimated:YES animated:YES];
    
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
        NSString *moviePath = [(NSURL *)[info objectForKey:UIImagePickerControllerMediaURL] path];
        [self dismissViewControllerAnimated:NO completion:nil];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath))
        {
            UISaveVideoAtPathToSavedPhotosAlbum(moviePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}

-(void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


/*
- (IBAction)recordAndPlay:(id)sender
{
    [self startCameraControllerFromViewController:self usingDelegate:self];
}
*/
@end
