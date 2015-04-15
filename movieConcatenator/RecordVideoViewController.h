//
//  RecordVideoViewController.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-21.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoLibrary.h"
#import "Scene.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Scene.h"
#import "VideoLibrary.h"

@interface RecordVideoViewController : UIViewController

//@property (nonatomic, strong) VideoLibrary* library;
//@property (nonatomic, strong) Scene *scene;
@property (nonatomic) NSInteger sceneIndex;
//@property (nonatomic, strong) Take *take;
@property (nonatomic, copy) void (^completionBlock)(BOOL);
@property (nonatomic, strong) NSURL *outputFileURL;
//- (IBAction)backToRootVC:(id)sender;
@property (nonatomic) UIDeviceOrientation currentOrientation;


- (IBAction)cancel:(UIBarButtonItem *)sender;
- (IBAction)save:(id)sender;

@end
