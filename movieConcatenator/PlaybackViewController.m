//
//  PlaybackViewController.m
//  DemoReel
//
//  Created by Veronica Baldys on 2015-04-24.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "PlaybackViewController.h"
#import "PlaybackView.h"

@interface PlaybackViewController ()

- (void)play:(id)sender;
- (void)pause:(id)sender;
//- (void)showMetadata:(id)sender;
- (void)initScrubberTimer;
- (void)showPlayButton;
- (void)showPauseButton;
- (void)syncScrubber;
- (IBAction)beginScrubbing:(id)sender;
- (IBAction)scrub:(id)sender;
- (IBAction)endScrubbing:(id)sender;
- (BOOL)isScrubbing;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)viewDidLoad;
- (void)viewWillDisappear:(BOOL)animated;
- (void)handleSwipe:(UISwipeGestureRecognizer*)gestureRecognizer;
- (void)syncPlayPauseButtons;
- (void)setURLFromTake;
//- (void)setURL:(NSURL*)URL;
//- (NSURL*)URL;

@property (strong, nonatomic) UISlider *startTrimScrubber;
@property (strong, nonatomic) UISlider *endTrimScrubber;

@property (nonatomic, getter=isTrimmingVideo) BOOL trimmingVideo;
@property (strong, nonatomic) UIBarButtonItem *starButton;
@property (strong, nonatomic) UIBarButtonItem *trashButton;

@property (strong, nonatomic) UIBarButtonItem *trimButton;
@property (nonatomic, strong) UIView *trimmingControlsView;
@property (strong, nonatomic) UIBarButtonItem *doneTrimmingButton;

- (IBAction)delete:(id)sender;
- (IBAction)star:(id)sender;
- (IBAction)trim:(id)sender;

@end

@interface PlaybackViewController (Player)

- (void)removePlayerTimeObserver;
- (CMTime)playerItemDuration;
- (BOOL)isPlaying;
- (void)playerItemDidReachEnd:(NSNotification *)notification ;
- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys;



@end

static void *PlaybackViewControllerRateObservationContext = &PlaybackViewControllerRateObservationContext;
static void *PlaybackViewControllerStatusObservationContext = &PlaybackViewControllerStatusObservationContext;
static void *PlaybackViewControllerCurrentItemObservationContext = &PlaybackViewControllerCurrentItemObservationContext;

#pragma mark -
@implementation PlaybackViewController

#pragma mark Asset URL

//-(NSURL*)URL
//{
//    return mURL;
//}
- (void)setURLFromTake
{
    if (!self.takeToPlay)
    {
        return;
    }
    /*
     Create an asset for inspection of a resource referenced by a given URL.
     Load the values for the asset key "playable".
     */
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[self.takeToPlay getFileURL] options:nil];
    NSArray *requestedKeys = @[@"playable"];
    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
    ^{
        dispatch_async( dispatch_get_main_queue(),
        ^{
            /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
            [self prepareToPlayAsset:asset withKeys:requestedKeys];
        });
    }];
}

#pragma mark -
#pragma mark Movie controller methods

#pragma mark
#pragma mark Button Action Methods
- (void) creteBarButtonItems
{
    self.mPlayButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(play:)];
    self.mPauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pause:)];
    self.mScrubber = [[UISlider alloc] init];
    
    self.trashButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(delete:)];
    self.starButton = [[UIBarButtonItem alloc] init];
    //[self.starButton setTarget:self];
    if ([self.takeToPlay isSelected])
    {
        [self.starButton setImage:[UIImage imageNamed:@"blue-star-32"]];
        [self.starButton setLandscapeImagePhone:[UIImage imageNamed:@"blue-star-24"]];
    }
    else
    {
        [self.starButton setImage:[UIImage imageNamed:@"white-outline-star-32"]];
        [self.starButton setLandscapeImagePhone:[UIImage imageNamed:@"white-outline-star-24"]];
    }
    [self.starButton setAction:@selector(star:)];
    
    self.trimButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"scissors-32"] landscapeImagePhone:[UIImage imageNamed:@"scissors-24"] style:UIBarButtonItemStyleDone target:self action:@selector(trim:)];
    
    [self.mScrubber addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventTouchDragInside];
    [self.mScrubber addTarget:self action:@selector(beginScrubbing:) forControlEvents:UIControlEventTouchDragEnter];
    [self.mScrubber addTarget:self action:@selector(endScrubbing:)forControlEvents:UIControlEventTouchDragExit];
    
    //[self.trashButton setAction:@selector(delete:)];
    
  
    //[self.starButton setAction:@selector(star:)];
    
}

