//
//  wsPreviewFrameViewController.m
//  Open
//
//  Created by Rich Stoner on 1/3/14.
//  Copyright (c) 2014 WholeSlide. All rights reserved.
//

#import "wsPreviewFrameViewController.h"

#import <JVFloatLabeledTextField.h>
#import "wsBiolucidaServerObject.h"
#import <BButton.h>

const static CGFloat kJVFieldHeight = 44.0f;
const static CGFloat kJVFieldHMargin = 20.0f;
const static CGFloat kJVFieldFontSize = 16.0f;
const static CGFloat kJVFieldFloatingLabelFontSize = 11.0f;



@interface wsPreviewFrameViewController () <UIWebViewDelegate>

/**
 
 */
@property(nonatomic, strong) UIImageView* previewThumbnail;
@property (nonatomic, strong) NSOperationQueue *thumbnailQueue;

/**
 
 */
@property(nonatomic, strong) UILabel* primaryLabel;

/**
 
 */
@property(nonatomic, strong) UILabel* secondaryLabel;

/**
 
 */
@property (nonatomic, strong) UIToolbar* defaultActions;


/**
 
 */
@property(nonatomic, strong) UIWebView* metadataView;



/**
 
 */
@property(nonatomic, strong) NSMutableDictionary* objectActions;

@property(nonatomic, strong) UIView* objectActionView;

@property(nonatomic, readonly) NSString* currentUsername;
@property(nonatomic, readonly) NSString* currentPassword;




@property(nonatomic, strong) UILabel* statusLabel;

@end


#define CollectionToolBarHeight 40

@implementation wsPreviewFrameViewController

@synthesize obj;

- (id)init
{
    self = [super init];
    if (self) {
        
        self.thumbnailQueue = [[NSOperationQueue alloc] init];
        self.thumbnailQueue.maxConcurrentOperationCount = 3;
        self.objectActions = [NSMutableDictionary new];
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
    }
    return self;
}

#pragma mark - Notifications and methods -

-(void) registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:kNotificationServerLoginSuccess object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailed:) name:kNotificationServerLoginFailed object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginMissingValues:) name:kNotificationServerLoginMissingValues object:nil];

}

-(void) unregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void) loginSuccess:(NSNotification*) notification
{
    self.statusLabel.text = @"Login successful, saving credentials.";
}

-(void) loginFailed:(NSNotification*) notification
{
    self.statusLabel.text = @"Login failed.";
}

-(void) loginMissingValues:(NSNotification*) notification
{
    self.statusLabel.text = @"Missing a value, check entries.";
}



#define leftColumnWidth 250
#define previewPad 20
#define itemSpacing 15
#define rightColumnOrigin 290



-(JVFloatLabeledTextField*) createTextLabelWithFrame:(CGRect) theFrame withKey:(NSString*) theKey
{
    
    JVFloatLabeledTextField* textField =[[JVFloatLabeledTextField alloc] initWithFrame:theFrame];
    
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.placeholder = theKey;
    textField.textColor = kPreviewDetailFontColor;
    textField.backgroundColor = kPreviewBackgroundColor;
    textField.font = kPreviewDetailFont;
    textField.floatingLabel.font = kPreviewFloatingLabelFont;
    
    CGRect newFrame = textField.floatingLabel.frame;
    newFrame.size.width = theFrame.size.width - 20;
    
    textField.floatingLabel.frame = newFrame;
    textField.floatingLabel.textColor = kPreviewFloatingLabelColor;
    
    return textField;
    
}

