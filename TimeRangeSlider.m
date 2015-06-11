//
//  TimeSliderCell.m
//  DemoReel
//
//  Created by Veronica Baldys on 2015-05-16.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "TimeRangeSlider.h"



@interface LimitedSlider : UISlider
{
    float _largestValue;
    float _smallestValue;
}


// The largest and smallest values the slider knob is limited to.
@property (nonatomic) float smallestValue;
@property (nonatomic) float largestValue;


@end




@implementation LimitedSlider

- (void) sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    //[self addTarget:target action:action forControlEvents:];
}

- (id)initWithFrame:(CGRect)frame
{
    _smallestValue = 0.0;
    _largestValue = 1.0;
    
    // Set the initial state
    
    self = [super initWithFrame:frame];
    return self;
}
//init with duration
// _duration = duration
//
- (float)smallestValue
{
    return _smallestValue;
}

- (void)setSmallestValue:(float)minValue
{
    _smallestValue = minValue;
    if (self.value < _smallestValue) {
        self.value = _smallestValue;
    }
}

- (float)largestValue
{
    return _largestValue;
}

- (void)setLargestValue:(float)maxValue
{
    _largestValue = maxValue;
    if (self.value > maxValue) {
        self.value = maxValue;
    }
}

- (void)setValue:(float)value
{
    if ((value > _largestValue)) {
        [super setValue:_largestValue];
    }
    else if (value < _smallestValue) {
        [super setValue:_smallestValue];
    }
    else {
        [super setValue:value];
    }
}

- (void)setValue:(float)value animated:(BOOL)animated
{
    if ((value > _largestValue)) {
        [super setValue:_largestValue animated:animated];
    }
    else if (value < _smallestValue) {
        [super setValue:_smallestValue animated:animated];
    }
    else {
        [super setValue:value animated:animated];
    }
}

@end


@interface TimeRangeSlider ()


@property (nonatomic, strong) UILabel *timeLabel;
-(float)xForValue:(float)value;

@end


IB_DESIGNABLE
@implementation TimeRangeSlider

//@synthesize slider = _slider;
//@synthesize sliderXInset = _sliderXInset;
//@synthesize delegate = _delegate;

#pragma mark -
#pragma mark Initialization

- (id)initWithFrame:(CGRect)frame
{
     if (self = [super initWithFrame:frame])
     {
         _minThumbOn = false;
         _maxThumbOn = false;
         _padding = 20;
         
         self.minimumValue = 1;
         self.selectedMinimumValue = 2;
         self.maximumValue = 10;
         self.selectedMinimumValue = 8;
         self.minimumRange = 2;
         
         _trackBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar-background.png"]];
         //_trackBackground.frame = CGRectMake((frame.size.width - _trackBackground.frame.size.width) / 2, (frame.size.height - _trackBackground.frame.size.height) / 2, _trackBackground.frame.size.width, _trackBackground.frame.size.height);
         
         //_trackBackground.frame = CGRectMake(80, frame.size.height-75, frame.size.width-140, 20);
         _trackBackground.frame = frame;
         _trackBackground.backgroundColor = [UIColor redColor];
         [self addSubview:_trackBackground];
         
         _track = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar-highlight.png"]];
         // _track.frame = CGRectMake((frame.size.width - _trackBackground.frame.size.width) / 2, (frame.size.height - _track.frame.size.height) / 2, _track.frame.size.width, _track.frame.size.height);
         _track.frame = frame;
         [self addSubview:_track];
         //[self bringSubviewToFront:_trackBackground];
         //[self bringSubviewToFront:_track];
         
         
         _minThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"handle.png"] highlightedImage:[UIImage imageNamed:@"handle-hover.png"]];
         _minThumb.center = CGPointMake([self xForValue:self.selectedMinimumValue], frame.size.height / 2);
         [self addSubview:_minThumb];
         
         _maxThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"handle.png"] highlightedImage:[UIImage imageNamed:@"handle-hover.png"]];
         _maxThumb.center = CGPointMake([self xForValue:self.selectedMaximumValue], frame.size.height / 2);
         [self addSubview:_maxThumb];
         //[self bringSubviewToFront:_minThumb];
         //[self bringSubviewToFront:_maxThumb];
         
         //self.slider = [[LimitedSlider alloc] initWithFrame:CGRectZero];
         //[self.slider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
         self.sliderXInset = 60.0;
         //[self addSubview:self.slider];
         
         
     }
    
    
    
   
    return self;
}
-(float)xForValue:(float)value
{
    return (_trackBackground.frame.size.width-(_padding*2))*((value -_minimumValue) / (_maximumValue - _minimumValue))+_padding;
}
- (void) initialState
{
    
    
}
//
//- (BOOL)flipSlider
//{
//    return _flipSlider;
//}
//
//- (void)setFlipSlider:(BOOL)flip
//{
//    if (flip != _flipSlider) {
//        _flipSlider = flip;
//        CGAffineTransform transform = flip ? CGAffineTransformMakeScale(-1.0, 1.0) : CGAffineTransformIdentity;
//        self.slider.transform = transform;
//    }
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize contentSize = self.bounds.size;
    CGSize sizeToFitIn = CGRectInset(self.bounds, self.sliderXInset, 0.0).size;
    
    CGRect sliderRect = CGRectZero;
    sliderRect.size = [self.slider sizeThatFits:sizeToFitIn];
    
    sliderRect.origin.x = 0.5*(contentSize.width - sliderRect.size.width);
    sliderRect.origin.x = roundf(sliderRect.origin.x);
    
    sliderRect.origin.y = 0.5*(contentSize.height - sliderRect.size.height);
    sliderRect.origin.y = roundf(sliderRect.origin.y);
    self.slider.frame = sliderRect;
    
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.slider.frame.size.width-40, 20, 40, 20)];
    
}

