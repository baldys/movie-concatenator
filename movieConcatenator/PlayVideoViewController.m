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

@interface PlayVideoViewController ()

@end

@implementation PlayVideoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureMoviePlayer];
    self.navigationController.navigationBarHidden = NO;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
    [doneButton setEnabled:YES];
    self.navigationItem.leftBarButtonItem = doneButton;
    
    
    
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
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.moviePlayer play];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)doneAction:(UIBarButtonItem*)sender
{
    NSLog(@"Done was pressed.");
    
    [self dismissMoviePlayerViewControllerAnimated];
    
    [self dismissViewControllerAnimated:YES completion:^{
        //
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