//- (void) setSelectedStarImage
//{
//    if (![self.takeToPlay isSelected])
//    {
//        [self.starButton setImage:[UIImage imageNamed:@"blue-star-32"]];
//        [self.starButton setLandscapeImagePhone:[UIImage imageNamed:@"blue-star-24"]];
//        [self.takeToPlay setSelected:YES];
//    }
//    
//}
//-(void) setDeselectedStarImage
//{
//    
//    [self.starButton setImage:[UIImage imageNamed:@"white-outline-star-32"]];
//    [self.starButton setLandscapeImagePhone:[UIImage imageNamed:@"white-outline-star-24"]];
//    [self.takeToPlay setSelected:NO];
//    
// 
//}

- (IBAction)play:(id)sender
{
    /* If we are at the end of the movie, we must seek to the beginning first
     before starting playback. */
    if (YES == seekToZeroBeforePlay)
    {
        seekToZeroBeforePlay = NO;
        [self.mPlayer seekToTime:kCMTimeZero];
    }
    
    [self.mPlayer play];
    
    [self showPauseButton];
}

- (IBAction)pause:(id)sender
{
    [self.mPlayer pause];
    
    [self showPlayButton];
}


#pragma mark - bottom toolbar buttons/actions.


- (IBAction)delete:(id)sender
{
    BOOL __block didConfirmDelete = NO;
    NSLog(@"the delete button was pressed?");
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Delete Take" message:@"This action cannot be undone" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        
        didConfirmDelete = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldDeleteTake" object:self.takeToPlay];
        NSLog(@"should delete take");
        
        [self.navigationController popViewControllerAnimated:YES];
        
        
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:deleteAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:^{
        if (didConfirmDelete)
        {
            NSLog(@"did confirm delete");
        }
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

- (void) enableTrimmingSliders
{
    [self.startTrimScrubber setEnabled:YES];
    [self.endTrimScrubber setEnabled:YES];
}

- (void)disableTrimmingSliders
{
    [self.startTrimScrubber setEnabled:NO];
    [self.endTrimScrubber setEnabled:NO];
}

- (void) unhideBars
{
    [self.mToolbar setHidden:NO];
    
    [self.tabBarController.tabBar setHidden:NO];
}
- (void) hideBars
{
    [self.mToolbar setHidden:YES];
    
    [self.tabBarController.tabBar setHidden:YES];
    
}

- (void) showTrimmingControls
{
   // [self.trimmingControlsView setHidden:NO];
    
   // self.trimmingControlsView.frame = CGRectMake(0,self.view.frame.size.height-200, self.view.frame.size.width, 200);
    
    [UIView animateWithDuration:0.5 animations:^{
        
        [self.trimmingControlsView setTransform:CGAffineTransformMakeTranslation(0.f, CGRectGetHeight([self.trimmingControlsView bounds])) ];
        //self.trimmingControlsView.frame = CGRectOffset(self.trimmingControlsView.frame, 0, -200);
       // self.trimmingControlsView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 200);

    } completion:
     ^(BOOL finished)
     {
         [self hideBars];
     }];
}
- (void) hideTrimmingControls
{
    if (self.startTrimScrubber.isHidden && self.endTrimScrubber.isHidden)
    {
        return;
    }
    [UIView animateWithDuration:0.5 animations:^{
        [self.trimmingControlsView setTransform:CGAffineTransformIdentity];
        //self.trimmingControlsView.frame = CGRectZero;
    } completion:
     ^(BOOL finished)
     {
         [self unhideBars];
         [self.doneTrimmingButton setEnabled:NO];
     }];
    
}
#pragma mark - trimming controls

// show trimming controls
- (void)initializeTrimmingControls
{
    //UIView* view  = [self view];
    
    //self.trimmingControlsView = [[UIView alloc] init];
    
    //self.trimmingControlsView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-200, self.view.bounds.size.width, 200)];
    
    //self.trimmingControlsView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    [self.trimmingControlsView setBackgroundColor:[UIColor redColor]];
    [self.trimmingControlsView setOpaque:YES];
    
    [self.view addSubview:self.trimmingControlsView];

    [self.view bringSubviewToFront:self.trimmingControlsView];
    
    
    self.startTrimScrubber = [[UISlider alloc] init];
    self.endTrimScrubber = [[UISlider alloc] init];
    
    [self.startTrimScrubber addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventTouchDragInside];
    [self.startTrimScrubber addTarget:self action:@selector(beginScrubbing:) forControlEvents:UIControlEventTouchDragEnter];
    [self.startTrimScrubber addTarget:self action:@selector(endScrubbing:)forControlEvents:UIControlEventTouchDragExit];
   
    [self.endTrimScrubber addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventTouchDragInside];
    [self.endTrimScrubber addTarget:self action:@selector(beginScrubbing:) forControlEvents:UIControlEventTouchDragEnter];
    [self.endTrimScrubber addTarget:self action:@selector(endScrubbing:)forControlEvents:UIControlEventTouchDragExit];
    
    self.startTrimScrubber.frame = CGRectMake(80, self.trimmingControlsView.frame.size.height-100, self.trimmingControlsView.frame.size.width-140, 20);
    self.endTrimScrubber.frame = CGRectMake(80, self.trimmingControlsView.bounds.size.height-100, self.trimmingControlsView.frame.size.width-140, 20);
    
    
    //[self.view addSubview:self.trimmingControlsView];
    [self.trimmingControlsView addSubview:self.startTrimScrubber];
    [self.trimmingControlsView addSubview:self.endTrimScrubber];
    
    [UIView animateWithDuration:0.5 animations:^{
        
        [self.trimmingControlsView setTransform:CGAffineTransformMakeTranslation(0.f, -200)];
        //self.trimmingControlsView.frame = CGRectOffset(self.trimmingControlsView.frame, 0, -200);
        // self.trimmingControlsView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 200);
        
    } completion:
     ^(BOOL finished)
     {
         //[self hideBars];
     }];

    
    
}

- (IBAction)trim:(id)sender
{
    [self.trimmingControlsView setHidden:NO];
    self.trimmingVideo = YES;
    [self disableScrubber];
    [self enableTrimmingSliders];
    [self initializeTrimmingControls];
    self.doneTrimmingButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(finishTrimmingVideo:)];
    self.navigationItem.rightBarButtonItem = self.doneTrimmingButton;
    [self.doneTrimmingButton setEnabled:YES];
    
    // if this button gets pressed, whatever position the slider is in will correspond to the time in which the video should be cut out when a done button is pressed. set this time to the new time range of the take that is being played.
    
    // if slider gets moved to a new position then the done button gets pressed, that value will be the new start time value
    
    
}

- (IBAction)finishTrimmingVideo:(id)sender
{
    // the done button was pressed. get the last time represented by the slider
    self.trimmingVideo = NO;
    //self.trimmingControlsView.frame = self.view.frame.size.height;
    
    
    [self hideTrimmingControls];
    [self enableScrubber];
    [self disableTrimmingSliders];
//    self.trimmingControlsView = nil;
//    [self.trimmingControlsView removeFromSuperview];
    
}
/* Display AVMetadataCommonKeyTitle and AVMetadataCommonKeyCopyrights metadata. */
//- (IBAction)showMetadata:(id)sender
//{
//    MetadataViewController* metadataViewController = [[MetadataViewController alloc] init];
//    
//    [metadataViewController setMetadata:[[[self.mPlayer currentItem] asset] commonMetadata]];
//    
//    [self presentViewController:metadataViewController animated:YES completion:NULL];
//    
//}

#pragma mark -
#pragma mark Play, Stop buttons

/* Show the stop button in the movie player controller. */
-(void)showPauseButton
{
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:[self.mToolbar items]];
    [toolbarItems replaceObjectAtIndex:0 withObject:self.mPauseButton];
    self.mToolbar.items = toolbarItems;
}

