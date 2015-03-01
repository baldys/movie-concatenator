//
//  PlayVideoViewController.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-21.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>


@interface PlayVideoViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
- (IBAction)playVideo:(id)sender;


// For opening UIImagePickerController
-(BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id )delegate;

@end
