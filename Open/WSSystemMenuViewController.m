//
//  WSSystemMenuViewController.m
//  Open
//
//  Created by Rich Stoner on 12/18/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//


#import "WSSystemMenuViewController.h"

@interface WSSystemMenuViewController () <RNFrostedSidebarDelegate>
{
    BOOL rotateBool;
}

@property(nonatomic, strong) UIButton* hideShowMenuButton;
@property(nonatomic, strong) RNFrostedSidebar* sideMenu;

@end

@implementation WSSystemMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSArray *images = @[
                        [FontAwesome imageWithIcon:fa_plus size:150 color:UIColorFromRGB(0xffffff)],
                        [FontAwesome imageWithIcon:fa_globe size:150 color:UIColorFromRGB(0xffffff)],
                        [FontAwesome imageWithIcon:fa_search size:150 color:UIColorFromRGB(0xffffff)],
                        [FontAwesome imageWithIcon:fa_pause size:150 color:UIColorFromRGB(0xffffff)],
                        [FontAwesome imageWithIcon:fa_cog size:150 color:UIColorFromRGB(0xffffff)]
                        ];
    
    NSArray *colors = @[KSystemMenuBackgroundColor, KSystemMenuBackgroundColor, KSystemMenuBackgroundColor, KSystemMenuBackgroundColor,  KSystemMenuBackgroundColor];
//    NSArray* labels = @[@"New tab", @"Web", @"Search", @"Settings"];
    
    self.sideMenu = [[RNFrostedSidebar alloc] initWithImages:images selectedIndices:Nil borderColors:colors];
    self.sideMenu.isSingleSelect = YES;
    self.sideMenu.width = 75;
    self.sideMenu.delegate = self;
    
    self.hideShowMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.hideShowMenuButton.frame = CGRectMake(0, 0, 44, 39);
    [self.hideShowMenuButton setImage:[FontAwesome imageWithIcon:fa_caret_left size:20 color:UIColorFromRGB(0xFFFFFF)] forState:UIControlStateNormal];
    self.hideShowMenuButton.backgroundColor = KSystemMenuBackgroundColor;
    [self.hideShowMenuButton addTarget:self action:@selector(showMenuTap:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.hideShowMenuButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - handle gestures

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.sideMenu dismissAnimated:NO];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
}

- (void)sidebar:(RNFrostedSidebar *)sidebar didTapItemAtIndex:(NSUInteger)index
{
    NSLog(@"Index: %d", index);
    
    switch (index) {
        case 0:
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowObjectBrowser object:nil];
            break;
            
        default:
            break;
    }
    
    [self.sideMenu performSelector:@selector(dismiss) withObject:nil afterDelay:0.5];
}

- (void)sidebar:(RNFrostedSidebar *)sidebar didDismissFromScreenAnimated:(BOOL)animatedYesOrNo
{
    [sidebar clearIndices];
}

-(void) showMenuTap:(id)sender
{
    [self.sideMenu show];
}

-(void) systemMenuTapped:(UITapGestureRecognizer*) r
{
    [self.sideMenu show];
}

@end