/* Show the play button in the movie player controller. */
-(void)showPlayButton
{
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:[self.mToolbar items]];
    [toolbarItems replaceObjectAtIndex:0 withObject:self.mPlayButton];
    self.mToolbar.items = toolbarItems;
}

/* If the media is playing, show the stop button; otherwise, show the play button. */
- (void)syncPlayPauseButtons
{
    if ([self isPlaying])
    {
        [self showPauseButton];
    }
    else
    {
        [self showPlayButton];
    }
}

-(void)enablePlayerButtons
{
    self.mPlayButton.enabled = YES;
    self.mPauseButton.enabled = YES;
}

-(void)disablePlayerButtons
{
    self.mPlayButton.enabled = NO;
    self.mPauseButton.enabled = NO;
}

#pragma mark -
#pragma mark Movie scrubber control

/* ---------------------------------------------------------
 **  Methods to handle manipulation of the movie scrubber control
 ** ------------------------------------------------------- */

/* Requests invocation of a given block during media playback to update the movie scrubber control. */
-(void)initScrubberTimer
{
    double interval = .01f;
    
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        CGFloat width = CGRectGetWidth([self.mScrubber bounds]);
        interval = 0.5f * duration / width;
    }
    
    /* Update the scrubber during normal playback. */
    __weak PlaybackViewController *weakSelf = self;
    mTimeObserver = [self.mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) queue:NULL /* If you pass NULL, the main queue is used. */ usingBlock:^(CMTime time)
        {
            [weakSelf syncScrubber];
        }];
}

