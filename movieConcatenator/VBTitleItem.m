//
//  VBTitleItem.m
//  DemoReel
//
//  Created by Veronica Baldys on 2015-06-28.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//
#define VIDEO_RECT_1080p CGRectMake(0,0,1920,1080)
#define VIDEO_RECT_720p CGRectMake(0,0,1280,720)

#import "VBTitleItem.h"
#import <UIKit/UIKit.h>


@interface VBTitleItem()

@property (copy, nonatomic) NSString *text;
@property (nonatomic) CGRect bounds;

@end

@implementation VBTitleItem

+ (instancetype)titleItemWithText:(NSString *)text
{
    return [[self alloc] initWithText:text];
}

- (instancetype)initWithText:(NSString *)text
{
    self = [super init];
    if (self) {
        _text = [text copy];
        _bounds = VIDEO_RECT_720p;
        
    }
    return self;
}

- (CALayer *)buildLayer {
    
    // --- Build Layers
    
    CALayer *parentLayer = [CALayer layer];                                 // 2
    parentLayer.frame = self.bounds;
    parentLayer.opacity = 0.0f;
  
    CALayer *textLayer = [self makeTextLayer];
    [parentLayer addSublayer:textLayer];
    
    
    // --- Build and Attach Animations
    
    CAAnimation *fadeInFadeOutAnimation = [self makeFadeInFadeOutAnimation];
    [parentLayer addAnimation:fadeInFadeOutAnimation forKey:nil];           // 1
    
    return parentLayer;
}

- (CALayer *)makeTextLayer {
    
    CGFloat fontSize = self.useLargeFont ? 64.0f : 54.0f;
    UIFont *font = [UIFont fontWithName:@"GillSans-Bold" size:fontSize];
    
    NSDictionary *attrs =
    @{NSFontAttributeName:font, NSForegroundColorAttributeName:(id)[UIColor whiteColor].CGColor};
    
    NSAttributedString *string =
    [[NSAttributedString alloc] initWithString:self.text attributes:attrs];
    
    CGSize textSize = [self.text sizeWithAttributes:attrs];
    
    CATextLayer *layer = [CATextLayer layer];
    layer.string = string;
    layer.bounds = CGRectMake(0.0f, 0.0f, textSize.width, textSize.height);
    layer.position = CGPointMake(CGRectGetMidX(self.bounds), 470.0f);
    layer.backgroundColor = [UIColor clearColor].CGColor;

    return layer;
}

- (CAAnimation *)makeFadeInFadeOutAnimation
{
    
    CAKeyframeAnimation *animation =
    [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    
    animation.values = @[@0.0f, @1.0, @1.0f, @0.0f];
    animation.keyTimes = @[@0.0f, @0.25f, @0.75f, @1.0f];
    
    //animation.beginTime = CMTimeGetSeconds(timeRange.start);
    
    //animation.duration = CMTimeGetSeconds(timeRange.duration);
    
    animation.removedOnCompletion = NO;
    
    return animation;
}

// each sublayer will have a corresponding animation
// each sublayer has different text and different animation times?







@end
