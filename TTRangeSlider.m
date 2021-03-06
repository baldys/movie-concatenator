//
//  TTRangeSlider.m
//  DemoReel
//
//  Created by Veronica Baldys on 2015-06-03.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

//
//  TTRangeSlider.m
//
//  Created by Tom Thorpe

#import "TTRangeSlider.h"

const int HANDLE_TOUCH_AREA_EXPANSION = -30; //expand the touch area of the handle by this much (negative values increase size) so that you don't have to touch right on the handle to activate it.
const float HANDLE_DIAMETER = 16;

@interface TTRangeSlider ()

@property (nonatomic, strong) CALayer *sliderLine;

@property (nonatomic, strong) CALayer *leftHandle;
@property (nonatomic, assign) BOOL leftHandleSelected;
@property (nonatomic, strong) CALayer *rightHandle;
@property (nonatomic, assign) BOOL rightHandleSelected;

@property (nonatomic, strong) CATextLayer *minLabel;
@property (nonatomic, strong) CATextLayer *maxLabel;

@property (nonatomic, strong) NSNumberFormatter *decimalNumberFormatter; // Used to format values if formatType is YLRangeSliderFormatTypeDecimal

@property (nonatomic) double adjustedDuration;

@end

static const CGFloat kLabelsFontSize = 12.0f;


@implementation TTRangeSlider

// indicates which value was last edited - minimum value or maximum value.
- (BOOL) lastValueChangedWasMinimumValue
{
    if (self.leftHandleSelected)
    {
        return YES;
    }
    return NO;
}
//do all the setup in a common place, as there can be two initialisers called depending on if storyboards or code are used. The designated initialiser isn't always called :|
- (void)initialiseControl {
    //defaults:
    _minValue = 0.0f;
    _selectedMinimum = 0.0f;
    _maxValue = 1.0f;
    _selectedMaximum  = _maxValue;
    
    NSLog(@"DURATION: %f", _duration );
    NSLog(@"##### %f,",[self maxSelectedTimeValue]);
    
    
    // create duration label.
    /////////
    CGFloat barSidePadding = 16.0f;
    CGRect currentFrame = self.frame;
    float yMiddle = currentFrame.size.height/2.0;
    if (!self.durationLabel)
    {
        self.durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, yMiddle, barSidePadding*3, 8.0)];
        self.durationLabel.textColor = [UIColor whiteColor];
        self.durationLabel.font = [UIFont systemFontOfSize:12.0f];
        
    }
    //////////
    
    
    
    [self addSubview:self.durationLabel];
    //draw the slider line
    self.sliderLine = [CALayer layer];
    self.sliderLine.backgroundColor = self.tintColor.CGColor;
    [self.layer addSublayer:self.sliderLine];
    
    //draw the minimum slider handle
    self.leftHandle = [CALayer layer];
    self.leftHandle.cornerRadius = 8.0f;
    self.leftHandle.backgroundColor = self.tintColor.CGColor;
    [self.layer addSublayer:self.leftHandle];
    
    //draw the maximum slider handle
    self.rightHandle = [CALayer layer];
    self.rightHandle.cornerRadius = 8.0f;
    self.rightHandle.backgroundColor = self.tintColor.CGColor;
    [self.layer addSublayer:self.rightHandle];
    
    self.leftHandle.frame = CGRectMake(0, 0, HANDLE_DIAMETER, HANDLE_DIAMETER);
    self.rightHandle.frame = CGRectMake(0, 0, HANDLE_DIAMETER, HANDLE_DIAMETER);
    
    //draw the text labels
    self.minLabel = [[CATextLayer alloc] init];
    self.minLabel.alignmentMode = kCAAlignmentCenter;
    self.minLabel.fontSize = kLabelsFontSize;
    self.minLabel.frame = CGRectMake(0, 0, 75, 14);
    self.minLabel.contentsScale = [UIScreen mainScreen].scale;
    if (self.minLabelColour == nil){
        self.minLabel.foregroundColor = self.tintColor.CGColor;
    } else {
        self.minLabel.foregroundColor = self.minLabelColour.CGColor;
    }
    [self.layer addSublayer:self.minLabel];
    
    self.maxLabel = [[CATextLayer alloc] init];
    self.maxLabel.alignmentMode = kCAAlignmentCenter;
    self.maxLabel.fontSize = kLabelsFontSize;
    self.maxLabel.frame = CGRectMake(0, 0, 75, 14);
    self.maxLabel.contentsScale = [UIScreen mainScreen].scale;
    if (self.maxLabelColour == nil){
        self.maxLabel.foregroundColor = self.tintColor.CGColor;
    } else {
        self.maxLabel.foregroundColor = self.maxLabelColour.CGColor;
    }
    [self.layer addSublayer:self.maxLabel];
    
   
    
    [self refresh];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //positioning for the slider line
    float barSidePadding = 16.0f;
    CGRect currentFrame = self.frame;
    float yMiddle = currentFrame.size.height/2.0;
    

    CGPoint lineLeftSide = CGPointMake(barSidePadding*3, yMiddle);
    CGPoint lineRightSide = CGPointMake(currentFrame.size.width-barSidePadding, yMiddle);
    self.sliderLine.frame = CGRectMake(lineLeftSide.x, lineLeftSide.y, lineRightSide.x-lineLeftSide.x, 1);
    
    [self updateHandlePositions];
    [self updateLabelPositions];
}

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    
    if(self)
    {
        //[self initialiseControl];
    }
    return self;
}