/* Set the scrubber based on the player current time. */
- (void)syncScrubber
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        self.mScrubber.minimumValue = 0.0;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    
    if (isfinite(duration))
    {
        float minValue = [self.mScrubber minimumValue];
        float maxValue = [self.mScrubber maximumValue];
        double time = CMTimeGetSeconds([self.mPlayer currentTime]);
        
        [self.mScrubber setValue:(maxValue - minValue) * time / duration + minValue];
    }
}

/* The user is dragging the movie controller thumb to scrub through the movie. */
- (IBAction)beginScrubbing:(id)sender
{
    mRestoreAfterScrubbingRate = [self.mPlayer rate];
    [self.mPlayer setRate:0.f];
    
    /* Remove previous timer. */
    [self removePlayerTimeObserver];
}

/* Set the player current time to match the scrubber position. */
- (IBAction)scrub:(id)sender
{
    if ([sender isKindOfClass:[UISlider class]] && !isSeeking)
    {
        isSeeking = YES;
        UISlider* slider = sender;
        
        CMTime playerDuration = [self playerItemDuration];
        
        if (CMTIME_IS_INVALID(playerDuration))
        {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        
    
        if (isfinite(duration))
        {
            float minValue = [slider minimumValue];
            float maxValue = [slider maximumValue];
            float value = [slider value];
            NSLog(@"slider value: %f", value);
            double time = duration * (value - minValue) / (maxValue - minValue);
            
            
            // if the video is to be trimmed, get the sliders time
            if (self.isTrimmingVideo)
            {
                if (sender == self.startTrimScrubber)
                {
                    self.trimmedTime_initial = CMTimeMake(duration*(value-minValue), maxValue-minValue);;
                }
                else if (sender == self.endTrimScrubber)
                {
                    self.trimmedTime_final = CMTimeMake(duration*(value-minValue), maxValue-minValue);;
                }
                NSLog(@"time: %f", time);
            }
            
            [self.mPlayer seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    isSeeking = NO;
                });
            }];
        }
    }
}

/* The user has released the movie thumb control to stop scrubbing through the movie. */
- (IBAction)endScrubbing:(id)sender
{
    if (!mTimeObserver)
    {
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration))
        {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        
        if (isfinite(duration))
        {
            CGFloat width = CGRectGetWidth([self.mScrubber bounds]);
            double tolerance = 0.5f * duration / width;
            
            __weak PlaybackViewController *weakSelf = self;
            mTimeObserver = [self.mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:NULL usingBlock:
                             ^(CMTime time)
                             {
                                 [weakSelf syncScrubber];
                             }];
        }
    }
    
    if (mRestoreAfterScrubbingRate)
    {
        [self.mPlayer setRate:mRestoreAfterScrubbingRate];
        mRestoreAfterScrubbingRate = 0.f;
    }
}

- (BOOL)isScrubbing
{
    return mRestoreAfterScrubbingRate != 0.f;
}

