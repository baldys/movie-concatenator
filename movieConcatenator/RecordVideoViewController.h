//
//  RecordVideoViewController.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-21.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Scene.h"

@interface RecordVideoViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) Scene *scene;
@property (nonatomic, copy) void (^completionBlock)(BOOL);

- (IBAction)backToRootVC:(id)sender;

//@property (nonatomic,strong) UIImagePickerController *imagePicker;
- (IBAction)recordAndPlay:(id)sender;

- (BOOL) startCameraControllerFromViewController:(UIViewController*)controller usingDelegate:(id)delegate;

-(void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void*)contextInfo;

@end
