//
//  TrimmingControlsView.m
//  DemoReel
//
//  Created by Veronica Baldys on 2015-05-25.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//
//
//#import "TrimmingControlsView.h"
//
//@implementation TrimmingControlsView
//
//
//- (void) showTrimmingControls
//{
//    // [self.trimmingControlsView setHidden:NO];
//    
//    // self.trimmingControlsView.frame = CGRectMake(0,self.view.frame.size.height-200, self.view.frame.size.width, 200);
//    
//    [UIView animateWithDuration:0.5 animations:^{
//        
//        [self setTransform:CGAffineTransformMakeTranslation(0.f, CGRectGetHeight([self bounds])) ];
//        //self.trimmingControlsView.frame = CGRectOffset(self.trimmingControlsView.frame, 0, -200);
//        // self.trimmingControlsView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 200);
//        
//    } completion:
//     ^(BOOL finished)
//     {
//         //[self hideBars];
//     }];
//}
//- (void) hideTrimmingControls
//{
//    if (self.startTrimScrubber.isHidden && self.endTrimScrubber.isHidden)
//    {
//        return;
//    }
//    [UIView animateWithDuration:0.5 animations:^{
//        [self setTransform:CGAffineTransformIdentity];
//        //self.trimmingControlsView.frame = CGRectZero;
//    } completion:
//     ^(BOOL finished)
//     {
//         //[self unhideBars];
//         //[self.doneTrimmingButton setEnabled:NO];
//     }];
//    
//}
//#pragma mark - trimming controls
//
//// show trimming controls
//- (void)initializeTrimmingControls
//{
//    //UIView* view  = [self view];
//    
//    //self.trimmingControlsView = [[UIView alloc] init];
//    
//    //self.trimmingControlsView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-200, self.view.bounds.size.width, 200)];
//    
//    //self.trimmingControlsView = [[UIView alloc] initWithFrame:CGRectZero];
//    
//    
//    [self setBackgroundColor:[UIColor blackColor]];
//    [self setOpaque:YES];
//    
//   // [self.view addSubview:self.trimmingControlsView];
//    
//    //[self.view bringSubviewToFront:self.trimmingControlsView];
//    
//    if(!self.startTrimScrubber && !self.endTrimScrubber)
//    {
//        self.startTrimScrubber = [[UISlider alloc] init];
//        self.endTrimScrubber = [[UISlider alloc] init];
//    }
//    
//    
//    [self.startTrimScrubber addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventTouchDragInside];
//    [self.startTrimScrubber addTarget:self action:@selector(beginScrubbing:) forControlEvents:UIControlEventTouchDragEnter];
//    [self.startTrimScrubber addTarget:self action:@selector(endScrubbing:)forControlEvents:UIControlEventTouchDragExit];
//    
//    [self.endTrimScrubber addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventTouchDragInside];
//    [self.endTrimScrubber addTarget:self action:@selector(beginScrubbing:) forControlEvents:UIControlEventTouchDragEnter];
//    [self.endTrimScrubber addTarget:self action:@selector(endScrubbing:)forControlEvents:UIControlEventTouchDragExit];
//    
//    self.startTrimScrubber.frame = CGRectMake(80, self.frame.size.height-75, self.frame.size.width-140, 20);
//    self.endTrimScrubber.frame = CGRectMake(80, self.bounds.size.height-50, self.frame.size.width-140, 20);
//    
//    
//    //[self.view addSubview:self.trimmingControlsView];
//    [self addSubview:self.startTrimScrubber];
//    [self addSubview:self.endTrimScrubber];
//    
//    [UIView animateWithDuration:0.5 animations:^{
//        
//        [self setTransform:CGAffineTransformMakeTranslation(0.f, -100)];
//        //self.trimmingControlsView.frame = CGRectOffset(self.trimmingControlsView.frame, 0, -200);
//        // self.trimmingControlsView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 200);
//        
//    } completion:
//     ^(BOOL finished)
//     {
//         //[self hideBars];
//     }];
//    
//    
//    
//}
//
//- (IBAction)trim:(id)sender
//{
//    [self.trimmingControlsView setHidden:NO];
//    self.trimmingVideo = YES;
//    [self disableScrubber];
//    [self enableTrimmingSliders];
//    [self initializeTrimmingControls];
//    self.doneTrimmingButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(finishTrimmingVideo:)];
//    self.navigationItem.rightBarButtonItem = self.doneTrimmingButton;
//    [self.doneTrimmingButton setEnabled:YES];
//    
//    // if this button gets pressed, whatever position the slider is in will correspond to the time in which the video should be cut out when a done button is pressed. set this time to the new time range of the take that is being played.
//    
//    // if slider gets moved to a new position then the done button gets pressed, that value will be the new start time value
//    
//    
//}
//
//- (IBAction)finishTrimmingVideo:(id)sender
//{
//    // the done button was pressed. get the last time represented by the slider
//    self.trimmingVideo = NO;
//    //self.trimmingControlsView.frame = self.view.frame.size.height;
//    
//    
//    [self hideTrimmingControls];
//    [self enableScrubber];
//    [self disableTrimmingSliders];
//    
//    // now must set the last recorded start and end times represented by the trimming controls to the takes' new time range
//    
//    
//    
//    //    self.trimmingControlsView = nil;
//    //    [self.trimmingControlsView removeFromSuperview];
//    
//    
//    // now must set the last recorded start and end times represented by the trimming controls to the takes' new time range
//    
//    self.takeToPlay.timeRange = CMTimeRangeFromTimeToTime(self.trimmedTime_initial, self.trimmedTime_final);
//    //CMTime newDuration = CMTimeMake(self.takeToPlay.timeRange.duration, NSEC_PER_MSEC);
//    
//    //self.takeToPlay.duration = self.takeToPlay.timeRange.duration;
//    //AVAsset *asset = [AVURLAsset URLAssetWithURL:[self.takeToPlay getFileURL] options:nil];
//    self.videoMerger = [[VideoMerger alloc] init];
//    [self.videoMerger exportTrimmedTake:self.takeToPlay];
//    
//    ///NSLog(@"new duration: %d", self.takeToPlay.timeRange.duration);
//    
//    
//}
//
//
//
///*
//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}
//*/
//
//@end
