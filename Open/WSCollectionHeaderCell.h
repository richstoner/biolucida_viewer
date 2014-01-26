//
//  WSCollectionCell.h
//  Open
//
//  Created by Rich Stoner on 12/9/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import <UIKit/UIKit.h>

@class wsCollectionObject;

@interface WSCollectionHeaderCell : UICollectionReusableView

-(void) loadObject:(wsCollectionObject*) object;

@end
