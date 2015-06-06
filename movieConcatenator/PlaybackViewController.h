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
#import "TimeRangeSlider.h"
#import "TTRangeSlider.h"

@class AVPlayer;
@class PlaybackView;
@class Take;

@interface PlaybackViewController : UIViewController <TTRangeSliderDelegate>
{
//@private
    
//    IBOutlet PlaybackView* mPlaybackView;
//    
//    UISlider* mScrubber;
//    IBOutlet UIToolbar *mToolbar;
//    UIBarButtonItem *mPlayButton;
//    UIBarButtonItem *mPauseButton;
//    
    float mRestoreAfterScrubbingRate;
    BOOL seekToZeroBeforePlay;
    id mTimeObserver;
    BOOL isSeeking;
//

    //NSURL* mURL;
//    
//    AVPlayer* mPlayer;
//    AVPlayerItem * mPlayerItem;
//}
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

@property (nonatomic) CMTime trimmedTime_initial;
@property (nonatomic) CMTime trimmedTime_final;

- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;
//- (IBAction)showMetadata:(id)sender;

@property (nonatomic, strong) Take *takeToPlay;
@property (nonatomic, strong) TTRangeSlider *slider;
@end