-(void)enableScrubber
{
    self.mScrubber.enabled = YES;
}

-(void)disableScrubber
{
    self.mScrubber.enabled = NO;
}





#pragma mark
#pragma mark View Controller
//
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
//    {
//        [self setPlayer:nil];
//        
//        [self setEdgesForExtendedLayout:UIRectEdgeAll];
//    }
//    
//    return self;
//}

//- (id)init
//{
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//    {
//        return [self initWithNibName:@"PlaybackView-iPad" bundle:nil];
//    }
//    else
//    {
        //return [self initWithNibName:@"PlaybackView" bundle:nil];
    //}
//}

- (void)viewDidUnload
{
    [super viewDidUnload];
}
//- (void) viewWillAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    [self.tabBarController hidesBottomBarWhenPushed];
//    [self.navigationController setToolbarHidden:NO animated:NO];
//}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    if (self.takeToPlay)
    {
        [self setURLFromTake];
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setPlayer:nil];
    [self creteBarButtonItems];
    
    UIView* view  = [self view];

    [self.navigationController setToolbarHidden:NO animated:NO];

    UISwipeGestureRecognizer* swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [swipeUpRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [view addGestureRecognizer:swipeUpRecognizer];
    
    UISwipeGestureRecognizer* swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [swipeDownRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [view addGestureRecognizer:swipeDownRecognizer];
    
    UIBarButtonItem *scrubberItem = [[UIBarButtonItem alloc] initWithCustomView:self.mScrubber];
    
    //UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    //UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    
    //[infoButton addTarget:self action:@selector(showMetadata:) forControlEvents:UIControlEventTouchUpInside];
    
    //UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    
    self.mToolbar.items = @[self.mPlayButton, scrubberItem, self.trimButton, self.starButton, self.trashButton];//, infoItem];
    CGFloat spaceForScrubberOnToolbar = self.view.frame.size.width - (36*self.mToolbar.items.count);
    [scrubberItem setWidth:spaceForScrubberOnToolbar];
    isSeeking = NO;
    [self initScrubberTimer];
    
    [self syncPlayPauseButtons];
    [self syncScrubber];
    //[self initializeTrimmingControls];
    self.trimmingControlsView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.trimmingControlsView];
    self.trimmingControlsView.frame = CGRectMake(0, self.view.frame.size.height, self.view.bounds.size.width, 200);
    [self.view bringSubviewToFront:self.trimmingControlsView];
    
    //self.trimmingControlsView = [[UIView alloc] initWithFrame:CGRectZero];
    //[self.view addSubview:self.trimmingControlsView];
    [self.trimmingControlsView setHidden:NO];
}

-  (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self removePlayerTimeObserver];
    
    [self.mPlayer removeObserver:self forKeyPath:@"rate"];
    [self.mPlayer.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player removeObserver:self
                  forKeyPath:@"currentItem"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:self.mPlayerItem];
    

}

