//
//  CompositionsViewController.h
//  DemoReel
//
//  Created by Veronica Baldys on 2015-06-23.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompositionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *videoCompositions;

@end
