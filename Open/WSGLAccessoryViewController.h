//
//  WSGLAccessoryViewController.h
//  Open
//
//  Created by Rich Stoner on 12/9/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol wsAccessoryDelegate;

@interface WSGLAccessoryViewController : UIViewController

@property (nonatomic, weak) id<wsAccessoryDelegate> delegate;


-(void) updateWithObject:(wsRenderObject*) theObject;

-(void) updateLayoutForOrientation:(UIInterfaceOrientation) theOrientation;

-(void) updatePositionString:(NSString*) theString;
@end

@protocol wsAccessoryDelegate <NSObject>

- (void) performAction:(defaultButtonAction) theAction;

@end


