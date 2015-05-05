//
//  BestTakesViewController.h
//  DemoReel
//
//  Created by Veronica Baldys on 2015-05-04.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Take.h"
@class Take;
@interface BestTakesViewController : UIViewController

- (void)addTakeToTakesToConcatenate:(NSNotification*)notification;
@property (nonatomic, strong) NSMutableArray *takesToConcatenate;
- (IBAction)concatenateSelectedTakes:(id)sender;
@end
