//
//  wsLargeImageCollectionCell.m
//  Open
//
//  Created by Rich Stoner on 1/12/14.
//  Copyright (c) 2014 WholeSlide. All rights reserved.
//

#import "wsLargeImageCollectionCell.h"

@implementation wsLargeImageCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = kCollectionItemBackgroundColor;
        
        
        self.iconColor = [UIColor whiteColor];
        
        self.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.layer.borderWidth = 1.0f;
        self.layer.shadowColor = kCollectionItemShadowColor.CGColor;
        self.layer.shadowRadius = 4.0f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        self.layer.shadowOpacity = 0.5f;
        self.layer.cornerRadius = 4.0f;
        
        // make sure we rasterize nicely for retina
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
        
        //        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        CGRect newBounds = self.bounds;
        newBounds.size.width = MIN(newBounds.size.width, 230);
        
        newBounds.size.height = MIN(newBounds.size.height, newBounds.size.height - 40);
        
        self.imageView = [[UIImageView alloc] initWithFrame:newBounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        //        self.imageView.layer.cornerRadius = 10.0f;
        
        
        self.primaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,newBounds.size.height + 2, 225, 20)];
        self.primaryLabel.backgroundColor = kCollectionItemBackgroundColor;
        self.primaryLabel.textColor = kCollectionItemHeaderFontColor;
        self.primaryLabel.font = kCollectionItemHeaderFont;
        
        self.secondaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, newBounds.size.height + 17, 225, 20)];
        self.secondaryLabel.backgroundColor = kCollectionItemBackgroundColor;
        self.secondaryLabel.textColor = kCollectionItemDetailFontColor;
        self.secondaryLabel.font = kCollectionItemDetailFont;
        
        [self.contentView addSubview:self.imageView];
        
        [self.contentView addSubview:self.primaryLabel];
        [self.contentView addSubview:self.secondaryLabel];
  

        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
