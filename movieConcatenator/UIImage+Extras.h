//
//  UIImage+Extras.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-31.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extras)

- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size;
@end
