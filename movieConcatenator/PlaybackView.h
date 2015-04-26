//
//  PlaybackView.h
//  DemoReel
//
//  Created by Veronica Baldys on 2015-04-24.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVPlayer;

@interface PlaybackView : UIView

@property (nonatomic, strong) AVPlayer* player;

- (void)setPlayer:(AVPlayer*)player;
- (void)setVideoFillMode:(NSString *)fillMode;

@end
