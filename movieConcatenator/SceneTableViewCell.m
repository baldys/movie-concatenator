//
//  SceneTableViewCell.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-08.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "SceneTableViewCell.h"
#import "Scene.h"
#import "Take.h"
#import "RecordVideoViewController.h"
#import "VideoLibrary.h"


@interface SceneTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *sceneTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *addTakeButton;
@property (nonatomic, strong) VideoLibrary *library;
@property NSMutableArray *selectedItems;
@end
@implementation SceneTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.collectionView reloadData];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 9, 10);
    layout.itemSize = CGSizeMake(44, 44);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];

   [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellIdentifier];
   self.collectionView.backgroundColor = [UIColor whiteColor];

 
    self.collectionView.showsHorizontalScrollIndicator = YES;
    [self.contentView addSubview:self.collectionView];
//    
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = self.contentView.bounds;
}

- (void) didSelectStarButtonInCell:(TakeCollectionViewCell *)takeCell
{
    if (takeCell.take.isSelected && ![self.selectedItems containsObject:takeCell.take])
    {
        [self.selectedItems addObject:takeCell.take];
        NSLog(@"take is selected but does not contain object");
    }
    //
    else if (!takeCell.take.isSelected && [self.selectedItems containsObject:takeCell.take])
    {
        [self.selectedItems removeObject:takeCell.take];
        NSLog(@"take is DEselected but contains object");
    }
    
    
}


-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index
{
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.tag = index;
    
    [self.collectionView reloadData];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"PREPARE");
    
    UIButton *addTakeButton = (UIButton*)sender;
    NSLog(@"buttontag = %li", (long)addTakeButton.tag);
    
    Scene *currentScene = self.library.scenes[addTakeButton.tag];
    
    
    if ([segue.identifier isEqualToString:@"showRecordVC"])
    {
        
        RecordVideoViewController *recordViewController = segue.destinationViewController;
        
        recordViewController.scene = currentScene;
        __weak __typeof(self) weakSelf = self;
        recordViewController.completionBlock = ^void (BOOL success)
        {
            NSLog(@"completion block called");
            if (success)
            {
                NSLog(@"saving");
                [weakSelf.library saveToFilename:@"videolibrary.plist"];
            }
        };
        /// add completion
        
    }
}


@end
