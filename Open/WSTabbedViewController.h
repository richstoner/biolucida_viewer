//
//  WSTabbedViewController.h
//  Open
//
//  Created by Rich Stoner on 10/18/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMBTabViewController.h"
#import "duraModel.h"


@interface WSTabbedViewController : QMBTabViewController<QMBTabViewControllerDelegate>
{
    
}

- (id) initWithFrame:(CGRect) theFrame;

- (void) addOpenTab;

- (void) addDefaultTabForObject:(wsObject*) theObject;

@end
