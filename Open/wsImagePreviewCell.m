//
//  wsImagePreviewCell.m
//  Open
//
//  Created by Rich Stoner on 12/30/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "wsImagePreviewCell.h"

@interface wsImagePreviewCell ()

@property (nonatomic, strong, readwrite) UIImageView *imageView;
@property (nonatomic, strong) UILabel* title;

@end

@implementation wsImagePreviewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kCollectionItemBackgroundColor;
        
        self.iconColor = [UIColor whiteColor];
        
    
        self.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.layer.borderWidth = 1.0f;
        self.layer.shadowColor = kCollectionItemShadowColor.CGColor;
        self.layer.shadowRadius = 4.0f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        self.layer.shadowOpacity = 0.5f;
        self.layer.cornerRadius = 10.0f;
        
        // make sure we rasterize nicely for retina
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
//        self.imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, 25, 25)];
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.imageView.layer.cornerRadius = 10.0f;
        
        [self.contentView addSubview:self.imageView];
        
//        UIView* labelBackground = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-30, self.frame.size.width, 30)];
//        labelBackground.backgroundColor = [UIColor whiteColor];
//        [self.contentView addSubview:labelBackground];
        
        
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, self.frame.size.width-8, 20)];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.textColor = kCollectionItemHeaderFontColor;
        self.title.font = [UIFont systemFontOfSize:10];
        
        if (IS_IPAD) {
            [self.contentView addSubview:self.title];
        }
    }
    
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.image = nil;
    self.title.text = @"";
}

- (void) setFontAwesomeIcon:(NSString*) fontAwesomeString
{
    if (IS_IPAD) {
        
        self.imageView.image = [FontAwesome imageWithIcon:fontAwesomeString iconColor:kFontAwesomeIconColor iconSize:36 imageSize:CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height )];
        
    }
    else{
        self.imageView.image = [FontAwesome imageWithIcon:fontAwesomeString iconColor:kFontAwesomeIconColor iconSize:14 imageSize:CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height )];
    }
    
    
}

- (void) setOverlayTitle:(NSString *)overlayTitle
{
    self.title.text = overlayTitle;
    
}

-(void)setSelected:(BOOL)selected
{
    if (selected) {
        //        self.backgroundColor = UIColorFromRGB(0xFF0000);
        self.layer.shadowColor = kCollectionItemShadowSelectColor.CGColor;
    }
    else
    {
        self.layer.shadowColor = kCollectionItemShadowColor.CGColor;
    }
}

@end
