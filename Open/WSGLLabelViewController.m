//
//  WSGLLabelViewController.m
//  Open
//
//  Created by Rich Stoner on 12/9/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "WSGLLabelViewController.h"
//#import "wsEMVolumeObject.h"
#import <JVFloatLabeledTextField.h>

const static CGFloat kJVFieldHeight = 44.0f;
const static CGFloat kJVFieldHMargin = 20.0f;
const static CGFloat kJVFieldFontSize = 16.0f;
const static CGFloat kJVFieldFloatingLabelFontSize = 11.0f;



@interface WSGLLabelViewController ()

@property (strong, nonatomic)   UILabel* positionLabel;

@property(nonatomic, strong) UIImageView* previewThumbnail;

@property(nonatomic, strong) UIView* buttonView;
@property(nonatomic, strong) NSMutableArray* buttonList;


@property(nonatomic, strong) UILabel* primaryLabel;
@property(nonatomic, strong) UILabel* secondaryLabel;

@property(nonatomic, strong) JVFloatLabeledTextField* createDateLabel;
@property(nonatomic, strong) JVFloatLabeledTextField* typeLabel;

@property(nonatomic, strong) wsRenderObject* obj;

@property (nonatomic, strong) NSOperationQueue *thumbnailQueue;



@end

@implementation WSGLLabelViewController

@synthesize obj = _obj;
@synthesize previewThumbnail;
@synthesize buttonView;

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
        
        self.buttonList = [NSMutableArray new];
        
    }
    return self;
}


- (void)viewDidLoad
{
    self.thumbnailQueue = [[NSOperationQueue alloc] init];
    self.thumbnailQueue.maxConcurrentOperationCount = 3;

    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.frame = CGRectMake(self.view.frame.size.width - 200, 0, 200, 40);
    self.view.backgroundColor = kPreviewBackgroundColor;
    self.view.opaque = YES;
    
    //    UIView* positionLabelView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 200, 0, 200, 40)];
    //    positionLabelView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    //    positionLabelView.opaque = YES;

    CGFloat topOffset = 10;
    
    self.primaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, topOffset, self.view.frame.size.width-20, 15)];
    self.primaryLabel.backgroundColor = kPreviewBackgroundColor;
    self.primaryLabel.textColor = kPreviewHeaderFontColor;
    self.primaryLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    self.primaryLabel.text = _obj.localizedName;
    self.primaryLabel.text = @"Tap on an object to select";
    self.primaryLabel.font = kPreviewHeaderFont;
    [self.view addSubview:self.primaryLabel];
    
    topOffset += self.primaryLabel.frame.size.height + 5;
    
    self.secondaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, topOffset, self.view.frame.size.width-20, 15)];
    self.secondaryLabel.backgroundColor = kPreviewBackgroundColor;
    self.secondaryLabel.textColor = kPreviewDetailFontColor;
    self.secondaryLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    self.secondaryLabel.text = _obj.localizedDescription;
    self.secondaryLabel.font = kPreviewDetailFont;
    [self.view addSubview:self.secondaryLabel];
    
    topOffset += self.secondaryLabel.frame.size.height + 5;
    
    
    
    UIView *div1 = [UIView new];
    div1.frame = CGRectMake(20, topOffset,
                            260, 1.0f);
    div1.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div1];
    
    topOffset += div1.frame.size.height + 10;
    
    self.previewThumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(20, topOffset, 100, 100)];
    self.previewThumbnail.backgroundColor = UIColorFromRGB(0x000000);
    self.previewThumbnail.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.previewThumbnail.layer.borderWidth = 1.0f;
    self.previewThumbnail.layer.cornerRadius = 4.0;
    self.previewThumbnail.clipsToBounds = YES;
    [self setFontAwesomeIcon:fa_minus];
    [self.view addSubview:self.previewThumbnail];
    
    
//    NSString *dateString = [NSDateFormatter localizedStringFromDate:obj.createDate
//                                                          dateStyle:NSDateFormatterShortStyle
//                                                          timeStyle:NSDateFormatterShortStyle];
//    
    self.createDateLabel = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectMake(130, topOffset, 200, kJVFieldHeight)];
    self.createDateLabel.enabled = NO;
    self.createDateLabel.placeholder = @"Create Date";
    self.createDateLabel.textColor = kPreviewDetailFontColor;
    self.createDateLabel.backgroundColor = kPreviewBackgroundColor;
    self.createDateLabel.font = kPreviewDetailFont;
    self.createDateLabel.floatingLabel.font = kPreviewFloatingLabelFont;
    self.createDateLabel.floatingLabelTextColor = kPreviewFloatingLabelColor;
//    self.createDateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
//    self.createDateLabel.text = dateString;
    
    [self.view addSubview:self.createDateLabel];
    
    
    
    topOffset += self.createDateLabel.frame.size.height + 5;
    
    self.typeLabel = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectMake(130, topOffset, 200, kJVFieldHeight)];
    
    self.typeLabel.enabled = NO;
    self.typeLabel.placeholder = @"Type";
    self.typeLabel.textColor = kPreviewDetailFontColor;
    self.typeLabel.backgroundColor = kPreviewBackgroundColor;
    self.typeLabel.font = kPreviewDetailFont;
    self.typeLabel.floatingLabel.font = kPreviewFloatingLabelFont;
    self.typeLabel.floatingLabelTextColor = kPreviewFloatingLabelColor;
//    self.typeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//
//    self.typeLabel.text = NSStringFromClass(obj.class);
    
    [self.view addSubview:self.typeLabel];
    
    
    topOffset = self.previewThumbnail.frame.origin.y + 115;
    
    
