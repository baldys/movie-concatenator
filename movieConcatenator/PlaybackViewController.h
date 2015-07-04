//
//  PlaybackViewController.h
//  DemoReel
//
//  Created by Veronica Baldys on 2015-04-24.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Take.h"
#import "PlaybackView.h"
#import "VideoMerger.h"
#import "TTRangeSlider.h"

@class AVPlayer;
@class PlaybackView;
@class Take;

@interface PlaybackViewController : UIViewController <TTRangeSliderDelegate, UIGestureRecognizerDelegate>
{
    float mRestoreAfterScrubbingRate;
    BOOL seekToZeroBeforePlay;
    id mTimeObserver;
    BOOL isSeeking;

}

//@property (nonatomic, copy) NSURL* URL;

@property (readwrite, strong, setter=setPlayer:, getter=player) AVPlayer* mPlayer;

@property (strong) AVPlayerItem* mPlayerItem;

@property (nonatomic, strong) IBOutlet PlaybackView *mPlaybackView;

@property (nonatomic, strong) IBOutlet UIToolbar *mToolbar;
@property (nonatomic, strong) UIBarButtonItem *mPlayButton;
@property (nonatomic, strong) UIBarButtonItem *mPauseButton;
@property (nonatomic, strong) UISlider* mScrubber;

@property (nonatomic, strong) NSArray *playbackItems;
@property (nonatomic, strong) VideoMerger *videoMerger;

- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;
//- (IBAction)showMetadata:(id)sender;

@property (nonatomic, strong) Take *takeToPlay;
@property (nonatomic, strong) NSMutableArray *takeQueue;
@property (nonatomic) CMTime trimmedTime_initial;
@property (nonatomic) CMTime trimmedTime_final;
@property (nonatomic, strong) TTRangeSlider *slider;

@end

/* 
TO DO:
[x] initial right hand slider value should = the duration
[x] cancel button to get out of trimming mode without saving
[x] UIAction sheet for confirming overwriting the video
 
[x] make the slider value labels in this format mm:ss instead of decimal.
[x] a label for duration that updates as slider values change.
[ ] play pause button for previewing the trimmed version (just use the one in the toolbar while keeping the toolbar showing)

[x] swipe gestures for switching between takes in that scene

*/