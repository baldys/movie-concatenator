//
//  TableViewCell.m
//  DemoReel
//
//  Created by Veronica Baldys on 2015-07-02.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "VBCompositionCell.h"

@implementation VBCompositionCell

- (void)awakeFromNib {
    // Initialization code
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    //UIButton *shareButton = [UIButton buttonWithType:UIBarButtonSystemItemAction];
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showMenu:)];
    
    self.accessoryView = actionButton;
    
    
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
