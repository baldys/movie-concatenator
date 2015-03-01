//
//  VideoController.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-24.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Take.h"
@interface VideoController : NSObject

// TODO make singleton

+ (VideoController*) sharedVideoManager;




//make asset from a bunch of RON Videos (NSArray of RON Videos) -> (AVAsset)

//list all relevant RON Videos

//  selected?

//  in order of filming/takes/sections
//append to list of RON Videos (RON Video) -> ()

//// addMediaItemToList:(MediaItem*)mediaItem

//later maybe delete a RON Video (RON Video) -> ()

//splice(NSArray of RON Videos) -> (AVAsset)  //OR completion block


//  leave room for CMTime for each RON Video to be edited.

// export(NSArray of RON Videos) -> (nsurl) //OR completion block

// we need a delegate for asynchronous operations

// TODO: make a separate view class with AVPlayerLayer.

// AVAsset -> (RON VideoPlayerView)

@end
