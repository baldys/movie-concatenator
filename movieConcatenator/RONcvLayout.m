//
//  UICollectionViewLayout.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-03-12.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//
//
//#import "RONcvLayout.h"
//
//@implementation RONcvLayout
//
//-(id)init {
//    self = [super init];
//    if (self) {
//        self.itemSize = CGSizeMake(250, 250);
//        self.scrollDirection = UICollectionViewScrollDirectionVertical;
//        self.sectionInset = UIEdgeInsetsMake(100, 0.0, 100, 0.0);
//        self.minimumLineSpacing = 50.0;
//    }
//    return self;
//}
//
//- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
//    return YES;
//}
//
//-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
//    NSArray* array = [super layoutAttributesForElementsInRect:rect];
//    CGRect visibleRect;
//    visibleRect.origin = self.collectionView.contentOffset;
//    visibleRect.size = self.collectionView.bounds.size;
//    
//    return array;
//}
//
//- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
//    CGFloat offsetAdjustment = MAXFLOAT;
//    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
//    
//    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
//    NSArray* array = [super layoutAttributesForElementsInRect:targetRect];
//    
//    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
//        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
////        if (ABS(itemHorizontalCenter) - ABS(offsetAdjustment))
////        {
////              offsetAdjustment = itemHorizontalCenter - horizontalCenter;
////        }
//        
//        
//    }
//    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
//}
//
//
//@end
