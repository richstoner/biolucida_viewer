//
//  WSGLAccessoryViewController.m
//  Open
//
//  Created by Rich Stoner on 12/9/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "WSGLAccessoryViewController.h"

@interface WSGLAccessoryViewController ()

@end

@implementation WSGLAccessoryViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) updateWithObject:(wsRenderObject*) theObject
{
//    VerboseLog(@"%@", theObject.class);
}

-(void) updateLayoutForOrientation:(UIInterfaceOrientation) theOrientation
{
    VerboseLog();
}

-(void) updatePositionString:(NSString*) theString
{
//    VerboseLog();
}

@end
