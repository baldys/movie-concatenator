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



@interface MergeVideoViewController : UIViewController
{
    BOOL isSelectingAssetOne;
}

@property(nonatomic, strong) AVAsset *firstAsset;
@property(nonatomic, strong) AVAsset *secondAsset;
@property(nonatomic, strong) AVAsset *firstAudioAsset;
@property (nonatomic,strong) AVAsset *secondAudioAsset;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
- (IBAction)loadVideo1:(id)sender;

- (IBAction)loadVideo2:(id)sender;

- (IBAction)mergeAndSave:(id)sender;

-(BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate;
-(void)exportDidFinish:(AVAssetExportSession*)session;
@end
