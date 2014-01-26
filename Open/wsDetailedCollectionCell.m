//
//  wsDetailedCollectionCell.m
//  Open
//
//  Created by Rich Stoner on 1/12/14.
//  Copyright (c) 2014 WholeSlide. All rights reserved.
//

#import "wsDetailedCollectionCell.h"

@implementation wsDetailedCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        VerboseLog();
        
#if ISMBF
        
        self.iconColor = [UIColor darkGrayColor];
//        self.layer.borderColor = [UIColor darkGrayColor].CGColor;
//        self.layer.borderWidth = 1.0f;
        self.layer.cornerRadius = 4.0f;
        
        // make sure we rasterize nicely for retina
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
#else
        
        self.iconColor = [UIColor whiteColor];
        self.layer.cornerRadius = 4.0f;
        
        // make sure we rasterize nicely for retina
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
#endif

        
        //        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        CGRect newBounds = self.bounds;
        newBounds.size.width = MIN(newBounds.size.width, 70);
        newBounds.size.height = MIN(newBounds.size.height, 70);
        
        self.imageView = [[UIImageView alloc] initWithFrame:newBounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        self.primaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(68, 20, self.contentView.frame.size.width - 68, 20)];
        self.primaryLabel.backgroundColor = kCollectionViewBackgroundColor;
        self.primaryLabel.textColor = kCollectionSystemItemFontColor;
        self.primaryLabel.font = kCollectionItemHeaderFont;
        
        self.secondaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(68, 36, self.contentView.frame.size.width - 68, 20)];
        self.secondaryLabel.backgroundColor = kCollectionViewBackgroundColor;
        self.secondaryLabel.textColor = kCollectionSystemItemFontColor;
        self.secondaryLabel.font = kCollectionItemDetailFont;
        
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.primaryLabel];
        [self.contentView addSubview:self.secondaryLabel];
        

    }
    return self;
}


@end
