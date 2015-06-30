//
//  VBTitleItem.h
//  DemoReel
//
//  Created by Veronica Baldys on 2015-06-28.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

@interface VBTitleItem : NSObject


+ (instancetype)titleItemWithText:(NSString *)text;
- (instancetype)initWithText:(NSString *)text;


@property (copy, nonatomic) NSString *identifier;

@property (nonatomic) BOOL useLargeFont;

- (CALayer *)buildLayer;

@end




