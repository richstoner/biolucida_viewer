//
//  WSCollectionViewItemCell.m
//  Open
//
//  Created by Rich Stoner on 12/26/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "WSCollectionViewItemCell.h"

@interface WSCollectionViewItemCell ()


@end

@implementation WSCollectionViewItemCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.image = nil;
    self.primaryLabel.text = @"";
    self.secondaryLabel.text = @"";
    
}

- (void) setFontAwesomeIcon:(NSString*) fontAwesomeString
{
    if (IS_IPAD) {
        
        self.imageView.image = [FontAwesome imageWithIcon:fontAwesomeString iconColor:self.iconColor iconSize:36 imageSize:CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height )];
        
    }
    else{
        self.imageView.image = [FontAwesome imageWithIcon:fontAwesomeString iconColor:self.iconColor iconSize:14 imageSize:CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height )];
    }
    

}

- (void) setPrimaryText:(NSString *)theText
{
    self.primaryLabel.text = theText;
}

- (void) setSecondaryText:(NSString *)theText
{
    self.secondaryLabel.text = theText;
}

-(void)setSelected:(BOOL)selected
{
    if (selected) {
        self.layer.shadowColor = kCollectionItemShadowSelectColor.CGColor;
    }
    else
    {
        self.layer.shadowColor = kCollectionItemShadowColor.CGColor;
    }
}




@end
