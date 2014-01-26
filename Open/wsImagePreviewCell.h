//
//  wsImagePreviewCell.h
//  Open
//
//  Created by Rich Stoner on 12/30/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface wsImagePreviewCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIImageView *imageView;

@property (nonatomic, strong) UIColor* iconColor;

- (void) setFontAwesomeIcon:(NSString*) fontAwesomeString;

- (void) setOverlayTitle:(NSString*) overlayTitle;


@end
