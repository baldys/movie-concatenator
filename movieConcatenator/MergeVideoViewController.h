//
//  MergeVideoViewController.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-21.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Take.h"


@interface MergeVideoViewController : UIViewController
{
    BOOL isSelectingAssetOne;
}

@property(nonatomic, strong) AVAsset *firstAsset;
@property(nonatomic, strong) AVAsset *secondAsset;


@property (nonatomic, strong) AVMutableVideoComposition *mainComposition;
//@property (nonatomic, strong) AVMutableVideoCompositionInstruction *videoCompositionInstruction;
// contains layer instructions for each video asset/composirtion
//@property (nonatomic, strong) NSMutableArray *videoCompositionLayerInstructions;
@property (nonatomic,strong) Take *video;

- (IBAction)loadVideo1:(id)sender;

- (IBAction)loadVideo2:(id)sender;

- (IBAction)mergeAndSave:(id)sender;

-(void) exportVideoComposition:(AVMutableComposition*)composition;

-(BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate;

-(void)exportDidFinish:(AVAssetExportSession*)session;


- (AVMutableComposition*) appendAsset:(AVAsset *)asset ToComposition:(AVMutableComposition*)composition;

@end
