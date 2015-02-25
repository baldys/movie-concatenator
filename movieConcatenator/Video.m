//
//  RONVideo.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-23.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "Video.h"

@implementation Video

- (instancetype) initWithURL:(NSURL*)url
{
    self = [super init];
    if(self)
    {
        self.asset = nil;
        self.assetURL = url;
        
        
    }
    return self;
}


- (NSArray*) videoaAssetTracks
{
    
    AVAssetTrack *assetVideoTrack = nil;
    AVAssetTrack *assetAudioTrack = nil;
    // Check if the asset contains video and audio tracks
    if ([[self.asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        assetVideoTrack = [self.asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    if ([[self.asset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
        assetAudioTrack = [self.asset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    
    
    NSError *error = nil;
    
   
    //AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *audioAssetTrack = [[self.asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    //[audioAssetTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.firstAsset.duration) ofTrack:firstAssetTrack atTime:kCMTimeZero error:nil];
    AVAssetTrack *videoAssetTrack = [[self.asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
    NSArray *assetTracks = [NSArray arrayWithObjects:audioAssetTrack, videoAssetTrack, nil];
    return assetTracks;
}


- (void) createCompositionWithAudioAndVideoTracks
{
    AVMutableComposition *composition = [AVMutableComposition composition];
}

@end
