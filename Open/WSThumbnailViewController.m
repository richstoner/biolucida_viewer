//
//  WSMBFControlsViewController.m
//  Open
//
//  Created by Rich Stoner on 10/30/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "WSThumbnailViewController.h"
#import <UIImageView+AFNetworking.h>
#import "wsRemoteImageObject.h"

#import "NYSliderPopover.h"


@interface WSThumbnailViewController ()
{
    CGPoint lastTranslate;
}


//@property(strong, nonatomic) UIToolbar* toolbar;
//@property (nonatomic, strong) NYSliderPopover *slider;

@property (nonatomic, assign) CGSize viewSize;
@property(nonatomic, strong) UIImageView* thumbnailImageView;
@property(nonatomic, strong) UIView*      thumbnailOverlay;

@end

@implementation WSThumbnailViewController

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
    self.view.clipsToBounds = NO;
    self.view.backgroundColor = kAccessoryBackgroundColor;
    
    self.viewSize = CGSizeMake(kThumbnailWidth, kThumbnailHeight);
    
    self.thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, self.viewSize.width, self.viewSize.height)];
    [self.thumbnailImageView setBackgroundColor:kAccessoryBackgroundColor];
    
//    [self.thumbnailImageView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
//    [self.thumbnailImageView.layer setBorderWidth:1];
    
    [self.thumbnailImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    self.thumbnailOverlay = [[UIView alloc] initWithFrame:CGRectZero];
    self.thumbnailOverlay.backgroundColor = [UIColor clearColor];
    self.thumbnailOverlay.alpha = 1.0f;
    
    [ self.thumbnailOverlay.layer setBorderColor:[[UIColor redColor] CGColor]];
    [ self.thumbnailOverlay.layer setBorderWidth:3.0];

    [self.thumbnailImageView addSubview:self.thumbnailOverlay];
    
    
    UITapGestureRecognizer* tapMapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMap:)];
    [tapMapGesture setNumberOfTapsRequired:1];
    [self.thumbnailImageView addGestureRecognizer:tapMapGesture];
    self.thumbnailImageView.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer* moveMapGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFrame:)];
    [self.thumbnailImageView addGestureRecognizer:moveMapGesture];

    [self.view addSubview:self.thumbnailImageView];
}



-(void) registerNotifications{
    VerboseLog();
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePosition:) name:kNotificationUpdatePosition object:nil];
    
}

-(void) unregisterNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (UIColor*) getBackgroundColorForImage:(UIImage*) theImage
{
    //    UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:theURL]];
    VerboseLog(@"%@", theImage);
    
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(theImage.CGImage));
    const u_int8_t* data = CFDataGetBytePtr(pixelData);
    
    int pixOO = 0;
    int pix11 = ((theImage.size.width  * theImage.size.height) * 4) - 4;
    
    u_int8_t red_0 = data[pixOO];
    u_int8_t green_0 = data[pixOO+1];
    u_int8_t blue_0 = data[pixOO+2];
    u_int8_t alpha_0 = data[pixOO+3];
    
    u_int8_t red_1 = data[pix11];
    u_int8_t green_1 = data[pix11+1];
    u_int8_t blue_1 = data[pix11+2];
    u_int8_t alpha_1 = data[pix11+3];
    CFRelease(pixelData);
    
    float red = (float)(red_0 + red_1) / 2.0;
    float green = (float)(green_0 + green_1) / 2.0;
    float blue = (float)(blue_0 + blue_1) / 2.0;
    float alpha = (float)(alpha_0 + alpha_1) / 2.0;
    
//    NSLog(@"%f %f %f", red, green, blue);
    
    UIColor* color = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha/255.0f]; // The pixel color info
    
    return color;
}


-(void) loadRenderObject:(wsRenderObject *)theRenderObject
{
    
    if ([theRenderObject isKindOfClass:[wsRemoteImageObject class]]) {
        
        wsRemoteImageObject* theImageObject = (wsRemoteImageObject*)theRenderObject;
        
        NSMutableURLRequest *thumbnailRequest = [NSMutableURLRequest requestWithURL:theImageObject.backgroundURL];
        
        [thumbnailRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        
        __weak WSThumbnailViewController *weakSelf = self;

        [self.self.thumbnailImageView setImageWithURLRequest:thumbnailRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            
            weakSelf.self.thumbnailImageView.backgroundColor = [weakSelf getBackgroundColorForImage:image];
            weakSelf.self.thumbnailImageView.image = image;

        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
            
            
        }];
        
        
        
    }
    
}

