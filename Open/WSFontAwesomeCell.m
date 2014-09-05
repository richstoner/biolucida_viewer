//
//  WSFontAwesomeCell.m
//  Open
//
//  Created by Rich Stoner on 9/4/14.
//  Copyright (c) 2014 WholeSlide. All rights reserved.
//

#import "WSFontAwesomeCell.h"

@implementation WSFontAwesomeCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        self.backgroundColor = [UIColor clearColor];
        
        self.iconColor = kMBFBlue;
        
//        self.layer.borderColor = [UIColor darkGrayColor].CGColor;
//        self.layer.borderWidth = 1.0f;
//        self.layer.shadowColor = kCollectionItemShadowColor.CGColor;
//        self.layer.shadowRadius = 4.0f;
//        self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
//        self.layer.shadowOpacity = 0.5f;
//        self.layer.cornerRadius = 4.0f;
        
        // make sure we rasterize nicely for retina
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
        
        CGRect newBounds = self.bounds;
        newBounds.size.height = MIN(newBounds.size.height, newBounds.size.height);
        newBounds.size.width = newBounds.size.height;
        
        self.imageView = [[UIImageView alloc] initWithFrame:newBounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        self.primaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(newBounds.size.width - 4, 22, 225, 20)];
        self.primaryLabel.backgroundColor = kCollectionItemBackgroundColor;
        self.primaryLabel.textColor = kCollectionItemHeaderFontColor;
        self.primaryLabel.font = kCollectionItemHeaderFont;
        
        self.secondaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(newBounds.size.width -3, 39, 225, 20)];
        self.secondaryLabel.backgroundColor = kCollectionItemBackgroundColor;
        self.secondaryLabel.textColor = kCollectionItemDetailFontColor;
        self.secondaryLabel.font = kCollectionItemDetailFont;
        
        [self.contentView addSubview:self.imageView];
        
        [self.contentView addSubview:self.primaryLabel];
        [self.contentView addSubview:self.secondaryLabel];
        
        
        
    }
    return self;
}


@end
