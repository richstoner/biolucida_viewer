//
//  WSViewController.m
//  Open
//
//  Created by Rich Stoner on 10/18/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

/* This is the root view controller
 
 This vc manages 1, 2, or 4 tabbed view controllers

 Each tabbed view controller is responsible for handling its own state.
 
 */

#import "RNBlurModalView.h"
#import "WSTabbedViewController.h"
#import "WSAddNewLocationViewController.h"
#import "wsPreviewFrameViewController.h"
#import "WSPlayground.h"

#import "WSViewController.h"

@interface WSViewController () <UIGestureRecognizerDelegate>
{

    
    

}

@property(nonatomic, strong) WSPlayground* playGround;


// determines how to layout tabbed view controllers
@property(nonatomic, readwrite) tabbedViewState currentViewState;

// an array of view controllers, index corresponds to location
@property(nonatomic, strong) NSMutableArray* tabbedViewControllers;

@property(nonatomic, strong) UIButton* hideShowMenuButton;

@property(nonatomic, strong) UIActivityIndicatorView* activityIndicator;

@property(nonatomic, strong)     RNBlurModalView *modal;

@property(nonatomic, strong)     UIViewController *modalViewController;



@end

@implementation WSViewController

@synthesize modalViewController;

@synthesize currentViewState = _currentViewState;
@synthesize tabbedViewControllers = _tabbedViewControllers;
//@synthesize menuViewController = _menuViewController;
@synthesize activityIndicator;

-(UIInterfaceOrientation) oppositeOrientationFrom:(UIInterfaceOrientation) theOrientation{
    if (UIInterfaceOrientationIsLandscape(theOrientation)){
        return UIInterfaceOrientationPortrait;
    }
    else{
        return UIInterfaceOrientationLandscapeLeft;
    }
}

- (void)viewDidLoad
{
    VerboseLog();
    
//    NSLog(@"%@",[NSThread callStackSymbols]);
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
//    self.view.backgroundColor = UIColorFromRGB(0xee0000);
    self.view.backgroundColor = kTabActiveBackgroundColor;
    
    // check if there was a view state saved that we need to reload, if yes, reload
    
#pragma todo
    
    // else, load default view state

    // default view state is single tabbed view, with initial tab containing local, recent, and main menu
    self.currentViewState = tabbedViewStateSingle;
    
    // initialize nsmutable array of view controllers
    self.tabbedViewControllers = [[NSMutableArray alloc] initWithCapacity:NUMBER_OF_SUBVIEWS];
    
    
    // initialize each tabbed view controller and add to array.
    for(int i=0;i<NUMBER_OF_SUBVIEWS;i++)
    {
        WSTabbedViewController* tabbedViewController = [[WSTabbedViewController alloc] init];
        tabbedViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:tabbedViewController.view];
        
        [self addChildViewController:tabbedViewController];
        [self.tabbedViewControllers addObject:tabbedViewController];
    }
    
    
    [self layoutTabbedViews];
    
    UIView* backDropView = [UIView new];
    backDropView.frame = CGRectMake(0, 0, 44, 39);
    backDropView.backgroundColor = kTabContainerBackgroundColor;
    [self.view addSubview:backDropView];
    
    
    self.hideShowMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.hideShowMenuButton.frame = CGRectMake(0, 0, 44, 39);
//    self.hideShowMenuButton.layer.cornerRadius = 15.0;
//    self.hideShowMenuButton.layer.borderColor = UIColorFromRGB(0xffffff).CGColor;
//    self.hideShowMenuButton.layer.borderWidth = 1.0f;
    [self.hideShowMenuButton setImage:[FontAwesome imageWithIcon:fa_plus size:20 color:kAddTabButtonColor] forState:UIControlStateNormal];
    self.hideShowMenuButton.backgroundColor =  [UIColor clearColor];
    [self.hideShowMenuButton addTarget:self action:@selector(showMenuTap:) forControlEvents:UIControlEventTouchUpInside];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:self.hideShowMenuButton.frame];
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
//    self.activityIndicator.hidesWhenStopped = NO;
    self.activityIndicator.backgroundColor = kTabContainerBackgroundColor;


    [self.view addSubview:self.activityIndicator];
    [self.view addSubview:self.hideShowMenuButton];

    
    [self registerForNotifications];
    
    self.playGround = [WSPlayground new];
    [self.playGround play];
    
