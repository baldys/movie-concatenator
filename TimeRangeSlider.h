//
//  TimeSliderCell.h
//  DemoReel
//
//  Created by Veronica Baldys on 2015-05-16.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimeRangeSliderDelegate;

@class LimitedSlider;

@interface TimeRangeSlider : UIView
{
    LimitedSlider *_slider;
    BOOL _flipSlider;
    
    //id <TimeRangeSliderDelegate> _delegate;
    
    float _duration;
    CGFloat _sliderXinset;
}

- (id) initWithFrame:(CGRect)frame;
@property (nonatomic, strong) LimitedSlider *slider;
@property (nonatomic) BOOL flipSlider;
@property (nonatomic) CGFloat sliderXInset;
@property (nonatomic, weak) id <TimeRangeSliderDelegate> delegate;

@property (nonatomic) float duration;
@property (nonatomic) float minimumTime;
@property (nonatomic) float maximumTime;

@property (nonatomic) float timeValue;

@end

@protocol TimeRangeSliderDelegate <NSObject>
@required
- (void)sliderTimeValueDidChange:(TimeRangeSlider*)slider;

@end

