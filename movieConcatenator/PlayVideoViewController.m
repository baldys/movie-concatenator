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

@interface PlayVideoViewController () <MPMediaPlayback>

@end

@implementation PlayVideoViewController

- (void) beginSeekingForward
{
    
    
    
}
- (void) beginSeekingBackward
{
    
}
- (void) stop
{
    
}
- (void) pause
{
    
}

- (void) prepareToPlay
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureMoviePlayer];
    //[self.navigationController setNavigationBarHidden:NO];
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
    //[doneButton setEnabled:YES];
    //self.navigationItem.leftBarButtonItem = doneButton;
    
 
    
}
- (void)endSeeking
{
    
}
-(void) configureMoviePlayer
{
    //self.view.backgroundColor = [UIColor blackColor];
    //[self initWithContentURL:[self.take getPathURL]];
    
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:self.takeURL];
    self.moviePlayer.view.backgroundColor = [UIColor blackColor];

    [self.moviePlayer prepareToPlay];
    [self.moviePlayer.view setFrame:self.view.bounds];
    [self.view addSubview:self.moviePlayer.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myMovieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doneAction:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:nil];
    [self.moviePlayer setControlStyle:MPMovieControlStyleEmbedded];
    [self.moviePlayer setFullscreen:NO animated:YES];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(movieControlActions:)
//                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
//                                               object:nil];
    
    /// then get the reason user info key
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}


-(void) play
{
    [self.moviePlayer play];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)doneAction:(NSNotification*)notification
{
    //NSNumber *reason = [notification.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    //if ([reason intValue] == MPMovieFinishReasonUserExited) {
        // Your done button action here
        NSLog(@"Done was pressed.");
    
        [self dismissMoviePlayerViewControllerAnimated];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            [[NSNotificationCenter defaultCenter]
             removeObserver:self
             name:MPMoviePlayerWillExitFullscreenNotification
             object:nil];
            [[NSNotificationCenter defaultCenter]
             removeObserver:self
             name:MPMoviePlayerPlaybackDidFinishNotification
             object:nil];
            
            NSLog(@"Dismissed View Controller.");
            
        }];
        
  
   
}

/// When the movie is done, release the controller.
-(void)myMovieFinishedCallback:(NSNotification*)aNotification {
    
    
    MPMoviePlayerController* moviePlayer = [aNotification object];
    
    [[NSNotificationCenter defaultCenter]
      removeObserver:self
      name:MPMoviePlayerPlaybackDidFinishNotification
      object:moviePlayer];
    
    [self dismissMoviePlayerViewControllerAnimated];
    
    [self dismissViewControllerAnimated:YES completion:^{
        //
        
    }];
}



@end
