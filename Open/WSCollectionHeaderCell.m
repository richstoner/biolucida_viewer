//
//  WSCollectionCell.m
//  Open
//
//  Created by Rich Stoner on 12/9/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "WSCollectionHeaderCell.h"
#import <QuartzCore/QuartzCore.h>

@interface WSCollectionHeaderCell ()

@property(nonatomic, strong) UILabel* textLabel;
@property(nonatomic, strong) UILabel* secondaryTextLabel;

@property(nonatomic, strong) wsCollectionObject* collection;


@end

@implementation WSCollectionHeaderCell

@synthesize textLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = kCollectionViewBackgroundColor;
        self.opaque = YES;
        
        self.textLabel =[[UILabel alloc] initWithFrame:CGRectMake(5, 4, self.frame.size.width - 180, 20)];
        self.textLabel.font = kSectionHeaderFont;
        self.textLabel.textColor = kSectionDetailFontColor;
        self.textLabel.backgroundColor = kSectionBackgroundColor;

//        self.secondaryTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-180, 4, 170, 30)];
        self.secondaryTextLabel =[[UILabel alloc] initWithFrame:CGRectMake(5, 21, self.frame.size.width - 180, 20)];
        self.secondaryTextLabel.font = kSectionDetailFont;
        self.secondaryTextLabel.textColor = kSectionDetailFontColor;
        self.secondaryTextLabel.backgroundColor = kSectionBackgroundColor;
//        self.secondaryTextLabel.textAlignment = NSTextAlignmentRight;
        
    
        [self addSubview:self.textLabel];
        [self addSubview:self.secondaryTextLabel];

//        UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 34, self.frame.size.width, 2)];
//        lineView.backgroundColor = kSectionDetailFontColor;
//        [lineView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
//        [self addSubview:lineView];
        
        
    }
    return self;
}



-(void) loadObject:(wsCollectionObject*) object
{
    self.collection = object;
    
    self.textLabel.text = self.collection.localizedName;
    self.secondaryTextLabel.text = self.collection.localizedDescription;
    
    if (self.collection.supportsAddObject) {
        
        UIButton* addObjectButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        addObjectButton.frame = CGRectMake(self.frame.size.width - 40, 0, 40, 40);
        [addObjectButton addTarget:self action:@selector(performAddObjectActivity:) forControlEvents:UIControlEventTouchUpInside];
        addObjectButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:addObjectButton];
        
    }
    else
    {
        for (UIView* view in self.subviews) {
            
            if ([view isKindOfClass:[UIButton class]]) {
                // removing the add contact button
                [view removeFromSuperview];
            }
        }
    }
    
}


-(void) performAddObjectActivity:(id)sender
{
    NSDictionary* msg = @{@"source" : self.collection};
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAddObject object:msg];
}


@end
