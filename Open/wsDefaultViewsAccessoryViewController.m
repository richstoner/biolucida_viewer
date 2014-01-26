//
//  wsDefaultViewsAccessoryViewController.m
//  Open
//
//  Created by Rich Stoner on 1/10/14.
//  Copyright (c) 2014 WholeSlide. All rights reserved.
//

#import "wsDefaultViewsAccessoryViewController.h"

@interface wsDefaultViewsAccessoryViewController ()

@property(nonatomic, strong) UIToolbar* controlToolbar;

@property(nonatomic, strong) UILabel* viewPosition;

@end

@implementation wsDefaultViewsAccessoryViewController

@synthesize viewPosition;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    self.controlToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
//    self.controlToolbar.barTintColor = kPreviewBackgroundColor;
//    self.controlToolbar.backgroundColor = kPreviewBackgroundColor;
//    
    [self.controlToolbar setBarStyle:UIBarStyleBlack];
    [self.controlToolbar setTranslucent:YES];
    
    self.view = self.controlToolbar;
    self.view.exclusiveTouch = YES;
    
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    self.view.frame = CGRectMake(0, 0, 300, 40);
//    self.view.autoresizingMask = UIViewAutoresizingNone;
//    self.view.backgroundColor = kCollectionItemBackgroundColor;
//    self.view.opaque = YES;
    
    
//    [self.view addSubview:self.controlToolbar];
    


    
    
    [self configureBarItems];
}


-(void) configureBarItems
{
    UIBarButtonItem* leftItem = [[UIBarButtonItem alloc] initWithImage:[FontAwesome imageWithIcon:fa_angle_left size:24 color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(barItemTap:)];
    leftItem.tag = defaultButtonActionAnimateToViewLeft;
    leftItem.tintColor = UIColorFromRGB(0xAAAAAA);
    
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithImage:[FontAwesome imageWithIcon:fa_angle_right size:24 color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(barItemTap:)];
    rightItem.tag = defaultButtonActionAnimateToViewRight;
    rightItem.tintColor = UIColorFromRGB(0xAAAAAA);
    
    
    UIBarButtonItem* separatorItem1 = [[UIBarButtonItem alloc] initWithTitle:@"|" style:UIBarButtonItemStylePlain target:nil action:nil];
    separatorItem1.tintColor = kDURABlue;
    
    UIBarButtonItem* forwardItem = [[UIBarButtonItem alloc] initWithImage:[FontAwesome imageWithIcon:fa_angle_double_up size:24 color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(barItemTap:)];
    forwardItem.tag = defaultButtonActionAnimateToViewFront;
    forwardItem.tintColor = UIColorFromRGB(0xAAAAAA);
    
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithImage:[FontAwesome imageWithIcon:fa_angle_double_down size:24 color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(barItemTap:)];
    backItem.tag = defaultButtonActionAnimateToViewBack;
    backItem.tintColor = UIColorFromRGB(0xAAAAAA);
    
    UIBarButtonItem* separatorItem2 = [[UIBarButtonItem alloc] initWithTitle:@"|" style:UIBarButtonItemStylePlain target:nil action:nil];
    separatorItem2.tintColor = kDURABlue;
    

    UIBarButtonItem* topItem = [[UIBarButtonItem alloc] initWithImage:[FontAwesome imageWithIcon:fa_angle_up size:24 color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(barItemTap:)];
    topItem.tag = defaultButtonActionAnimateToViewTop;
    topItem.tintColor = UIColorFromRGB(0xAAAAAA);
    
    UIBarButtonItem* bottomItem = [[UIBarButtonItem alloc] initWithImage:[FontAwesome imageWithIcon:fa_angle_down size:24 color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(barItemTap:)];
    bottomItem.tag = defaultButtonActionAnimateToViewBottom;
    bottomItem.tintColor = UIColorFromRGB(0xAAAAAA);
    

    UIBarButtonItem* separatorItem3 = [[UIBarButtonItem alloc] initWithTitle:@"|" style:UIBarButtonItemStylePlain target:nil action:nil];
    separatorItem2.tintColor = kDURABlue;

    self.viewPosition = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    self.viewPosition.text = @"test";
    self.viewPosition.textColor =UIColorFromRGB(0xAAAAAA);
    

    UIBarButtonItem* positionItem = [[UIBarButtonItem alloc] initWithCustomView:self.viewPosition];
    positionItem.tag = defaultButtonActionAnimateToViewBottom;
    positionItem.tintColor = UIColorFromRGB(0xAAAAAA);
    
//    
//    UIBarButtonItem* tableItem = [[UIBarButtonItem alloc] initWithImage:[FontAwesome imageWithIcon:fa_external_link size:22 color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(barItemTap:)];
//    tableItem.tag = defaultButtonActionOpenSelectedInCurrentTab;
//    tableItem.tintColor = UIColorFromRGB(0xAAAAAA);
//    
//    
//    
//    UIBarButtonItem* fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    fixedItem.width = 5.0f;
    
    
    
    //    UIBarButtonItem* tableItem = [[UIBarButtonItem alloc] initWithImage:[FontAwesome imageWithIcon:fa_th size:24 color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(tableItemTap:)];
    //    tableItem.tintColor = [UIColor whiteColor];
    
//    
//    UIBarButtonItem* flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    [self.controlToolbar setItems:@[leftItem, rightItem, separatorItem1, topItem, bottomItem, separatorItem2, forwardItem, backItem, separatorItem3, positionItem]];
    
}

-(void) barItemTap:(UIBarButtonItem*) theItem
{
    if ([self.delegate respondsToSelector:@selector(performAction:)]) {
        [self.delegate performAction:theItem.tag];
    }
}

-(void) updateLayoutForOrientation:(UIInterfaceOrientation) theOrientation
{
    
    if (UIInterfaceOrientationIsPortrait(theOrientation)) {
        
        self.view.frame = CGRectMake(0, 0, self.view.superview.frame.size.width, 40);
        
//        self.buttonView.frame = CGRectMake(300, 0, 168, k3DToolBarHeight);
        
    }
    else{
        
        self.view.frame = CGRectMake(0, 0, self.view.superview.frame.size.width-k3DToolBarWidth, 40);
//        
//        self.view.frame = CGRectMake(self.view.superview.frame.size.width - k3DToolBarWidth, 0, k3DToolBarWidth, self.view.superview.frame.size.height-k3DToolBarHeight);
//        
//        self.buttonView.frame = CGRectMake(0, 200, 300, k3DToolBarHeight);
    }
}



-(void) updatePositionString:(NSString*) theString
{
    self.viewPosition.text = theString;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
