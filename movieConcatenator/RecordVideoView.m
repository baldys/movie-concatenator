//
//  RecordVideoView.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-20.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "RecordVideoView.h"
#import <AVFoundation/AVFoundation.h>

@implementation RecordVideoView


+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session
{
    return [(AVCaptureVideoPreviewLayer *)[self layer] session];
}

- (void)setSession:(AVCaptureSession *)session
{
    [(AVCaptureVideoPreviewLayer *)[self layer] setSession:session];
}


@end
