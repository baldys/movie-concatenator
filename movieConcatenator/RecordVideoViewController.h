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

@property (nonatomic, strong) VideoLibrary* library;
@property (nonatomic, strong) Scene *scene;
@property (nonatomic, copy) void (^completionBlock)(BOOL);

//- (IBAction)backToRootVC:(id)sender;


@end
