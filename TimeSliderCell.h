//
//  TimeSliderCell.h
//  DemoReel
//
//  Created by Veronica Baldys on 2015-05-16.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimeSliderCellDelegate;

@class LimitedSlider;

@interface TimeSliderCell : UITableViewCell
{
    LimitedSlider *_slider;
    BOOL _flipSlider;
    
    //id <TimeSliderCellDelegate> _delegate;
    
    float _duration;
    CGFloat _sliderXinset;
}

- (id)initWithReuseIdentifier:(NSString *)identifier;

@property (nonatomic) BOOL flipSlider;
@property (nonatomic) CGFloat sliderXInset;
@property (nonatomic, weak) id <TimeSliderCellDelegate> delegate;

@property (nonatomic) float duration;
@property (nonatomic) float minimumTime;
@property (nonatomic) float maximumTime;

@property (nonatomic) float timeValue;

@end

@protocol TimeSliderCellDelegate <NSObject>
@required
- (void)sliderCellTimeValueDidChange:(TimeSliderCell*)cell;

@end

