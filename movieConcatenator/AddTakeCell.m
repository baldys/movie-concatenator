//
//  AddTakeCell.m
//  DemoReel
//
//  Created by Veronica Baldys on 2015-06-29.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "AddTakeCell.h"

@implementation AddTakeCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.layer.borderWidth = 4.0;
    self.layer.cornerRadius = 4.0;
}
@end
