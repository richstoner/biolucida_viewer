//
//  WSEMVolumeBrowserViewController.h
//  Open
//
//  Created by Rich Stoner on 12/2/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface WSGLBrowserViewController : GLKViewController <wsRenderObjectDelegate, UIGestureRecognizerDelegate>




-(wsObject*) getCurrentObject;

- (void) updateWithObject:(wsRenderObject*) theObject;

-(void) registerNotifications;

-(void) unregisterNotifications;

- (void)tearDownGL;

@end
