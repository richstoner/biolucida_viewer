//
//  WSLayersViewController.h
//  Open
//
//  Created by Rich Stoner on 8/29/14.
//  Copyright (c) 2014 WholeSlide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSLayersViewController : UIViewController

- (void) updateWithObject:(wsImageObject*) theObject;

-(wsObject*) getCurrentObject;

-(void)createWebkitview;

@end