- (void)viewWillDisappear:(BOOL)animated
{
    
    
    
    [self.mPlayer pause];
    
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)setViewDisplayName
{
    /* Set the view title to the last component of the asset URL. */
    //self.title = [[self.takeToPlay getPathURL] lastPathComponent];
    
    /* Or if the item has a AVMetadataCommonKeyTitle metadata, use that instead. */
    
//    for (AVMetadataItem* item in ([[[self.mPlayer currentItem] asset] commonMetadata]))
//    {
//        NSString* commonKey = [item commonKey];
//        
//        if ([commonKey isEqualToString:AVMetadataCommonKeyTitle])
//        {
//            self.title = [item stringValue];
//        }
//    }
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    UIView* view = [self view];
    UISwipeGestureRecognizerDirection direction = [gestureRecognizer direction];
    CGPoint location = [gestureRecognizer locationInView:view];
    
    if (location.y < CGRectGetMidY([view bounds]))
    {
        if (direction == UISwipeGestureRecognizerDirectionUp)
        {
            [UIView animateWithDuration:0.2f animations:
             ^{
                 [[self navigationController] setNavigationBarHidden:YES animated:YES];
             } completion:
             ^(BOOL finished)
             {
                 [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
             }];
        }
        if (direction == UISwipeGestureRecognizerDirectionDown)
        {
            [UIView animateWithDuration:0.2f animations:
             ^{
                 [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
             } completion:
             ^(BOOL finished)
             {
                 [[self navigationController] setNavigationBarHidden:NO animated:YES];
             }];
        }
    }
    else
    {
        if (direction == UISwipeGestureRecognizerDirectionDown)
        {
            if (![self.mToolbar isHidden])
            {
                [UIView animateWithDuration:0.2f animations:
                 ^{
                     [self.mToolbar setTransform:CGAffineTransformMakeTranslation(0.f, CGRectGetHeight([self.mToolbar bounds]))];
                 } completion:
                 ^(BOOL finished)
                 {
                     [self.mToolbar setHidden:YES];
                 }];
            }
        }
        else if (direction == UISwipeGestureRecognizerDirectionUp)
        {
            if ([self.mToolbar isHidden])
            {
                [self.mToolbar setHidden:NO];
                
                [UIView animateWithDuration:0.2f animations:
                 ^{
                     [self.mToolbar setTransform:CGAffineTransformIdentity];
                 } completion:^(BOOL finished){}];
            }
        }
    }
}

- (void)dealloc
{
    self.mPlaybackView = nil;
    
    self.mToolbar = nil;
    self.mPlayButton = nil;
    self.mPauseButton = nil;
    self.mScrubber = nil;
    
    [self.mPlayer pause];
    
    
}

@end

@implementation PlaybackViewController (Player)

#pragma mark Player Item

- (BOOL)isPlaying
{
    return mRestoreAfterScrubbingRate != 0.f || [self.mPlayer rate] != 0.f;
}

/* Called when the player item has played to its end time. */
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    /* After the movie has played to its end time, seek back to time zero
     to play it again. */
    seekToZeroBeforePlay = YES;
}

/* ---------------------------------------------------------
 **  Get the duration for a AVPlayerItem.
 ** ------------------------------------------------------- */

- (CMTime)playerItemDuration
{
    AVPlayerItem *playerItem = [self.mPlayer currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return([playerItem duration]);
    }
    
    return(kCMTimeInvalid);
}


/* Cancels the previously registered time observer. */
-(void)removePlayerTimeObserver
{
    if (mTimeObserver)
    {
        [self.mPlayer removeTimeObserver:mTimeObserver];
        mTimeObserver = nil;
    }
}

#pragma mark -
#pragma mark Loading the Asset Keys Asynchronously

#pragma mark -
#pragma mark Error Handling - Preparing Assets for Playback Failed

/* --------------------------------------------------------------
 **  Called when an asset fails to prepare for playback for any of
 **  the following reasons:
 **
 **  1) values of asset keys did not load successfully,
 **  2) the asset keys did load successfully, but the asset is not
 **     playable
 **  3) the item did not become ready to play.
 ** ----------------------------------------------------------- */

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self removePlayerTimeObserver];
    [self syncScrubber];
    [self disableScrubber];
    [self disablePlayerButtons];
    
    /* Display the error. */
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                        message:[error localizedFailureReason]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}


#pragma mark Prepare to play asset, URL

