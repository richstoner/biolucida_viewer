//
//  WSZNavigationViewController.m
//  Open
//
//  Created by Rich Stoner on 12/2/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "WSZNavigationViewController.h"
#import "wsBiolucidaRemoteImageObject.h"

#import "NYSliderPopover.h"

@interface WSZNavigationViewController ()

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel* positionLabel;

@end

@implementation WSZNavigationViewController

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

    self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    self.view.backgroundColor = kAccessoryBackgroundColor;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) loadRenderObject:(wsRenderObject *)theRenderObject
{
    
    VerboseLog();

    if ([theRenderObject isKindOfClass:[wsBiolucidaRemoteImageObject class]]) {
        
        wsBiolucidaRemoteImageObject* theImage = (wsBiolucidaRemoteImageObject*)theRenderObject;
        
        NSLog(@"Image z index: %d", [theImage.z_index intValue]);
        NSLog(@"Image z max: %d", [theImage.z_max intValue]);
        
        self.positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        self.positionLabel.backgroundColor = kAccessoryBackgroundColor;
        self.positionLabel.textColor = [UIColor whiteColor];
        self.positionLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.positionLabel];
        
        self.slider = [[UISlider alloc] initWithFrame:CGRectMake(20 + -(kZNavHeight-30) / 2, 130, kZNavHeight-30, 60)];
        self.slider.clipsToBounds = NO;
        
        self.slider.maximumValue = [theImage.z_max floatValue];
        self.slider.minimumValue = [theImage.z_index floatValue];
        
        [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.slider addTarget:self action:@selector(setZ:) forControlEvents:UIControlEventTouchUpInside];
        [self.slider addTarget:self action:@selector(setZ:) forControlEvents:UIControlEventTouchUpOutside];

        CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI_2);
        self.slider.transform = trans;
        [self.view addSubview:self.slider];
    
        [self updateSliderPopoverText];
        
        self.view.layer.cornerRadius = 5.0;
        self.view.clipsToBounds = YES;
        
    }
    else
    {
        VerboseLog(@"Unsupported format for Z navigation");
    }
    
    
}

- (void) sliderValueChanged:(id)sender
{
    NSLog(@"%f", self.slider.value);
    
    self.positionLabel.text = [NSString stringWithFormat:@"%.0f", self.slider.value];
    
    NSNumber* sliderValue = [NSNumber numberWithFloat:round(self.slider.value)];

    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSetZ object:sliderValue];

    
//    [self updateSliderPopoverText];
    
    
}



- (void)updateSliderPopoverText
{
//    self.slider.popover.textLabel.text = [NSString stringWithFormat:@"%d", (int)round(self.slider.value)];
}



- (void) incrementZ:(id)sender {
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationIncreaseZ object:nil];
    
    if (self.slider.value < self.slider.maximumValue) {
        self.slider.value +=1;
    }
    
    
}

- (void) decrementZ:(id)sender {
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDecreaseZ object:nil];
    
    if (self.slider.value > self.slider.minimumValue) {
        self.slider.value -= 1;
    }
    
}

- (void) setZ:(id)sender {
    
//    NSNumber* sliderValue = [NSNumber numberWithFloat:round(self.slider.value)];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSetZ object:sliderValue];
    
}


- (void) tableItemTap:(id)sender{
    
    //    NSLog(@"%@", self.parentViewController);
    
    
    //    [self.parentViewController dismissViewControllerAnimated:NO completion:nil];
    
}


@end