//    UIScreenEdgePanGestureRecognizer* r = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(edgePanDetected:)];
//    [r setEdges:UIRectEdgeLeft];
//    
//    [self.view addGestureRecognizer:r];

}
//
//-(void) edgePanDetected:(UIGestureRecognizer*) r
//{
//    CGPoint translatedPoint = [(UIScreenEdgePanGestureRecognizer*)r translationInView:self.view];
//    float d  = sqrtf(powf(translatedPoint.x, 2) + powf(translatedPoint.y, 2));
//    NSLog(@"%f", d);
//    
//    
//    
//    if (d > 40) {
//        
//        if (YES) {
//            
//            [self.sideMenu show];
//        }
//
//    }
//    
//}

//- (void) addSystemMenu
//{
//    
//    NSArray *images = @[
//                        [FontAwesome imageWithIcon:fa_folder size:150 color:UIColorFromRGB(0xffffff)],
//                        [FontAwesome imageWithIcon:fa_globe size:150 color:UIColorFromRGB(0xffffff)],
//                        [FontAwesome imageWithIcon:fa_search size:150 color:UIColorFromRGB(0xffffff)],
//                        [FontAwesome imageWithIcon:fa_pause size:150 color:UIColorFromRGB(0xffffff)],
//                        [FontAwesome imageWithIcon:fa_cog size:150 color:UIColorFromRGB(0xffffff)]
//                        ];
//    
//    NSArray *colors = @[KSystemMenuBackgroundColor, KSystemMenuBackgroundColor, KSystemMenuBackgroundColor, KSystemMenuBackgroundColor,  KSystemMenuBackgroundColor];
//    //    NSArray* labels = @[@"New tab", @"Web", @"Search", @"Settings"];
//    
//    self.sideMenu = [[RNFrostedSidebar alloc] initWithImages:images selectedIndices:Nil borderColors:colors];
//    self.sideMenu.isSingleSelect = YES;
//    self.sideMenu.width = 150;
//    self.sideMenu.showFromRight = YES;
//    self.sideMenu.delegate = self;
//    
//    self.hideShowMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.hideShowMenuButton.frame = CGRectMake(0, 0, 44, 39);
////    self.hideShowMenuButton.layer.cornerRadius = 15.0;
////    self.hideShowMenuButton.layer.borderColor = UIColorFromRGB(0xffffff).CGColor;
////    self.hideShowMenuButton.layer.borderWidth = 1.0f;
//    [self.hideShowMenuButton setImage:[FontAwesome imageWithIcon:fa_plus size:20 color:UIColorFromRGB(0xFFFFFF)] forState:UIControlStateNormal];
//    self.hideShowMenuButton.backgroundColor = [UIColor blackColor];
//    [self.hideShowMenuButton addTarget:self action:@selector(showMenuTap:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:self.hideShowMenuButton];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    [self layoutTabbedViewsForOrientation:toInterfaceOrientation]];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self layoutTabbedViewsForOrientation:fromInterfaceOrientation];
}

- (void) layoutTabbedViews
{
    UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self layoutTabbedViewsForOrientation:toInterfaceOrientation];
}


- (void) layoutTabbedViewsForOrientation:(UIInterfaceOrientation) theOrientation
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{

        for(int i=0;i < [self.tabbedViewControllers count]; i++){
            WSTabbedViewController* tempVC = self.tabbedViewControllers[i];
            [tempVC.view setFrame:[self frameForViewAtIndex:i forOrientation:theOrientation]];
        }

        
    } completion:^(BOOL finished) {
        
    }];
    
}



#pragma mark - layout methods

// Clear beats concise.

- (CGRect) frameForViewAtIndex:(int) theIndex forOrientation:(UIInterfaceOrientation)theOrientation
{
    if (self.currentViewState == tabbedViewStateSingle) {
        
        // if single view, 0 index takes full screen
        if (theIndex==0) {
            return [self frameForFullWithOrientation:theOrientation];
        }
        else{
            return CGRectZero;
        }
    }
    else if (self.currentViewState == tabbedViewStateDual) {
        
        // if dual view, only indices 0 & 1 need frames
        if (theIndex < 2)
        {
            return [self frameForSide:theIndex withOrientation:theOrientation];
        }
        else
        {
            return CGRectZero;
        }
    }
    else if (self.currentViewState == tabbedViewStateQuad)
    {
        return [self frameForQuandrant:theIndex withOrientation:theOrientation];
        
    }
    return CGRectZero;
}




- (CGRect) frameForFullWithOrientation:(UIInterfaceOrientation) theOrientation
{
    
    CGRect bound = self.view.bounds;
//    CGRect frame = CGRectMake(0, 0, bound.size.height, bound.size.width);
    return bound;
}


