//
//  WSGLEMAccessoryViewController.m
//  Open
//
//  Created by Rich Stoner on 12/10/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "WSGLEMAccessoryViewController.h"

@interface WSGLEMAccessoryViewController ()

@property(nonatomic, strong) UIToolbar* controlToolbar;

@end

@implementation WSGLEMAccessoryViewController

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
    
    
//    
//    UIView* positionLabelView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 30)];
//    positionLabelView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
//    positionLabelView.layer.cornerRadius = 5.0;
//    positionLabelView.layer.borderColor = UIColorFromRGB(0xEEEEEE).CGColor;
//    positionLabelView.layer.borderWidth = 1;
    
    self.controlToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(10, 10, 300, 40)];
//    self.controlToolbar.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    self.controlToolbar.barTintColor = [UIColor colorWithWhite:0.0 alpha:1.0];
//    self.controlToolbar.layer.cornerRadius = 5.0;
//    self.controlToolbar.layer.borderColor = UIColorFromRGB(0xEEEEEE).CGColor;
//    self.controlToolbar.layer.borderWidth = 1;

//    self.controlToolbar.backgroundColor = [UIColor clearColor];
//    self.controlToolbar.tintColor = [UIColor clearColor];
//    self.positionLabel.textColor = [UIColor whiteColor];
//    self.positionLabel.text = @"Position : ";
//    self.positionLabel.font = [UIFont fontWithName:@"Avenir Black" size:12];
    
//    [positionLabelView addSubview:self.controlToolbar];
    self.view = self.controlToolbar;
    
    self.view.exclusiveTouch = YES;
//    self.view.userInteractionEnabled = YES;
//    self set
    
    [self configureBarItems];
}




-(void) configureBarItems
{
    UIBarButtonItem* forwardItem = [[UIBarButtonItem alloc] initWithImage:[FontAwesome imageWithIcon:fa_angle_right size:24 color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(barItemTap:)];
    forwardItem.tag = defaultButtonActionOpenSelectedInCurrentTab;
    forwardItem.tintColor = UIColorFromRGB(0xAAAAAA);
    
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithImage:[FontAwesome imageWithIcon:fa_angle_left size:24 color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(barItemTap:)];
    backItem.tag = defaultButtonActionGoBackWithinTab;
    backItem.tintColor = UIColorFromRGB(0xAAAAAA);
    
    
    UIBarButtonItem* separatorItem = [[UIBarButtonItem alloc] initWithTitle:@"|" style:UIBarButtonItemStylePlain target:nil action:nil];
    separatorItem.tintColor = UIColorFromRGB(0x666666);
    
    UIBarButtonItem* tableItem = [[UIBarButtonItem alloc] initWithImage:[FontAwesome imageWithIcon:fa_external_link size:22 color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(barItemTap:)];
    tableItem.tag = defaultButtonActionOpenSelectedInCurrentTab;
    tableItem.tintColor = UIColorFromRGB(0xAAAAAA);
    

    
    UIBarButtonItem* fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedItem.width = 5.0f;
    
    
    
//    UIBarButtonItem* tableItem = [[UIBarButtonItem alloc] initWithImage:[FontAwesome imageWithIcon:fa_th size:24 color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(tableItemTap:)];
//    tableItem.tintColor = [UIColor whiteColor];
    
    
    UIBarButtonItem* flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    [self.controlToolbar setItems:@[backItem, fixedItem, forwardItem, flexItem,tableItem] animated:NO];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) barItemTap:(UIBarButtonItem*) theItem
{
    if ([self.delegate respondsToSelector:@selector(performAction:)]) {
        [self.delegate performAction:theItem.tag];
    }
}

@end