-(JVFloatLabeledTextField*) createPasswordLabelWithFrame:(CGRect) theFrame withKey:(NSString*) theKey
{
    JVFloatLabeledTextField* passwordField = [self createTextLabelWithFrame:theFrame withKey:theKey];
    passwordField.secureTextEntry = YES;
    
    return passwordField;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    wsObject* _obj = self.obj;
    
    self.view.backgroundColor = kPreviewBackgroundColor;
    self.view.frame = CGRectMake(0, 0, 700, 620);
    self.view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.view.layer.borderWidth = 1.0f;
    self.view.autoresizingMask = UIViewAutoresizingNone;    
    
    CGFloat topOffset = previewPad;
    
    self.metadataView = [[UIWebView alloc] initWithFrame:CGRectMake(rightColumnOrigin, topOffset, self.view.frame.size.width - rightColumnOrigin - previewPad, 550)];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    self.metadataView.opaque = NO;
    self.metadataView.backgroundColor = UIColorFromRGB(0x111111);

//    self.metadataView.delegate =self;
    self.metadataView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.metadataView.layer.borderWidth = 1.0f;
    self.metadataView.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self.metadataView loadHTMLString:[WSMetaDataStore metadataStringForObject:self.obj] baseURL:baseURL];
    
    [self.view addSubview:self.metadataView];
    
    self.primaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(previewPad, topOffset, leftColumnWidth, 15)];
    self.primaryLabel.backgroundColor = kPreviewBackgroundColor;
    self.primaryLabel.textColor = kPreviewHeaderFontColor;
    self.primaryLabel.text = _obj.localizedName;
    self.primaryLabel.font = kPreviewHeaderFont;
    [self.view addSubview:self.primaryLabel];
    
    topOffset += self.primaryLabel.frame.size.height + 5;
    
    self.secondaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(previewPad, topOffset, leftColumnWidth, 15)];
    self.secondaryLabel.backgroundColor = kPreviewBackgroundColor;
    self.secondaryLabel.textColor = kPreviewDetailFontColor;
    self.secondaryLabel.text = _obj.localizedDescription;
    self.secondaryLabel.font = kPreviewDetailFont;
    [self.view addSubview:self.secondaryLabel];
    
    topOffset += self.secondaryLabel.frame.size.height + 15;
    
    
    self.previewThumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(previewPad, topOffset, leftColumnWidth, leftColumnWidth)];
    self.previewThumbnail.backgroundColor = UIColorFromRGB(0x222222);
    self.previewThumbnail.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.previewThumbnail.layer.borderWidth = 1.0f;
    self.previewThumbnail.contentMode = UIViewContentModeScaleAspectFit;
    self.previewThumbnail.layer.cornerRadius = 2.0;
    
    self.previewThumbnail.clipsToBounds = YES;
    [self.view addSubview:self.previewThumbnail];
    
    topOffset = self.previewThumbnail.frame.origin.y + self.previewThumbnail.frame.size.height + itemSpacing;

    
    self.objectActionView = [[UIView alloc] initWithFrame:CGRectMake(previewPad, topOffset, leftColumnWidth, 200)];
    self.objectActionView.backgroundColor = kPreviewBackgroundColor;
    self.objectActionView.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:self.objectActionView];
    
    
    CGFloat innerOffset = 5;

    
    
    if ([self.obj respondsToSelector:@selector(username)]) {
        
        
        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, innerOffset, leftColumnWidth-10, 20)];
        self.statusLabel.numberOfLines = 1;
        self.statusLabel.textAlignment = NSTextAlignmentLeft;
        self.statusLabel.textColor = kPreviewDetailFontColor;
        self.statusLabel.text = @"Server credentials";
        self.statusLabel.font = kPreviewDetailFont;
        
        [self.objectActionView addSubview:self.statusLabel];
        
        innerOffset += self.statusLabel.frame.size.height + 5;
        
        JVFloatLabeledTextField* usernameField = [self createTextLabelWithFrame:CGRectMake(5, innerOffset, leftColumnWidth-10, kJVFieldHeight) withKey:@"Username"];

       usernameField.text = [self.obj performSelector:@selector(username)];
        
        [self.objectActionView addSubview:usernameField];
        [self.objectActions setObject:usernameField forKey:@"usernameField"];
        
        innerOffset += usernameField.frame.size.height;
        
    }
    
    if ([self.obj respondsToSelector:@selector(password)]) {
        
        JVFloatLabeledTextField* passwordField = [self createPasswordLabelWithFrame:CGRectMake(5, innerOffset, leftColumnWidth-10, kJVFieldHeight) withKey:@"Password"];
        passwordField.text = [self.obj performSelector:@selector(password)];
        
        [self.objectActionView addSubview:passwordField];
        [self.objectActions setObject:passwordField forKey:@"passwordField"];
        
        innerOffset += passwordField.frame.size.height + 10;
        
        UIButton* testCredentials = [UIButton buttonWithType:UIButtonTypeCustom];
        testCredentials.frame = CGRectMake(5, innerOffset, leftColumnWidth - 10, kJVFieldHeight);
        [testCredentials setTitle:@"Login" forState:UIControlStateNormal];
        [testCredentials setTitleColor:kPreviewActionFontColor forState:UIControlStateNormal];
        testCredentials.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [testCredentials addTarget:self action:@selector(testLogin:) forControlEvents:UIControlEventTouchUpInside];

        [self.objectActionView addSubview:testCredentials];
        
    }

    [self setThumbnailImage];
    

    [self createDefaultActionsViewContainer];
    [self updateActionsView];


}


