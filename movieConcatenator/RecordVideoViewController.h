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

@interface RecordVideoViewController : UIViewController

- (IBAction)recordAndPlay:(id)sender;

- (BOOL) startCameraControllerFromViewController:(UIViewController*)controller usingDelegate:(id)delegate;

-(void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void*)contextInfo;

@end
