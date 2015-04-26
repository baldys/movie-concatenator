//
//  PlayVideoViewController.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-21.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//
//
// to do:
/// navigation bar with a cancel button to be able to cancel when the movie is playing.
///
#import "PlayVideoViewController.h"
#import "CustomToolbar.h"

@interface PlayVideoViewController () //<MPMediaPlayback>
@property (nonatomic) NSInteger currentIndex;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *starButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashButton;
- (IBAction)delete:(id)sender;
- (IBAction)star:(id)sender;

@end

@implementation PlayVideoViewController


//- (void) beginSeekingForward
//{
//    // we have reached the end of the list of takes. prevent out of bounds error.
//    if (self.currentIndex == self.playerItems.count)
//    {
//        [self goAway];
//        return;
//    }
//    self.moviePlayer.contentURL = [self nextVideoURL];
//    [self.moviePlayer prepareToPlay];
//    NSLog(@"seeking forward");
//    
//}
//
//
//- (NSURL*)nextVideoURL
//{
//    self.currentIndex = self.currentIndex+1;
//    self.takeURL = [self.playerItems[self.currentIndex] getPathURL];
//    
////    [self.moviePlayer prepareToPlay];
//    return self.takeURL;
//}
//
//- (NSURL*)previousVideoURL
//{
//    self.currentIndex = self.currentIndex-1;
//    self.takeURL = [self.playerItems[self.currentIndex] getPathURL];
//    
//    //    [self.moviePlayer prepareToPlay];
//    return self.takeURL;
//}
//- (void) beginSeekingBackward
//{
//    //[self.moviePlayer beginSeekingBackward];
//    // currently at the first movie in the sequence. Prevent from going out of bounds of array..
//    if (self.currentIndex == 0)
//    {
//        [self goAway];
//        return;
//    }
//    // play the previous video otherwise.
//    else
//    {
//        NSLog(@"Seeking backward");
//        self.moviePlayer.contentURL = [self previousVideoURL];
//        [self.moviePlayer prepareToPlay];
//    }
//    
//}
//- (void) stop
//{
//    [self.moviePlayer stop];
//    
//     NSLog(@"stop");
//}
//- (void) pause
//{
//    [self.moviePlayer pause];
//     NSLog(@"paused");
//}
//
//- (void) prepareToPlay
//{
//    
//}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.navigationController.toolbarHidden = YES;
    //CustomToolbar *myToolbar = [[CustomToolbar alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height,self.view.frame.size.width, 44)];
    //[self.view addSubview:myToolbar];
    [self configureMoviePlayer];
    //[self.view setNavigationBarHidden:NO];
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
    //[doneButton setEnabled:YES];
    //self.navigationItem.leftBarButtonItem = doneButton;
    
 
    
}
- (void)endSeeking
{
    
}
-(void) configureMoviePlayer
{
    
    NSMutableArray *actualPlayerItems = [[NSMutableArray alloc] init];
    //self.view.backgroundColor = [UIColor blackColor];
    //[self initWithContentURL:[self.take getPathURL]];
    self.currentIndex = 0;
    self.takeURL = [[self.playerItems firstObject] getPathURL];
    NSLog(@"takeURL: %@ ", self.takeURL);
    
    AVPlayerItem *playerItem =[[AVPlayerItem alloc] initWithURL:self.takeURL];

    for (int i=0; i<self.playerItems.count; i++)
    {
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:[self.playerItems[i] getPathURL]];
        
        [actualPlayerItems addObject:playerItem];
    }
   
//    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:actualPlayerItems];
    //self.playerViewController.player = self.queuePlayer;

    self.playerViewController = [[AVPlayerViewController alloc] init];
    self.playerViewController.player = [AVPlayer playerWithPlayerItem:playerItem];

    //self.moviePlayer.view.backgroundColor = [UIColor blackColor];
    
    [self.playerViewController.view setFrame:self.view.bounds];
    
    // [playerView.contentOverlayView addSubview:...]
    
    [self.view addSubview:self.playerViewController.view];
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myMovieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
//
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doneAction:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:nil];
  
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieControlActions:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
    /// then get the reason user info key
    
    */
}
//- (void) movieControlActions:(NSNotification*)notification
//{
//
//    if (self.moviePlayer.playbackState== MPMoviePlaybackStateSeekingBackward)
//    {
//        NSLog(@"MPMoviePlaybackStateSeekingBackward");
//        //[self beginSeekingBackward];
//    }
//    
//    else if (self.moviePlayer.playbackState == MPMoviePlaybackStateSeekingForward)
//    {
//        NSLog(@"MPMoviePlaybackStateSeekingFORWARD");
//        //[self beginSeekingForward];
//    }
//    
//    else if (self.moviePlayer.playbackState == MPMoviePlaybackStatePaused)
//    {
//        NSLog(@"MPMoviePlaybackStatePAUSED");
//        //[self pause];
//    }
//
//    else if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying)
//    {
//        NSLog(@"MPMoviePlaybackStatePLAYING");
//        //[self play];
//    }
//}

//-(void) play
//{
//    [self.moviePlayer play];
//    
//}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
//
//- (void)doneAction:(NSNotification*)notification
//{
//    NSLog(@"Done was pressed.");
//    [self goAway];
//}

/////// When the movie is done, release the controller.
//-(void)myMovieFinishedCallback:(NSNotification*)notification
//{
//    NSNumber *reason = [notification.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
//
//    if ([reason intValue] == MPMovieFinishReasonPlaybackEnded)
//    {
//        NSLog(@"Playback ended");
//        // go to next video in the queue if there is one.
//        if (self.currentIndex == self.playerItems.count-1)
//        {
//            [self goAway];
//            return;
//        }
//        self.currentIndex++;
//        self.moviePlayer.contentURL = [self nextVideoURL];
//        [self.moviePlayer prepareToPlay];
//    }
//    
//    else if ([reason intValue] == MPMovieFinishReasonUserExited || MPMovieFinishReasonPlaybackError)
//    {
//        NSLog(@"User exited or PLAYBACK ERROR");
//        
//        //        [self dismissMoviePlayerViewControllerAnimated];
//        //
//        //        [self dismissViewControllerAnimated:YES completion:^{
//        //            [[NSNotificationCenter defaultCenter]
//        //             removeObserver:self
//        //             name:MPMoviePlayerPlaybackDidFinishNotification
//        //             object:[notification object]];
//        //        }];
//        [self goAway];
//    }
//    
//}

//- (void) goAway
//{
//    [self dismissMoviePlayerViewControllerAnimated];
//    
//    [self dismissViewControllerAnimated:YES completion:^{
//        
//        [[NSNotificationCenter defaultCenter]
//         removeObserver:self
//                   name:MPMoviePlayerWillExitFullscreenNotification
//                 object:nil];
//        
//        [[NSNotificationCenter defaultCenter]
//         removeObserver:self
//                   name:MPMoviePlayerPlaybackDidFinishNotification
//                 object:nil];
//        // object: [notification object]?
//        
//        [[NSNotificationCenter defaultCenter]
//         removeObserver:self
//                   name:MPMoviePlayerPlaybackStateDidChangeNotification
//                 object:nil];
//        
//        NSLog(@"Dismissed View Controller.");
//    }];
//}





- (IBAction)delete:(id)sender {
}

- (IBAction)star:(id)sender {
}
@end
