//
//  wsCollectionLayout.m
//  Open
//
//  Created by Rich Stoner on 1/25/14.
//  Copyright (c) 2014 WholeSlide. All rights reserved.
//

#import "wsCollectionLayout.h"

@implementation wsCollectionLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray* arr = [super layoutAttributesForElementsInRect:rect];
    for (UICollectionViewLayoutAttributes* atts in arr) {
        if (nil == atts.representedElementKind) {
            NSIndexPath* ip = atts.indexPath;
            atts.frame = [self layoutAttributesForItemAtIndexPath:ip].frame;
        }
    }
    return arr;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* atts =
    [super layoutAttributesForItemAtIndexPath:indexPath];
    
    if (indexPath.item == 0 || indexPath.item == 1) // degenerate case 1, first item of section
        return atts;
    
    NSIndexPath* ipPrev =
    [NSIndexPath indexPathForItem:indexPath.item-2 inSection:indexPath.section];
    
    CGRect fPrev = [self layoutAttributesForItemAtIndexPath:ipPrev].frame;
    CGFloat rightPrev = fPrev.origin.y + fPrev.size.height + 10;
//    if (atts.frame.origin.y <= rightPrev) // degenerate case 2, first item of line
    
        return atts;
    
    CGRect f = atts.frame;
    f.origin.y = rightPrev;
    atts.frame = f;
    return atts;
}

@end