//
//- (void) configureForImage:(WSGenericTiledImage*) theImage;
//{
//    VerboseLog();
//    
//    
//    NSMutableURLRequest *thumbnailRequest = [NSMutableURLRequest requestWithURL:[theImage getThumbnailURL]];
//    [thumbnailRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
//    __weak WSThumbnailViewController *weakSelf = self;
//    
//    [self.self.thumbnailImageView setImageWithURLRequest:thumbnailRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//        
//        //        NSLog(@"Request finished");
//        weakSelf.self.thumbnailImageView.backgroundColor = [weakSelf getBackgroundColorForImage:image];
////        weakSelf.superview.backgroundColor = weakSelf.backgroundImageView.backgroundColor;
//        weakSelf.self.thumbnailImageView.image = image;
//        
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//        
//        
//        
//    }];
////    [self.thumbnailImageView setImageWithURL:[theImage getThumbnailURL]];
//    
//    
//    
//    
//
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - gesture methods

-(void) tapMap:(UITapGestureRecognizer*) gestureRecognizer
{
    CGPoint tapLocation = [gestureRecognizer locationInView:_thumbnailImageView];
    
    CGPointSub(tapLocation, lastTranslate);
    
    if ((self.thumbnailOverlay.frame.size.width <  self.viewSize.width/1.5) || (self.thumbnailOverlay.frame.size.height <  self.viewSize.height/1.5) ) {
        
        NSValue* toSend = [NSValue valueWithCGPoint:tapLocation];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAdjustTileView object:toSend];
    }
}

-(void) panFrame:(UIGestureRecognizer *) gesture {
    
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *) gesture;
    if (panGesture.state == UIGestureRecognizerStateBegan ) {
        lastTranslate = [panGesture locationInView:self.thumbnailImageView];
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged) {
        
        // only update after every displacement of 10
        
        CGPoint tapLocation = [panGesture locationInView:self.thumbnailImageView];
        CGPoint diff = CGPointSub(tapLocation, lastTranslate);
        
        CGFloat mag = CGPointMag(diff);
        int trigger = (int)round(mag) % 2;
        bool trig_b = trigger == 0;
//        NSLog(@"%f %d", mag, trigger);
        if (trig_b) {

            if ((self.thumbnailOverlay.frame.size.width <  self.viewSize.width/1.5) || (self.thumbnailOverlay.frame.size.height <  self.viewSize.height/1.5) ) {

                NSValue* toSend = [NSValue valueWithCGPoint:tapLocation];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAdjustTileView object:toSend];
            }
        }
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded)
    {
        CGPoint tapLocation = [panGesture locationInView:self.thumbnailImageView];
        
        if ((self.thumbnailOverlay.frame.size.width <  self.viewSize.width/1.5) || (self.thumbnailOverlay.frame.size.height <  self.viewSize.height/1.5) ) {
            
            NSValue* toSend = [NSValue valueWithCGPoint:tapLocation];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAdjustTileView object:toSend];
        }
    }
    
}

-(void) updatePosition:(NSNotification*) notification
{

    CGRect relRect = [(NSValue*)[notification object] CGRectValue];
    
    float rel_wf = (relRect.size.width* self.viewSize.width);
    float rel_hf = (relRect.size.height* self.viewSize.height);
    
    if ( rel_wf <  self.viewSize.width/2 || rel_hf <  self.viewSize.height/2 ) {
        self.thumbnailOverlay.alpha = 0.5;
    }
    else
    {
        self.thumbnailOverlay.alpha = 0.0;
    }
    
    if (rel_wf < 4) {
        rel_wf = 4.0f;
    }
    
    if (rel_hf < 4) {
        rel_hf = 4.0f;
    }
    
    [self.thumbnailOverlay setFrame:CGRectMake(0, 0, rel_wf,rel_hf)];
    [self.thumbnailOverlay setCenter:CGPointMake( self.viewSize.width/2 - relRect.origin.x* self.viewSize.width,  self.viewSize.height/2 - relRect.origin.y* self.viewSize.height )];
    
}



@end