-(void) setThumbnailImage
{
    wsObject* _obj = self.obj;
    
    if ([_obj isKindOfClass:[wsServerObject class]]) {
        
        wsServerObject* so = (wsServerObject*)_obj;
        
        if (so.localIconString != nil) {
            // use icon string for representation
            [self.previewThumbnail setImage:[UIImage imageNamed:so.localIconString]];
        }
        else{
            // i could do a default image here if needed.
        }
        
    }
    
    
    if ([_obj isKindOfClass:[wsSystemObject class]]) {
        
        wsSystemObject* so = (wsSystemObject*)_obj;
        
        if (so.localIconString != nil) {
            // use icon string for representation
            [self.previewThumbnail setImage:[UIImage imageNamed:so.localIconString]];
            
        } else if (so.fontAwesomeIconString != nil) {
            [self setFontAwesomeIcon:so.fontAwesomeIconString];
            
        }
        else{
            // i could do a default image here if needed.
        }
    }
    
    
    
    // if it has a thumbnail url, then use that
    if([_obj respondsToSelector:@selector(thumbnailURL)])
    {
        
        // load photo images in the background
        __weak wsPreviewFrameViewController *weakSelf = self;
        
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //                wsImageObject* io = (wsImageObject*) _obj;
                [weakSelf.previewThumbnail setImageWithURL:[obj performSelector:@selector(thumbnailURL)]];
                
            });
        }];
        
        
        [self.thumbnailQueue addOperation:operation];
    }
    
    
}


-(void) createDefaultActionsViewContainer
{
    
#if ToolBarOnTop
    
    self.defaultActions = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CollectionToolBarHeight)];
    
#else
    
    self.defaultActions = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - CollectionToolBarHeight - 5, self.view.frame.size.width, CollectionToolBarHeight)];
    
#endif
    self.defaultActions.translucent = NO;
    self.defaultActions.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.defaultActions.barTintColor = kHistoryBackgroundColor;
    [self.view addSubview:self.defaultActions ];
}

