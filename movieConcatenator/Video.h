//
//  RONVideo.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-23.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>



@interface Video : NSObject

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) AVAsset  *asset;

@property (nonatomic, strong) NSURL    *assetURL;

@property AVMutableComposition *mutableComposition;
@property AVMutableVideoComposition *mutableVideoComposition;
@property AVMutableAudioMix *mutableAudioMix;
//@property (nonatomic) CMTime *insertionPoint;

//@property (nonatomic, strong) AVMutableVideoComposition *videoComposition;
//@property (nonatomic, strong) AVMutableAudioMix *audioMix;
@property (nonatomic, strong) NSArray *assetTracks;

//TODO: each RON video has a beginning cut in time (CMTime), cut out time (CMTime)
//OR CMTimeRange
//additional feature


- (instancetype) initWithURL:(NSURL *)url;

- (NSArray*)assetTracks;
//TODO: split into two.





@end