// Quadrants
// 0 | 1
// -----
// 2 | 3
- (CGRect) frameForQuandrant:(int) theQuadrant withOrientation:(UIInterfaceOrientation) theOrientation
{
    
    CGRect frame = [self frameForFullWithOrientation:theOrientation];
    
    BOOL iPad = NO;
#ifdef UI_USER_INTERFACE_IDIOM
    iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif
    if (iPad) {
        
        frame.size.width *= 0.5;
        frame.size.height *= 0.5;
        
        frame.origin.x = (theQuadrant % 2) * frame.size.width;
        frame.origin.y = (theQuadrant / 2) * frame.size.height;
        
    }
    else{
        
        frame.size.width *= 0.5;
        frame.size.height *= 0.5;
        
        frame.origin.x = (theQuadrant % 2) * frame.size.width;
        frame.origin.y = (theQuadrant / 2) * frame.size.height;
        
    }
    
    
    return frame;
}

// Sides
// 0 | 1

- (CGRect) frameForSide:(int) theSide withOrientation:(UIInterfaceOrientation) theOrientation
{
    CGRect frame = [self frameForFullWithOrientation:theOrientation];
    
    BOOL iPad = NO;
#ifdef UI_USER_INTERFACE_IDIOM
    iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif
    
    if (UIDeviceOrientationIsPortrait(theOrientation)) {
        // if portrat split horiztonally
        frame.size.width *= 0.5;
        frame.origin.x = (theSide) * frame.size.width;
    }
    else{
        // if landscape, split vertically
        frame.size.height *= 0.5;
        frame.origin.y = (theSide) * frame.size.height;
    }
    
    NSLog(@"%d: %@", theSide, [NSValue valueWithCGRect:frame]);
    
    return frame;
}



#pragma mark - Message routing

- (void) registerForNotifications {
    
    VerboseLog();
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(presentOpenTab:)
                                                 name:kNotificationShowObjectBrowser
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(presentObjectDefault:)
                                                 name:kNotificationPresentObject
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(presentMoreInformation:)
                                                 name:kNotificationPresentMoreInformation
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(presentAddObject:)
                                                 name:kNotificationAddObject
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissModalView:)
                                                 name:kNotificationDismissModal
                                               object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestLinkForDropbox:)
                                                 name:kNotificationRequestDropboxLink
                                               object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startSystemIndicator:)
                                                 name:AFNetworkingTaskDidStartNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopSystemIndicator:)
                                                 name:AFNetworkingTaskDidFinishNotification
                                               object:nil];
    
    
    
    
    
  
    
    

}


-(void) startSystemIndicator:(NSNotification*) notification
{
    [self.activityIndicator startAnimating];
}

-(void) stopSystemIndicator:(NSNotification*) notification
{
    [self.activityIndicator stopAnimating];
}

- (void) requestLinkForDropbox:(NSNotification*) notification
{
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
}



- (void) presentOpenTab:(NSNotification*) notification
{
    VerboseLog();
    WSTabbedViewController* tv = self.tabbedViewControllers[0];
    [tv addOpenTab];
}


- (void) presentObjectDefault:(NSNotification*) notification {
    VerboseLog();
    
    WSTabbedViewController* tv = self.tabbedViewControllers[0];
    [tv addDefaultTabForObject:[notification object]];
    
}


#pragma mark - System menu

-(void) showMenuTap:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowObjectBrowser object:nil];
}


#pragma mark - Object information view

-(void) presentMoreInformation:(NSNotification*)notification
{
    
    NSDictionary* msg = notification.object;
    
    wsPreviewFrameViewController* anvc = [[wsPreviewFrameViewController alloc] init];
    anvc.obj = msg[@"object"];
    anvc.sourceObject = msg[@"source"];
    [anvc registerNotifications];
    
    self.modalViewController = anvc;
    
    self.modal = [[RNBlurModalView alloc] initWithViewController:self view:self.modalViewController.view];
    self.modal.animationOptions = UIViewAnimationOptionShowHideTransitionViews;
    self.modal.animationDelay = 0.0;
    self.modal.animationDuration = 0.1;
    
    [self.modal show];
    
    
}

-(void) presentAddObject:(NSNotification*) notification
{
    
    NSDictionary* msg = [notification object];

    self.modalViewController = [[WSAddNewLocationViewController alloc] init];
    self.modal = [[RNBlurModalView alloc] initWithViewController:self view:self.modalViewController.view];

    self.modal.animationDelay = 0.0;
    self.modal.animationDuration = 0.1;

    WSAddNewLocationViewController* anlvc = (WSAddNewLocationViewController*)self.modalViewController;
    [anlvc setSourceObject:msg[@"source"]];


    
    [self.modal show];



}



-(void) dismissModalView:(NSNotification*) notification
{
    
    [self.modal hide];
    
}




@end