/*
 Invoked at the completion of the loading of the values for all keys on the asset that we require.
 Checks whether loading was successfull and whether the asset is playable.
 If so, sets up an AVPlayerItem and an AVPlayer to play the asset.
 */
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    /* Make sure that the value of each key has loaded successfully. */
    for (NSString *thisKey in requestedKeys)
    {
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        if (keyStatus == AVKeyValueStatusFailed)
        {
            [self assetFailedToPrepareForPlayback:error];
            return;
        }
        /* If you are also implementing -[AVAsset cancelLoading], add your code here to bail out properly in the case of cancellation. */
    }
    
    /* Use the AVAsset playable property to detect whether the asset can be played. */
    if (!asset.playable)
    {
        /* Generate an error describing the failure. */
        NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
        NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   localizedDescription, NSLocalizedDescriptionKey,
                                   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
                                   nil];
        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        /* Display the error to the user. */
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        
        return;
    }
    
    /* At this point we're ready to set up for playback of the asset. */
    
    /* Stop observing our prior AVPlayerItem, if we have one. */
    if (self.mPlayerItem)
    {
        /* Remove existing player item key value observers and notifications. */
        
        [self.mPlayerItem removeObserver:self forKeyPath:@"status"];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.mPlayerItem];
    }
    
    /* Create a new instance of AVPlayerItem from the now successfully loaded AVAsset. */
    self.mPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    /* Observe the player item "status" key to determine when it is ready to play. */
    [self.mPlayerItem addObserver:self
                       forKeyPath:@"status"
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:PlaybackViewControllerStatusObservationContext];
    
    /* When the player item has played to its end time we'll toggle
     the movie controller Pause button to be the Play button */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.mPlayerItem];
    
    seekToZeroBeforePlay = NO;
    
    /* Create new player, if we don't already have one. */
    if (!self.mPlayer)
    {
        /* Get a new AVPlayer initialized to play the specified player item. */
        [self setPlayer:[AVPlayer playerWithPlayerItem:self.mPlayerItem]];
        
        /* Observe the AVPlayer "currentItem" property to find out when any
         AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
         occur.*/
        [self.player addObserver:self
                      forKeyPath:@"currentItem"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:PlaybackViewControllerCurrentItemObservationContext];
        
        /* Observe the AVPlayer "rate" property to update the scrubber control. */
        [self.player addObserver:self
                      forKeyPath:@"rate"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:PlaybackViewControllerRateObservationContext];
    }
    
    /* Make our new AVPlayerItem the AVPlayer's current item. */
    if (self.player.currentItem != self.mPlayerItem)
    {
        /* Replace the player item with a new player item. The item replacement occurs
         asynchronously; observe the currentItem property to find out when the
         replacement will/did occur
         
         If needed, configure player item here (example: adding outputs, setting text style rules,
         selecting media options) before associating it with a player
         */
        [self.mPlayer replaceCurrentItemWithPlayerItem:self.mPlayerItem];
        
        [self syncPlayPauseButtons];
    }
    
    [self.mScrubber setValue:0.0];
}

#pragma mark -
#pragma mark Asset Key Value Observing
#pragma mark

#pragma mark Key Value Observer for player rate, currentItem, player item status

/* ---------------------------------------------------------
 **  Called when the value at the specified key path relative
 **  to the given object has changed.
 **  Adjust the movie play and pause button controls when the
 **  player item "status" value changes. Update the movie
 **  scrubber control when the player item is ready to play.
 **  Adjust the movie scrubber control when the player item
 **  "rate" value changes. For updates of the player
 **  "currentItem" property, set the AVPlayer for which the
 **  player layer displays visual output.
 **  NOTE: this method is invoked on the main queue.
 ** ------------------------------------------------------- */

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    /* AVPlayerItem "status" property value observer. */
    if (context == PlaybackViewControllerStatusObservationContext)
    {
        [self syncPlayPauseButtons];
        
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerItemStatusUnknown:
            {
                [self removePlayerTimeObserver];
                [self syncScrubber];
                
                [self disableScrubber];
                [self disablePlayerButtons];
            }
                break;
                
            case AVPlayerItemStatusReadyToPlay:
            {
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                
                [self initScrubberTimer];
                
                [self enableScrubber];
                [self enablePlayerButtons];
            }
                break;
                
            case AVPlayerItemStatusFailed:
            {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:playerItem.error];
            }
                break;
        }
    }
    /* AVPlayer "rate" property value observer. */
    else if (context == PlaybackViewControllerRateObservationContext)
    {
        [self syncPlayPauseButtons];
    }
    /* AVPlayer "currentItem" property observer. 
     Called when the AVPlayer replaceCurrentItemWithPlayerItem: 
     replacement will/did occur. */
    else if (context == PlaybackViewControllerCurrentItemObservationContext)
    {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        /* Is the new player item null? */
        if (newPlayerItem == (id)[NSNull null])
        {
            [self disablePlayerButtons];
            [self disableScrubber];
        }
        else /* Replacement of player currentItem has occurred */
        {
            /* Set the AVPlayer for which the player layer displays visual output. */
            [self.mPlaybackView setPlayer:_mPlayer];
            
            [self setViewDisplayName];
            
            /* Specifies that the player should preserve the video’s aspect ratio and 
             fit the video within the layer’s bounds. */
            [self.mPlaybackView setVideoFillMode:AVLayerVideoGravityResizeAspect];
            
            [self syncPlayPauseButtons];
        }
    }
    else
    {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



@end


