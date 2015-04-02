//
//  AddSceneViewController.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-31.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Scene.h"
@class Scene;
@interface AddSceneViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) Scene *sceneData;



@end
