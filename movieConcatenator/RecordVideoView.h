//
//  RecordVideoView.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-20.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AVCaptureSession;
@interface RecordVideoView : UIView
@property (nonatomic) AVCaptureSession *session;
@end
