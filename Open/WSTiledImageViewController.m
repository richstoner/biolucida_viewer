//////////////////////////////////////////////////////////////////////////////////////
//
//    This software is Copyright © 2013 WholeSlide, Inc. All Rights Reserved.
//
//    Permission to copy, modify, and distribute this software and its documentation
//    for educational, research and non-profit purposes, without fee, and without a
//    written agreement is hereby granted, provided that the above copyright notice,
//    this paragraph and the following three paragraphs appear in all copies.
//
//    Permission to make commercial use of this software may be obtained by contacting:
//
//    Rich Stoner, WholeSlide, Inc
//    8070 La Jolla Shores Dr, #410
//    La Jolla, CA 92037
//    stoner@wholeslide.com
//
//    This software program and documentation are copyrighted by WholeSlide, Inc. The
//    software program and documentation are supplied "as is", without any
//    accompanying services from WholeSlide, Inc. WholeSlide, Inc does not warrant
//    that the operation of the program will be uninterrupted or error-free. The
//    end-user understands that the program was developed for research purposes and is
//    advised not to rely exclusively on the program for any reason.
//
//    IN NO EVENT SHALL WHOLESLIDE, INC BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT,
//    SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING
//    OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF WHOLESLIDE,INC
//    HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. WHOLESLIDE,INCSPECIFICALLY
//    DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED
//    HEREUNDER IS ON AN "AS IS" BASIS, AND WHOLESLIDE,INC HAS NO OBLIGATIONS TO
//    PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS UNLESS
//    OTHERWISE STATED.
//
//////////////////////////////////////////////////////////////////////////////////////
//
//  WSTiledImageViewController.m
//  Open
//
//  Created by Rich Stoner on 10/27/13.
//

#import "WSTiledImageViewController.h"
#import "WSZNavigationViewController.h"
#import "WSThumbnailViewController.h"
#import "WSImageScrollView.h"
#import "wsImageObject.h"

@interface WSTiledImageViewController ()
{
    
}

@property(nonatomic, strong) wsImageObject* imageObject;

@property(nonatomic, strong) WSImageScrollView* imageScrollView;

@property(nonatomic, strong) NSMutableArray* accessoryViewControllers;


@end


@implementation WSTiledImageViewController

@synthesize imageScrollView;


- (id)init
{
    self = [super init];
    if (self) {
        
        self.imageScrollView = [WSImageScrollView new];
        
        self.accessoryViewControllers = [NSMutableArray new];
        
    }
    return self;
}

- (void)viewDidLoad
{
    
    VerboseLog();
    
    [super viewDidLoad];
    
    CGRect contentsFrame = self.view.frame;
    contentsFrame.size.height -= 44.0;
    self.view.frame = contentsFrame;

    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view.backgroundColor = kTabActiveBackgroundColor;
    
    //    self.view.backgroundColor = [kTabActiveBackgroundColor colorDarkenedBy:0.2];
    //    self.imageScrollView.backgroundColor = kTabActiveBackgroundColor;
    
    [self.view addSubview:self.imageScrollView];
    
    self.imageScrollView.autoresizingMask =UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.imageScrollView.frame = self.view.frame;
    
    [self loadCurrentObject];
    
    
}

-(void) viewWillAppear:(BOOL)animated
{
    VerboseLog(@"apear");
    
    if (self.imageScrollView) {
        [self.imageScrollView registerNotifications];
    }
    
    for (WSAccessoryViewController* vc in self.accessoryViewControllers) {
        
        [vc registerNotifications];
    }
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    VerboseLog(@"dissapear");
    
    if (self.imageScrollView) {
        [self.imageScrollView unregisterNotifications];
    }
    
    for (WSAccessoryViewController* vc in self.accessoryViewControllers) {
        
        [vc unregisterNotifications];
    }
    
}


// passes the image object into the tiling scroll view
- (void) loadCurrentObject
{
    VerboseLog(@"The object: %@ (%@)", self.imageObject.class, self.imageObject.localizedName);
    
    [self.imageScrollView loadImageObject:self.imageObject];
}

-(wsObject*) getCurrentObject
{
    return self.imageObject;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -

- (void) updateWithObject:(wsObject*) theObject
{
    self.imageObject = (wsImageObject*)theObject;
    
    // add the accessory views
    WSThumbnailViewController* accessoryView = [[WSThumbnailViewController alloc] init];
    accessoryView.view.frame = [self frameForBottomRight];

    [self.view addSubview:accessoryView.view];
    
//    // configure it (after the initial view layout called)
    [accessoryView loadRenderObject:self.imageObject];
    [self.accessoryViewControllers addObject:accessoryView];
    
    
    if ([theObject respondsToSelector:@selector(z_max)]) {
        
        NSNumber* zmax = [theObject performSelector:@selector(z_max)];
        
        if ([zmax intValue] > 1) {
            
            WSZNavigationViewController* znav = [WSZNavigationViewController new];
            znav.view.frame = [self frameForZNav];
            [znav loadRenderObject:(wsRenderObject*)theObject];
            [self.view addSubview:znav.view];
            [self.accessoryViewControllers addObject:znav];

        }
        
    }
    
}



-(CGRect) frameForBottomRight
{
    return CGRectMake(self.view.frame.size.width - kThumbnailWidth - 10, self.view.frame.size.height - kThumbnailHeight - 10, kThumbnailWidth + 10, kThumbnailHeight + 10);
}

-(CGRect) frameForZNav
{
    return CGRectMake(self.view.frame.size.width - 60, self.view.frame.size.height - kThumbnailHeight - kZNavHeight - 20, 40, kZNavHeight);
}



@end