-(void) updateActionsView
{
    if (self.defaultActions) {
        
        NSMutableArray* items = [NSMutableArray new];
        
        
        [[UIBarButtonItem appearance] setTitleTextAttributes:
         @{NSFontAttributeName: kPreviewDetailFont,
           NSBackgroundColorAttributeName: kHistoryBackgroundColor}
                                                    forState:UIControlStateNormal];
        
        [[UIBarButtonItem appearance] setTitlePositionAdjustment:UIOffsetMake(0.0f, 5.0f) forBarMetrics:UIBarMetricsDefault];


        NSArray* defaultAcitons = @[@"Delete", @"Save", @"", @"Open"];
        
        int i=0;
        for (NSString* str in defaultAcitons) {

        
            if ([str isEqualToString:@""]) {
                
                UIBarButtonItem * flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
                
                [items addObject:flexSpace];
                
                
            }
            else
            {
                
                UIBarButtonItem* historyItem = [[UIBarButtonItem alloc] initWithTitle:str style:UIBarButtonItemStylePlain target:self action:@selector(performAction:)];
                
                historyItem.tintColor = kPreviewActionFontColor;
                historyItem.style= UIBarButtonItemStyleBordered;

                historyItem.width = 75;
                historyItem.tag = i++;
                [items addObject:historyItem];
                
                UIBarButtonItem * divider = [[UIBarButtonItem alloc] initWithTitle:@"|" style:UIBarButtonItemStylePlain target:nil action:nil];
                divider.tintColor = kPreviewActionSpacerColor;
                [items addObject:divider];
                
            }
        
        }
        
        [self.defaultActions setItems:items animated:YES];
        
    }
}


-(void) performAction:(UIBarButtonItem*) item
{
    int actionTag = item.tag;
    
    switch (actionTag) {
        case 0:
            
            
            [self removeObjectFromSource];
            
//
            
            break;
        case 1:
            
#if ISMBF
            [[WSMetaDataStore sharedDataStore] addObjectToStarList:self.obj];
            
#else
      
            [[WSMetaDataStore sharedDataStore] saveObjectToDocumentsDirectory:self.obj];
            
#endif
            
      
            
            break;
            
        case 2:

            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOpenObject object:self.obj];

            
            
            break;
            
        default:
            break;
    }
    
}


-(void) openObject:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOpenObject object:self.obj];
}


-(void) removeObjectFromSource
{
    
    
    NSDictionary* msg = @{@"source": self.sourceObject,
                          @"object": self.obj};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRemoveObject object:msg];
}



-(NSString*) currentPassword
{
    JVFloatLabeledTextField* tf = self.objectActions[@"passwordField"];
    
    if (tf.text) {
        return tf.text;
    }
    
    return @"";
}

-(NSString*) currentUsername
{
    JVFloatLabeledTextField* tf = self.objectActions[@"usernameField"];
    if (tf.text) {
        return tf.text;
    }
    
    return @"";
}

-(void) testLogin:(id)sender
{
    if ([self.obj respondsToSelector:@selector(loginWithCredentials:)]) {
        
        NSString* currentUsername = self.currentUsername;
        NSString* currentPassword = self.currentPassword;
        
        if (currentUsername && currentPassword) {

            NSDictionary* testCredentials = @{@"username": self.currentUsername,
                                              @"password": self.currentPassword};
            
            [self.obj performSelector:@selector(loginWithCredentials:) withObject:testCredentials];
        }
        else
        {
            NSLog(@"error");
        }
    }
    else
    {
        VerboseLog(@"Object doesn't support login");
    }
}


- (void) setFontAwesomeIcon:(NSString*) fontAwesomeString
{
    if (IS_IPAD) {
        
        self.previewThumbnail.image = [FontAwesome imageWithIcon:fontAwesomeString iconColor:UIColorFromRGB(0xffffff) iconSize:144 imageSize:CGSizeMake(self.previewThumbnail.frame.size.width, self.previewThumbnail.frame.size.height )];
        
    }
    else{
        self.previewThumbnail.image = [FontAwesome imageWithIcon:fontAwesomeString iconColor:UIColorFromRGB(0xffffff) iconSize:14 imageSize:CGSizeMake(self.previewThumbnail.frame.size.width, self.previewThumbnail.frame.size.height )];
    }
    
    
}


//
//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    
//    [webView.scrollView setContentSize: CGSizeMake(webView.frame.size.width, webView.scrollView.contentSize.height)];
//    
//}
//
//-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//{
//    return YES;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