//-  (id)initWithFrame:(CGRect)frame
//{
//    
////    self = [super initWithFrame:frame];
////    if (self)
////    {
////        [self initialiseControl];
////    }
//    //return self;
//    
//    return [self initWithDuration:[NSNull null]];
//
//}

- (instancetype) initWithDuration:(Float64)duration
{
    if (self == [super initWithFrame:CGRectZero])
    {
        _duration = duration;
        [self initialiseControl];
    }
    return self;
}

- (float)getPercentageAlongLineForValue:(float)currentValue {
    if (self.minValue == self.maxValue){
        return 0; //stops divide by zero errors where maxMinDif would be zero. If the min and max are the same the percentage has no point.
    }
    
    //get the difference between the maximum and minimum values (e.g if max was 100, and min was 50, difference is 50)
    float maxMinDif = self.maxValue - self.minValue;
    
    //now subtract value from the minValue (e.g if value is 75, then 75-50 = 25)
    float valueSubtracted = currentValue - self.minValue;
    
    //now divide valueSubtracted by maxMinDif to get the percentage (e.g 25/50 = 0.5)
    return valueSubtracted / maxMinDif;
}

- (float)getXPositionAlongLineForValue:(float) value {
    //first get the percentage along the line for the value
    float percentage = [self getPercentageAlongLineForValue:value];
    
    //get the difference between the maximum and minimum coordinate position x values (e.g if max was x = 310, and min was x=10, difference is 300)
    float maxMinDif = CGRectGetMaxX(self.sliderLine.frame) - CGRectGetMinX(self.sliderLine.frame);
    
    //now multiply the percentage by the minMaxDif to see how far along the line the point should be, and add it onto the minimum x position.
    float offset = percentage * maxMinDif;
    
    return CGRectGetMinX(self.sliderLine.frame) + offset;
}

- (NSString*)timeLabel:(double)timeValue
{
    int minutes = 0;
    double seconds = 0;
    NSLog(@"time value: %f", timeValue);
    while (timeValue >= 60.0)
    {
        minutes++;
        timeValue = timeValue-60;
        NSLog(@"mins counted: %f", timeValue);
        
    }
    
    seconds = timeValue;
    NSLog(@"seconds: %f", seconds);
    NSString *timeString = [NSString stringWithFormat:@"%i:%.2f", minutes, seconds];
    return timeString;
}

