//
//  PlaybackViewController.h
//  DemoReel
//
//  Created by Veronica Baldys on 2015-04-24.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class AVPlayer;
@class PlaybackView;

@interface PlaybackViewController : UIViewController
{
@private
    
    IBOutlet PlaybackView* mPlaybackView;
    
    IBOutlet UISlider* mScrubber;
    IBOutlet UIToolbar *mToolbar;
    IBOutlet UIBarButtonItem *mPlayButton;
    IBOutlet UIBarButtonItem *mStopButton;
    
    float mRestoreAfterScrubbingRate;
    BOOL seekToZeroBeforePlay;
    id mTimeObserver;
    BOOL isSeeking;
    
    NSURL* mURL;
    
    AVPlayer* mPlayer;
    AVPlayerItem * mPlayerItem;
}

@property (nonatomic, copy) NSURL* URL;

@property (readwrite, strong, setter=setPlayer:, getter=player) AVPlayer* mPlayer;

@property (strong) AVPlayerItem* mPlayerItem;

@property (nonatomic, strong) IBOutlet PlaybackView *mPlaybackView;

@property (nonatomic, strong) IBOutlet UIToolbar *mToolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *mPlayButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *mStopButton;
@property (nonatomic, strong) IBOutlet UISlider* mScrubber;
@property (nonatomic, strong) NSArray *playbackItems;
- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)showMetadata:(id)sender;


@end
