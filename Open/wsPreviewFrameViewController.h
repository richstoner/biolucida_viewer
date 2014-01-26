//
//  wsPreviewFrameViewController.h
//  Open
//
//  Created by Rich Stoner on 1/3/14.
//  Copyright (c) 2014 WholeSlide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface wsPreviewFrameViewController : UIViewController

/**
 The colleciton object containing this object (in case we need to delete it)
 */
@property(nonatomic, strong) wsObject* sourceObject;


/**
 The object itself
 */
@property(nonatomic, strong) wsObject* obj;


-(void) registerNotifications;

-(void) unregisterNotifications;


@end