- (void)updateLabelValues {
    if ([self.numberFormatterOverride isEqual:[NSNull null]]){
        self.minLabel.string = @"";
        self.maxLabel.string = @"";
        return;
    }
    
    //NSNumberFormatter *formatter = (self.numberFormatterOverride != nil) ? self.numberFormatterOverride : self.decimalNumberFormatter;
    
    NSLog(@"duration: %f", self.duration);
    double updatedDuration = [self maxSelectedTimeValue] - [self minSelectedTimeValue];
    NSLog(@"updated duration: %f", updatedDuration);
    
    //self.minLabel.string = [formatter stringFromNumber:@([self minSelectedTimeValue])];
    //self.maxLabel.string = [formatter stringFromNumber:@([self maxSelectedTimeValue])];
    
    self.minLabel.string = [self timeLabel:[self minSelectedTimeValue]];
    self.maxLabel.string = [self timeLabel:[self maxSelectedTimeValue]];
    self.durationLabel.text = [self timeLabel:updatedDuration];
    
}

#pragma mark - Set Positions
- (void)updateHandlePositions {
    CGPoint leftHandleCenter = CGPointMake([self getXPositionAlongLineForValue:self.selectedMinimum], CGRectGetMidY(self.sliderLine.frame));
    self.leftHandle.position = leftHandleCenter;
    
    CGPoint rightHandleCenter = CGPointMake([self getXPositionAlongLineForValue:self.selectedMaximum], CGRectGetMidY(self.sliderLine.frame));
    self.rightHandle.position= rightHandleCenter;
}

- (void)updateLabelPositions {
    //the centre points for the labels are X = the same x position as the relevant handle. Y = the y position of the handle minus half the height of the text label, minus some padding.
    int padding = 8;
    float minSpacingBetweenLabels = 8.0f;
    
    CGPoint leftHandleCentre = [self getCentreOfRect:self.leftHandle.frame];
    CGPoint newMinLabelCenter = CGPointMake(leftHandleCentre.x, self.leftHandle.frame.origin.y - (self.minLabel.frame.size.height/2) - padding);
    
    CGPoint rightHandleCentre = [self getCentreOfRect:self.rightHandle.frame];
    CGPoint newMaxLabelCenter = CGPointMake(rightHandleCentre.x, self.rightHandle.frame.origin.y - (self.maxLabel.frame.size.height/2) - padding);
    
    CGSize minLabelTextSize = [self.minLabel.string sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kLabelsFontSize]}];
    CGSize maxLabelTextSize = [self.maxLabel.string sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kLabelsFontSize]}];
    
    float newLeftMostXInMaxLabel = newMaxLabelCenter.x - maxLabelTextSize.width/2;
    float newRightMostXInMinLabel = newMinLabelCenter.x + minLabelTextSize.width/2;
    float newSpacingBetweenTextLabels = newLeftMostXInMaxLabel - newRightMostXInMinLabel;
    
    if (newSpacingBetweenTextLabels > minSpacingBetweenLabels) {
        self.minLabel.position = newMinLabelCenter;
        self.maxLabel.position = newMaxLabelCenter;
    }
    else {
        newMinLabelCenter = CGPointMake(self.minLabel.position.x, self.leftHandle.frame.origin.y - (self.minLabel.frame.size.height/2) - padding);
        newMaxLabelCenter = CGPointMake(self.maxLabel.position.x, self.rightHandle.frame.origin.y - (self.maxLabel.frame.size.height/2) - padding);
        self.minLabel.position = newMinLabelCenter;
        self.maxLabel.position = newMaxLabelCenter;
        
        //Update x if they are still in the original position
        if (self.minLabel.position.x == self.maxLabel.position.x && self.leftHandle != nil) {
            self.minLabel.position = CGPointMake(leftHandleCentre.x, self.minLabel.position.y);
            self.maxLabel.position = CGPointMake(leftHandleCentre.x + self.minLabel.frame.size.width/2 + minSpacingBetweenLabels + self.maxLabel.frame.size.width/2, self.maxLabel.position.y);
        }
    }
}

#pragma mark - Touch Tracking


- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint gesturePressLocation = [touch locationInView:self];
    
    if (CGRectContainsPoint(CGRectInset(self.leftHandle.frame, HANDLE_TOUCH_AREA_EXPANSION, HANDLE_TOUCH_AREA_EXPANSION), gesturePressLocation) || CGRectContainsPoint(CGRectInset(self.rightHandle.frame, HANDLE_TOUCH_AREA_EXPANSION, HANDLE_TOUCH_AREA_EXPANSION), gesturePressLocation))
    {
        //the touch was inside one of the handles so we're definitely going to start movign one of them. But the handles might be quite close to each other, so now we need to find out which handle the touch was closest too, and activate that one.
        float distanceFromLeftHandle = [self distanceBetweenPoint:gesturePressLocation andPoint:[self getCentreOfRect:self.leftHandle.frame]];
        float distanceFromRightHandle =[self distanceBetweenPoint:gesturePressLocation andPoint:[self getCentreOfRect:self.rightHandle.frame]];
        
        if (distanceFromLeftHandle < distanceFromRightHandle && self.disableRange == NO){
            self.leftHandleSelected = YES;
            [self animateHandle:self.leftHandle withSelection:YES];
        } else {
            if (self.selectedMaximum == self.maxValue && [self getCentreOfRect:self.leftHandle.frame].x == [self getCentreOfRect:self.rightHandle.frame].x) {
                self.leftHandleSelected = YES;
                [self animateHandle:self.leftHandle withSelection:YES];
            }
            else {
                self.rightHandleSelected = YES;
                [self animateHandle:self.rightHandle withSelection:YES];
            }
        }
        
        return YES;
    } else {
        return NO;
    }
}

- (void)refresh {
    //ensure the minimum and maximum selected values are within range. Access the values directly so we don't cause this refresh method to be called again (otherwise changing the properties causes a refresh)
    if (self.selectedMinimum < self.minValue){
        _selectedMinimum = self.minValue;
    }
    if (self.selectedMaximum > self.maxValue){
        _selectedMaximum = self.maxValue;
    }
    
   
    
    //update the frames in a transaction so that the tracking doesn't continue until the frame has moved.
    [CATransaction begin];
    [CATransaction setDisableActions:YES] ;
    [self updateHandlePositions];
    [self updateLabelPositions];
    [CATransaction commit];
    [self updateLabelValues];
    
    //update the delegate
    if (self.delegate){
        [self.delegate rangeSlider:self didChangeSelectedMinimumValue:self.selectedMinimum andMaximumValue:self.selectedMaximum];
    }
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint location = [touch locationInView:self];
    
    //find out the percentage along the line we are in x coordinate terms (subtracting half the frames width to account for moving the middle of the handle, not the left hand side)
    float percentage = ((location.x-CGRectGetMinX(self.sliderLine.frame)) - HANDLE_DIAMETER/2) / (CGRectGetMaxX(self.sliderLine.frame) - CGRectGetMinX(self.sliderLine.frame));
    
    //multiply that percentage by self.maxValue to get the new selected minimum value
    float selectedValue = percentage * (self.maxValue - self.minValue) + self.minValue;
    
    if (self.leftHandleSelected)
    {
        if (selectedValue < self.selectedMaximum){
            self.selectedMinimum = selectedValue;
            [self setSelectedMinimum:selectedValue];
        }
        else {
            self.selectedMinimum = self.selectedMaximum;
        }
        
    }
    else if (self.rightHandleSelected)
    {
        if (selectedValue > self.selectedMinimum || (self.disableRange && selectedValue >= self.minValue)){ //don't let the dots cross over, (unless range is disabled, in which case just dont let the dot fall off the end of the screen)
            
            
            
            self.selectedMaximum = selectedValue;
            [self setSelectedMaximum:selectedValue];
        }
        else {
            self.selectedMaximum = self.selectedMinimum;
        }
    }
    
    //no need to refresh the view because it is done as a sideeffect of setting the property
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (self.leftHandleSelected){
        self.leftHandleSelected = NO;
        [self animateHandle:self.leftHandle withSelection:NO];
    } else {
        self.rightHandleSelected = NO;
        [self animateHandle:self.rightHandle withSelection:NO];
    }
}