//    
//    UIView *div2 = [UIView new];
//    div2.frame = CGRectMake(20, topOffset,
//                            260, 1.0f);
//    div2.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
//    [self.view addSubview:div2];
//    
//    topOffset += div2.frame.size.height + 10;
//    

//
//    self.positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, 280, 26)];
//    self.positionLabel.backgroundColor = [UIColor clearColor];
//    self.positionLabel.textColor = [UIColor whiteColor];
//
//    self.positionLabel.text = @"";
//    self.positionLabel.font = [UIFont fontWithName:@"Avenir Black" size:12];
//
//    [positionLabelView addSubview:self.positionLabel];
//    self.view = positionLabelView;
    
    [self addButtonView];

}

-(void) addButtonView
{
    
    self.buttonView = [[UIView alloc] initWithFrame:CGRectMake(300, 0, 168, k3DToolBarHeight)];
    self.buttonView.backgroundColor = [UIColor colorWithWhite:0.08 alpha:1.0];

    
    
    [self.view addSubview:self.buttonView];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) updateWithObject:(wsRenderObject*) theObject
{
//    VerboseLog();
    
    self.obj = theObject;
    
    if([self.obj respondsToSelector:@selector(thumbnailURL)])
    {
        __weak WSGLLabelViewController *weakSelf = self;
        
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{

                    [weakSelf.previewThumbnail setImageWithURL:[self.obj performSelector:@selector(thumbnailURL)]];
                });
        }];
        
        [self.thumbnailQueue addOperation:operation];
    }
    
    if(self.obj.localIconString != nil)
    {
        [self.previewThumbnail setImage:[UIImage imageNamed:self.obj.localIconString]];
        
    }
    else if (self.obj.fontAwesomeIconString != nil)
    {
        [self setFontAwesomeIcon:self.obj.fontAwesomeIconString];
    }
    else
    {
        [self setFontAwesomeIcon:fa_minus];
    }
    
    if (theObject) {
        self.primaryLabel.text = self.obj.localizedName;
        self.secondaryLabel.text = self.obj.localizedDescription;
        NSString *dateString = [NSDateFormatter localizedStringFromDate:self.obj.createDate
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterShortStyle];
        
        self.createDateLabel.text = dateString;
        self.typeLabel.text = NSStringFromClass(self.obj.class);

    }
    else
    {
        self.primaryLabel.text = @"Tap on an object to select";
        self.secondaryLabel.text = @"";
        self.createDateLabel.text = @"";
        self.typeLabel.text = @"";
    }
    
    // redo this later
    
    [self clearButtonList];

    
    CGFloat buttonOffset = 10;
    int tag_cache= 0;

    {
        UIButton* openCube = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [openCube setTitle:@"Select next" forState:UIControlStateNormal];
        openCube.frame = CGRectMake(10, buttonOffset, self.buttonView.frame.size.width - 20, 35);
        openCube.tintColor = kDURABlue;
        [openCube addTarget:self action:@selector(performSelectNext:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.buttonView addSubview:openCube];
        [self.buttonList addObject:openCube];
    }
    
        buttonOffset += 35 + 10;

    
    if (self.obj.actions.count > 0 ) {
        
        
        for (wsActionObject* ao in self.obj.actions) {

            
            
            UIButton* openCube = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [openCube setTitle:ao.localizedName forState:UIControlStateNormal];
            openCube.frame = CGRectMake(10, buttonOffset, self.buttonView.frame.size.width - 20, 35);
            openCube.tintColor = kDURABlue;
            openCube.tag = tag_cache++;
            [openCube addTarget:self action:@selector(performObjectAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.buttonView addSubview:openCube];
            [self.buttonList addObject:openCube];
            
            buttonOffset += 35 + 10;            
            
        }
        
    }

    
}

-(void) performObjectAction:(UIButton*) sender
{
//    VerboseLog();
    wsActionObject* ao = self.obj.actions[sender.tag];
    
    if (ao) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ao.notificationString object:nil];
        
    }
}

-(void) performSelectNext:(UIButton*) sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSelectNext object:nil];
    
}


-(void) clearButtonList
{
//    VerboseLog();
    
    for (UIButton* button in self.buttonList) {
        [button removeFromSuperview];
    }
    
    [self.buttonList removeAllObjects];
    
}

- (void) setFontAwesomeIcon:(NSString*) fontAwesomeString
{
    if (IS_IPAD) {
        
        self.previewThumbnail.image = [FontAwesome imageWithIcon:fontAwesomeString iconColor:[UIColor whiteColor] iconSize:36 imageSize:CGSizeMake(self.previewThumbnail.frame.size.width, self.previewThumbnail.frame.size.height )];
        
    }
    else{
        self.previewThumbnail.image = [FontAwesome imageWithIcon:fontAwesomeString iconColor:[UIColor whiteColor] iconSize:14 imageSize:CGSizeMake(self.previewThumbnail.frame.size.width, self.previewThumbnail.frame.size.height )];
    }
    
    
}

-(void) updateLayoutForOrientation:(UIInterfaceOrientation) theOrientation
{

    if (UIInterfaceOrientationIsPortrait(theOrientation)) {

        self.view.frame = CGRectMake(0, self.view.superview.frame.size.height - k3DToolBarHeight, self.view.superview.frame.size.width-k3DToolBarWidth, k3DToolBarHeight);
        
        self.buttonView.frame = CGRectMake(300, 0, 168, k3DToolBarHeight);
        
    }
    else{
        
        self.view.frame = CGRectMake(self.view.superview.frame.size.width - k3DToolBarWidth, 0, k3DToolBarWidth, self.view.superview.frame.size.height-k3DToolBarHeight);
        
        self.buttonView.frame = CGRectMake(0, 200, 300, k3DToolBarHeight);
    }
}



@end
