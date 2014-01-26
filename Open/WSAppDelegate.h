//
//  WSAppDelegate.h
//  Open
//
//  Created by Rich Stoner on 10/18/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSViewController;

@interface WSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) WSViewController *viewController;

@end