#pragma mark - Animation
- (void)animateHandle:(CALayer*)handle withSelection:(BOOL)selected {
    if (selected){
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.3];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut] ];
        handle.transform = CATransform3DMakeScale(1.7, 1.7, 1);
        
        //the label above the handle will need to move too if the handle changes size
        [self updateLabelPositions];
        
        [CATransaction setCompletionBlock:^{
        }];
        [CATransaction commit];
        
    } else {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.3];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut] ];
        handle.transform = CATransform3DIdentity;
        
        //the label above the handle will need to move too if the handle changes size
        [self updateLabelPositions];
        
        [CATransaction commit];
    }
}

#pragma mark - Calculating nearest handle to point
- (float)distanceBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2
{
    CGFloat xDist = (point2.x - point1.x);
    CGFloat yDist = (point2.y - point1.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
}

- (CGPoint)getCentreOfRect:(CGRect)rect
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}


#pragma mark - Properties
-(void)setTintColor:(UIColor *)tintColor{
    [super setTintColor:tintColor];
    
    struct CGColor *color = self.tintColor.CGColor;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.5];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut] ];
    self.sliderLine.backgroundColor = color;
    self.leftHandle.backgroundColor = color;
    self.rightHandle.backgroundColor = color;
    
    if (self.minLabelColour == nil){
        self.minLabel.foregroundColor = color;
    }
    if (self.maxLabelColour == nil){
        self.maxLabel.foregroundColor = color;
    }
    [CATransaction commit];
}

- (void)setDisableRange:(BOOL)disableRange {
    _disableRange = disableRange;
    if (_disableRange){
        self.leftHandle.hidden = YES;
        self.minLabel.hidden = YES;
    } else {
        self.leftHandle.hidden = NO;
    }
}

- (NSNumberFormatter *)decimalNumberFormatter {
    if (!_decimalNumberFormatter){
        _decimalNumberFormatter = [[NSNumberFormatter alloc] init];
        _decimalNumberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        _decimalNumberFormatter.maximumFractionDigits = 2;
    }
    return _decimalNumberFormatter;
}

- (void)setMinValue:(float)minValue {
    _minValue = minValue;
    [self refresh];
}

- (void)setMaxValue:(float)maxValue {
    _maxValue = maxValue;
    [self refresh];
}

- (void)setSelectedMinimum:(float)selectedMinimum {
    if (selectedMinimum < self.minValue){
        selectedMinimum = self.minValue;
    }
    
    _selectedMinimum = selectedMinimum;
    [self refresh];
}

- (void)setSelectedMaximum:(float)selectedMaximum {
    if (selectedMaximum > self.maxValue){
        selectedMaximum = self.maxValue;
    }
    
    _selectedMaximum = selectedMaximum;
    [self refresh];
}

-(void)setMinLabelColour:(UIColor *)minLabelColour{
    _minLabelColour = minLabelColour;
    self.minLabel.foregroundColor = _minLabelColour.CGColor;
}

-(void)setMaxLabelColour:(UIColor *)maxLabelColour{
    _maxLabelColour = maxLabelColour;
    self.maxLabel.foregroundColor = _maxLabelColour.CGColor;
}

-(void)setNumberFormatterOverride:(NSNumberFormatter *)numberFormatterOverride{
    _numberFormatterOverride = numberFormatterOverride;
    [self updateLabelValues];
}

- (void) sliderValueDidChange
{
    if (_delegate)
    {
        [_delegate rangeSlider:self didChangeSelectedMinimumValue:_minValue andMaximumValue:_maxValue];
    }
    
}

