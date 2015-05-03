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

@interface PlayVideoViewController ()
@property (nonatomic) NSInteger currentItemIndex;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *starButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashButton;
- (IBAction)delete:(id)sender;
- (IBAction)star:(id)sender;

@property (nonatomic) BOOL showBarsOnTap;
@property (nonatomic, getter=areBarsHidden) BOOL barsHidden;

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

- (void)deviceOrientationDidChange:(NSNotification *)notification

{
    //Obtaining the current device orientation
    
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    if (currentOrientation == UIDeviceOrientationLandscapeLeft ||
        currentOrientation == UIDeviceOrientationLandscapeRight)
    {
        if (self.playerViewController.showsPlaybackControls)
        {
            [self hideBars];
        }
        else
        {
            [self showBars];
        }
    }
    else if (currentOrientation == UIDeviceOrientationPortrait)
    {
        if (self.playerViewController.showsPlaybackControls)
        {
            [self hideBars];
        }
        else
        {
            [self showBars];
        }
    }
    // Do your Code using the current Orienation
    
}
- (void) showBars
{
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];
    self.barsHidden = NO;
}
- (void) hideBars
{
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    self.barsHidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.navigationController.toolbarHidden = YES;
    //CustomToolbar *myToolbar = [[CustomToolbar alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height,self.view.frame.size.width, 44)];
    //[self.view addSubview:myToolbar];
    [self showBars];
    // do kvo for the device orientation (add observer for key path ...)
    [self.trashButton setAction:@selector(delete:)];
    if ([self.takeToPlay isSelected])
    {
        [self.starButton setImage:[UIImage imageNamed:@"blue-star-32"]];
        [self.starButton setLandscapeImagePhone:[UIImage imageNamed:@"blue-star-24"]];
    }
    else
    {
        [self.starButton setLandscapeImagePhone:[UIImage imageNamed:@"white-outline-star-24"]];
    }
    
    [self.starButton setAction:@selector(star:)];
    
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    //[self checkOrientation:orientation];
    
    

    //[self.view setNavigationBarHidden:NO];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    // Create and initialize a tap gesture
    //UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             //initWithTarget:self action:@selector(respondToTapGesture:)];
    
    // Specify that the gesture must be a single tap
    //tapRecognizer.numberOfTapsRequired = 1;
    
    // Add the tap gesture recognizer to the view
    //[self.view addGestureRecognizer:tapRecognizer];
    [self configureMoviePlayer];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
    //[doneButton setEnabled:YES];
    //self.navigationItem.leftBarButtonItem = doneButton;
    
    
 
    
}

//- (IBAction)respondToTapGesture:(id)sender
//{
//    BOOL playbackControls = [self playerViewController].showsPlaybackControls;
//    
//    if ([self areBarsHidden])
//    {
//        [self showBars];
//        
//    }
//    else
//    {
//        [self hideBars];
//    }
//
//    
//}
-(void) configureMoviePlayer
{
    
    //NSMutableArray *actualPlayerItems = [[NSMutableArray alloc] init];
    //self.view.backgroundColor = [UIColor blackColor];
    //[self initWithContentURL:[self.take getPathURL]];
    //self.currentItemIndex = 0;
    
    //self.takeURL = self.takeToPlay;
    //NSLog(@"takeURL: %@ ", self.takeURL);
    
    AVPlayerItem *playerItem =[[AVPlayerItem alloc] initWithURL:[self.takeToPlay getPathURL]];
//
//    for (int i=0; i<self.playerItems.count; i++)
//    {
//        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:[self.playerItems[i] getPathURL]];
//        
//        [actualPlayerItems addObject:playerItem];
//    }
   
//    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:actualPlayerItems];
    //self.playerViewController.player = self.queuePlayer;

    self.playerViewController = [[AVPlayerViewController alloc] init];
    self.playerViewController.player = [AVPlayer playerWithPlayerItem:playerItem];

    //self.moviePlayer.view.backgroundColor = [UIColor blackColor];
    
    [self.playerViewController.view setFrame:self.view.bounds];
    
    //[self.playerViewController.contentOverlayView addSubview:self.navigationController.toolbar];
    
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




- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}


- (IBAction)delete:(id)sender
{
    NSLog(@"the delete button was pressed?");
   UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Delete Take" message:@"This action cannot be undone" preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldDeleteTake" object:self.takeToPlay];
        NSLog(@"should delete take");
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
        
    
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:deleteAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:^{
    }];
    
}

- (IBAction)star:(id)sender
{
    // if the take has not been selected to be put in the list of videos to concatenate
    //self.takeToPlay.selected = !self.takeToPlay.selected;
    
    
    if (![self.takeToPlay isSelected])
    {
        [self.starButton setImage:[UIImage imageNamed:@"blue-star-32"]];
         [self.starButton setLandscapeImagePhone:[UIImage imageNamed:@"blue-star-24"]];
        [self.takeToPlay setSelected:YES];
    }
    else{
        [self.starButton setImage:[UIImage imageNamed:@"white-outline-star-32"]];
        [self.starButton setLandscapeImagePhone:[UIImage imageNamed:@"white-outline-star-24"]];
        [self.takeToPlay setSelected:NO];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectStarButtonInCell" object:self.takeToPlay];
    
}
@end
