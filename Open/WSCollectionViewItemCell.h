//
//  WSCollectionViewItemCell.h
//  Open
//
//  Created by Rich Stoner on 12/26/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSCollectionViewItemCell : UICollectionViewCell

/**
 
 */

@property (nonatomic, strong) UIColor* iconColor;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel* primaryLabel;

@property (nonatomic, strong) UILabel* secondaryLabel;


- (void) setFontAwesomeIcon:(NSString*) fontAwesomeString;

- (void) setSecondaryText:(NSString *)theText;

- (void) setPrimaryText:(NSString *)theText;

@end