- (void)updateTimeLabel
{
    float timeInSeconds = [self timeValue];
    
    if (timeInSeconds < 60.0) {
        self.timeLabel.text = [NSString stringWithFormat:@"%.1fs", [self timeValue]];
    }
    else {
        self.timeLabel.text = [NSString stringWithFormat:@"%.1fm", timeInSeconds/60.0];
    }
}

- (void)sliderValueChanged
{
    [self updateTimeLabel];
    if (_delegate) {
        [_delegate sliderTimeValueDidChange:self];
    }
}

- (float)duration
{
    return _duration;
}

//- (void)setDuration:(float)duration
//{
//    if (_duration != duration) {
//        _duration = duration;
//        [self updateTimeLabel];
//    }
//}

- (float)timeValue
{
    float sliderValue = self.slider.value;
    if (_flipSlider) {
        sliderValue = 1.0 - sliderValue;
    }
    return _duration*sliderValue;
}

- (void)setTimeValue:(float)value
{
    float sliderValue = value/_duration;
    if (_flipSlider) {
        sliderValue = 1.0 - sliderValue;
    }
    self.slider.value = sliderValue;
    [self updateTimeLabel];
}

- (float)minimumTime
{
    float minValue;
    if (_flipSlider) {
        minValue = 1.0 - [self.slider largestValue];
    }
    else {
        minValue = [self.slider smallestValue];
    }
    return minValue*_duration;
}

- (void)setMinimumTime:(float)minTime
{
    float normalizedMinTime = minTime/_duration;
    if (_flipSlider) {
        normalizedMinTime = 1.0 - normalizedMinTime;
        [self.slider setLargestValue:normalizedMinTime];
    }
    else {
        [self.slider setSmallestValue:normalizedMinTime];
    }
    [self updateTimeLabel];
}

- (float)maximumTime
{
    float maxValue = [self.slider largestValue];
    if (_flipSlider) {
        maxValue = 1.0 - maxValue;
    }
    
    return maxValue*_duration;
}

- (void)setMaximumTime:(float)maxTime
{
    float normalizedMaxTime = maxTime/_duration;
    if (_flipSlider) {
        normalizedMaxTime = 1.0 - normalizedMaxTime;
        [self.slider setSmallestValue:normalizedMaxTime];
    }
    else {
        [self.slider setLargestValue:normalizedMaxTime];
    }
    [self updateTimeLabel];
}

- (void)dealloc
{
    self.slider = nil;
}

@end

