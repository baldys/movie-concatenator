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

IB_DESIGNABLE
@interface TimeRangeSlider : UIControl
{
    LimitedSlider *_slider;
    BOOL _flipSlider;
    
    //id <TimeRangeSliderDelegate> _delegate;
    
    float _duration;
    CGFloat _sliderXinset;
    
    BOOL _maxThumbOn;
    BOOL _minThumbOn;
    
    float _padding;
  

    
}




- (id) initWithFrame:(CGRect)frame;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) LimitedSlider *slider;
@property (nonatomic) BOOL flipSlider;
@property (nonatomic) CGFloat sliderXInset;
@property (nonatomic, weak) id <TimeRangeSliderDelegate> delegate;

@property (nonatomic) float duration;
@property (nonatomic) float minimumTime;
@property (nonatomic) float maximumTime;

@property (nonatomic) float timeValue;
@property (nonatomic) float initialTimeValue;
@property (nonatomic) float finalTimeValue;

@property(nonatomic) float minimumValue;
@property(nonatomic) float maximumValue;
@property(nonatomic) float minimumRange;
@property(nonatomic) float selectedMinimumValue;
@property(nonatomic) float selectedMaximumValue;


@property (nonatomic, strong) IBInspectable UIImageView * minThumb;
@property (nonatomic, strong) IBInspectable UIImageView * maxThumb;
@property (nonatomic, strong) IBInspectable UIImageView * track;
@property (nonatomic, strong) IBInspectable UIImageView * trackBackground;
@end

@protocol TimeRangeSliderDelegate <NSObject>
@required
- (void)sliderTimeValueDidChange:(TimeRangeSlider*)slider;

@end

