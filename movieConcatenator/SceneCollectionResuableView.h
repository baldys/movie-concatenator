//
//  SceneCollectionResuableView.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-02.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Scene.h"

@class Scene;

@interface SceneCollectionResuableView : UICollectionReusableView

@property (nonatomic, strong) Scene *scene;

@property (strong, nonatomic) IBOutlet UILabel *sceneTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *addTake;


@end