- (void)updateTimeLabel
{

    if (!self.minTimeLabel)
    {
        self.minTimeLabel = [[UILabel alloc] init];
    }
    if (!self.maxTimeLabel)
    {
        self.maxTimeLabel = [[UILabel alloc] init];
    }

    self.minTimeLabel.text = [self timeLabel:[self minSelectedTimeValue]];
    self.maxTimeLabel.text = [self timeLabel:[self maxSelectedTimeValue]];
    
    // Float64 maxTimeInSeconds = self.minimumSelectedTime;
    // Float64 minTimeInSeconds = self.maximumSelectedTime;
//    if (minTimeInSeconds < 60.0)
//    {
//        //self.minTimeLabel.text = [NSString stringWithFormat:@"%.1fs", self.minimumSelectedTime];
//
//        self.minTimeLabel.text = [NSString stringWithFormat:@"%.1fs", [self minSelectedTimeValue]];
//        
//  
//    }
//    else {
//        self.minTimeLabel.text = [NSString stringWithFormat:@"%.1fm", minTimeInSeconds/60.0];
//       
//    }
//    
//    if (maxTimeInSeconds < 60.0)
//    {
//        //self.maxTimeLabel.text = [NSString stringWithFormat:@"%.1fs", self.maximumSelectedTime];
//        self.maxTimeLabel.text = [NSString stringWithFormat:@"%.1fs", [self maxSelectedTimeValue]];
//    }
//    else{
//        self.maxTimeLabel.text = [NSString stringWithFormat:@"%.1fs", maxTimeInSeconds/60.0];
//        
//    }
}


//- (void)setDuration:(float)duration
//{
//        duration = duration;
////        [self updateTimeLabel];
////    
////}
// get the upper time value from the upper (right) handles' current value.
- (Float64)maxSelectedTimeValue
{
    NSLog(@"MAXIMUM TIME VALUE: %.2f:", self.duration*self.selectedMaximum);
    return self.duration*self.selectedMaximum;
}
// get the lower time value from the lower (left) handles' current value.
- (Float64)minSelectedTimeValue
{
    NSLog(@"MINIMUM TIME VALUE: %.2f:", self.duration*self.selectedMinimum);
    return self.duration*self.selectedMinimum;
}


- (Float64)timeFromSelectedValue:(float)selectedValue
{
    if(!_duration)
    {
        NSLog(@"duration not set");
        return 0;
    }
    NSLog(@"FLOAT VALUE IN SECONDS: %.02f",(Float64)selectedValue*_duration);
    return (Float64)selectedValue*_duration;
}



//- (void)setMinTimeValueFromSelectedValue:(float)minSelected
//{
//    if (_duration > 0.0)
//    {
//        
//    }
//    self.selectedMinimum = minSelected/self.duration;
//    [self updateTimeLabel];
//}

//- (void)setMaxTimeValueFromSelectedValue:(float)maxSelected;
//{
//    float maxSelectedValue = maxSelected/self.duration;
//  
//    self.selectedMaximum = maxSelectedValue;
//    [self updateTimeLabel];
//}

//- (float)minimumTime
//{
//    float minValue;
//
//    minValue = [self.slider smallestValue];
//    return minValue*_duration;
//}

//- (void)setMinimumTime:(float)minTime
//{
//    float normalizedMinTime = minTime/_duration;
//    if (_flipSlider) {
//        normalizedMinTime = 1.0 - normalizedMinTime;
//        [self.slider setLargestValue:normalizedMinTime];
//    }
//    else {
//        [self.slider setSmallestValue:normalizedMinTime];
//    }
//    [self updateTimeLabel];
//}
//
//- (float)maximumTime
//{
//    float maxValue = [self.slider largestValue];
//    if (_flipSlider) {
//        maxValue = 1.0 - maxValue;
//    }
//    
//    return maxValue*_duration;
//}
//
//- (void)setMaximumTime:(float)maxTime
//{
//    float normalizedMaxTime = maxTime/_duration;
//    if (_flipSlider) {
//        normalizedMaxTime = 1.0 - normalizedMaxTime;
//        [self.slider setSmallestValue:normalizedMaxTime];
//    }
//    else {
//        [self.slider setLargestValue:normalizedMaxTime];
//    }
//    [self updateTimeLabel];
//}

@end