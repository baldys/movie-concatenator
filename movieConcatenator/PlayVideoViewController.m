//
//  PlayVideoViewController.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-21.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "PlayVideoViewController.h"

@interface PlayVideoViewController ()



@end

@implementation PlayVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureMoviePlayer];

    
    
}

-(void) configureMoviePlayer {
    self.view.backgroundColor = [UIColor blueColor];
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[self.take getPathURL]];
    
  //  NSLog(@"self.take.assetFIleURL:%@", [self.take getPathURL]);
    self.moviePlayer.view.backgroundColor = [UIColor redColor];
    [self.moviePlayer prepareToPlay];
    
    [self.moviePlayer.view setFrame: self.view.bounds];
    [self.view addSubview:self.moviePlayer.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.moviePlayer play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


/// When the movie is done, release the controller.
-(void)myMovieFinishedCallback:(NSNotification*)aNotification {
    [self dismissMoviePlayerViewControllerAnimated];
    MPMoviePlayerController* moviePlayer = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    [self dismissMoviePlayerViewControllerAnimated];
    [self dismissViewControllerAnimated:YES completion:^{
        //
        
    }];
}



@end
