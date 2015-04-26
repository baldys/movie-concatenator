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
#import "Take.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayVideoViewController : UIViewController
@property (nonatomic, strong) AVPlayerViewController *playerViewController;
@property (nonatomic, strong) NSURL *takeURL;
//@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) AVQueuePlayer *queuePlayer;
@property (nonatomic, strong) NSArray *playerItems;

@end
