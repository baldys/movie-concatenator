//
//  TTRangeSliderDelegate.h
//  DemoReel
//
//  Created by Veronica Baldys on 2015-06-03.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TTRangeSlider;

@protocol TTRangeSliderDelegate <NSObject>

-(void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum;

@end