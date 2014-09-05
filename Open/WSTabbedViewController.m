//
//  WSTabbedViewController.m
//  Open
//
//  Created by Rich Stoner on 10/18/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//


#import "WSTabbedViewController.h"

#import <MPColorTools.h>
#import <FontAwesome.h>

#import "RNFrostedSidebar.h"
#import "WSTabbedViewController.h"
#import "wsCollectionViewController.h"
#import "WSBrowserTabViewController.h"

#import "WSLayersViewController.h"

#import "wsWebPageObject.h"

@interface WSTabbedViewController () <UIGestureRecognizerDelegate, RNFrostedSidebarDelegate, UIWebViewDelegate>
{

}

@property(nonatomic, strong) RNFrostedSidebar* sideMenu;

@property(nonatomic, strong) UIWebView* defaultContentView;

@end

@implementation WSTabbedViewController


- (id)init
{
    self = [super init];
    if (self) {
        
//        self.arrayOfTabViewControllers = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)theFrame
{
    self = [super init];
    if (self) {
        
//        self.arrayOfTabViewControllers = [[NSMutableArray alloc] init];

//        [self.view setFrame:theFrame];
        
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    VerboseLog();
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.delegate = self;
    
//    self.defaultContentView = [[UIWebView alloc] initWithFrame:CGRectMake(0, kTabHeight, self.view.frame.size.width, self.view.frame.size.height - kTabHeight)];
//    
//    self.defaultContentView.delegate = self;
//    self.defaultContentView.backgroundColor = kTabInactiveBackgroundColor;
//    
//    [self.view addSubview:self.defaultContentView];
//    
//    [self.defaultContentView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]]];
//    
//    
//    [self addSystemMenu];

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (QMBTabsAppearance *)getDefaultAppearance
{

    QMBTabsAppearance *appearance = [super getDefaultAppearance];
    
    [appearance setTabBarBackgroundColor:kTabContainerBackgroundColor];
    [appearance setTabBackgroundColorHighlighted:kTabActiveBackgroundColor];
    [appearance setTabBackgroundColorEnabled:kTabInactiveBackgroundColor];

    [appearance setTabBarHighlightColor:kTabActiveBackgroundColor];
    
    [appearance setTabCloseButtonImage:[UIImage imageNamed:@"qmb-tab-close-icon.png"]];
    [appearance setTabCloseButtonHighlightedImage:[UIImage imageNamed:@"qmb-tab-close-icon-highlight.png"]];
    
    [appearance setTabDefaultIconHighlightedImage:nil];
    [appearance setTabDefaultIconImage:nil];

    [appearance setTabLabelFontEnabled:kTabActiveFont];
    [appearance setTabLabelFontHighlighted:kTabActiveFont];
    
    [appearance setTabLabelColorHighlighted:kTabActiveFontColor];
    [appearance setTabLabelColorEnabled:kTabInactiveFontColor];

    [appearance setTabShadowBlur:3];
    [appearance setTabShadowColor:[UIColor blackColor]];
    
//    [appearance setTabShadowHeightOffset:kTabHeight];
//    [appearance setTabSideOffset:40];
    
    
    // Tabs
    //    [appearance setTabBackgroundColorHighlighted:[UIColor colorWithPatternImage:[UIImage imageNamed:@"qmb-tab-background-highlight.png"]]];
    //    [appearance setTabBackgroundColorEnabled:[UIColor colorWithPatternImage:[UIImage imageNamed:@"qmb-tab-background.png"]]];
    //    [appearance setTabBarHighlightColor:[UIColor colorWithRed:242.0f/255.0f green:140.0f/255.0f blue:19.0f/255.0f alpha:1.0f]];
    //    [appearance setTabBarBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"navigation-bar-background_44.png"]]];
    //    [appearance setTabBarStrokeHighlightColor:[UIColor redColor]];
    //    [appearance setTabDefaultIconHighlightedImage:[UIImage imageNamed:@"qmb-tab-icon-default-highlight.png"]];
    //    [appearance setTabDefaultIconImage:[UIImage imageNamed:@"qmb-tab-icon-default.png"]];
    //    [appearance setTabLabelColorEnabled:kTabInactiveFontColor];
    
    

    return appearance;
}


//-(void) tabBar:(QMBTabBar *)tabBar didChangeTabItem:(QMBTab *)tab{
//    VerboseLog();
//    
//}


- (BOOL)tabViewController:(QMBTabViewController *)tabViewController shouldSelectViewController:(UIViewController *)viewController
{
    VerboseLog();
    
    return YES;
}


-(void)tabViewController:(QMBTabViewController *)tabViewController willRemoveViewController:(UIViewController *)viewController
{
    VerboseLog(@"%@", viewController.class);
}

- (void)tabViewController:(QMBTabViewController *)tabViewController didSelectViewController:(UIViewController *)viewController
{
    VerboseLog(@"%@", tabViewController.viewControllers);
    
    for (int i=0; i< tabViewController.viewControllers.count; i++) {
        
        id vc = tabViewController.viewControllers[i];

        if (![vc isEqual:viewController]) {
            
            // one of the hidden frames
            if ([vc respondsToSelector:@selector(unregisterNotifications)]) {
                [vc performSelector:@selector(unregisterNotifications)];
            }
        }
        else
        {
            if ([vc respondsToSelector:@selector(registerNotifications)]) {
                [vc performSelector:@selector(registerNotifications)];
            }
        }
        
    }

}





#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint translation = [panGestureRecognizer translationInView:panGestureRecognizer.view];
    return fabs(translation.y) > fabs(translation.x);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}


#pragma mark - add tab modules

- (void) addOpenTab{
    
    wsCollectionViewController * newTab = [wsCollectionViewController new];
    
    __weak WSTabbedViewController* weakself = self;

    [self addViewController:newTab withCompletion:^(QMBTab *tabItem) {

        tabItem.titleLabel.text = kApplicationName;
        tabItem.iconHighlightedImage = [FontAwesome imageWithIcon:fa_asterisk iconColor:UIColorFromRGB(0x0099FF) iconSize:20 imageSize:CGSizeMake(30, 30)];
        tabItem.iconImage = [FontAwesome imageWithIcon:fa_asterisk iconColor:[UIColor darkGrayColor] iconSize:20 imageSize:CGSizeMake(30, 30)];

        UITapGestureRecognizer* gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:weakself action:@selector(doubleTapTab:)];
        [gestureRecognizer setNumberOfTapsRequired:2];
        [tabItem addGestureRecognizer:gestureRecognizer];

    }];
    
    [self selectViewController:newTab];
}



-(void) addDefaultTabForObject:(wsObject *)theObject
{
    VerboseLog(@"%@", theObject.class);
    
    if ([theObject isKindOfClass:[wsImageObject class]]) {
        
        WSLayersViewController* newTab = [[WSLayersViewController alloc] init];
        
#pragma warning hack for ios8 webkitview
        
        [newTab createWebkitview];
        
        
        [newTab updateWithObject:(wsImageObject*)theObject];
        [[WSMetaDataStore sharedDataStore] pushDataObjectToHistory:theObject];
        
        NSString* localizedName = theObject.localizedName;
        __weak WSTabbedViewController* weakself = self;
        
        [self addViewController:newTab withCompletion:^(QMBTab *tabItem) {

            tabItem.titleLabel.text = localizedName;
            
            UITapGestureRecognizer* gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:weakself action:@selector(doubleTapTab:)];
            [gestureRecognizer setNumberOfTapsRequired:2];
            [tabItem addGestureRecognizer:gestureRecognizer];

        }];

        [self selectViewController:newTab];
    }
    else if ([theObject isKindOfClass:[wsWebPageObject class]])
    {
        
        WSBrowserTabViewController* newTab = [[WSBrowserTabViewController alloc] init];
        
        [newTab updateWithObject:(wsDataObject*)theObject];
        
        [self addViewController:newTab withCompletion:^(QMBTab *tabItem) {
            
            tabItem.titleLabel.text = theObject.localizedName;
            
        }];
        
        [self selectViewController:newTab];
    }
    
    
}


-(void) doubleTapTab:(UITapGestureRecognizer*)r {
    
    UIViewController* vc = self.selectedViewController;
    
    if ([vc respondsToSelector:@selector(getCurrentObject)]){
        
        wsObject* obj = [vc performSelector:@selector(getCurrentObject)];
        
        NSDictionary* msg = @{@"object":obj};
        
        if (obj) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPresentMoreInformation object:msg];
            
        }
    }
}


@end
