//////////////////////////////////////////////////////////////////////////////////////
//
//    This software is Copyright © 2013 WholeSlide, Inc. All Rights Reserved.
//
//    Permission to copy, modify, and distribute this software and its documentation
//    for educational, research and non-profit purposes, without fee, and without a
//    written agreement is hereby granted, provided that the above copyright notice,
//    this paragraph and the following three paragraphs appear in all copies.
//
//    Permission to make commercial use of this software may be obtained by contacting:
//
//    Rich Stoner, WholeSlide, Inc
//    8070 La Jolla Shores Dr, #410
//    La Jolla, CA 92037
//    stoner@wholeslide.com
//
//    This software program and documentation are copyrighted by WholeSlide, Inc. The
//    software program and documentation are supplied "as is", without any
//    accompanying services from WholeSlide, Inc. WholeSlide, Inc does not warrant
//    that the operation of the program will be uninterrupted or error-free. The
//    end-user understands that the program was developed for research purposes and is
//    advised not to rely exclusively on the program for any reason.
//
//    IN NO EVENT SHALL WHOLESLIDE, INC BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT,
//    SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING
//    OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF WHOLESLIDE,INC
//    HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. WHOLESLIDE,INCSPECIFICALLY
//    DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED
//    HEREUNDER IS ON AN "AS IS" BASIS, AND WHOLESLIDE,INC HAS NO OBLIGATIONS TO
//    PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS UNLESS
//    OTHERWISE STATED.
//
//////////////////////////////////////////////////////////////////////////////////////
//
//  WSAddNewLocationViewController.m
//  Open
//
//  Created by Rich Stoner on 11/4/13.
//


#import "WSAddNewLocationViewController.h"
#import <JVFloatLabeledTextField.h>
#import "wsBiolucidaServerObject.h"
#import <BButton.h>

const static CGFloat kJVFieldHeight = 44.0f;
const static CGFloat kJVFieldHMargin = 20.0f;
const static CGFloat kJVFieldFontSize = 16.0f;
const static CGFloat kJVFieldFloatingLabelFontSize = 11.0f;


@interface WSAddNewLocationViewController () <UITextFieldDelegate>

@property(nonatomic, strong) UIActivityIndicatorView* activityIndicator;
@property(nonatomic, strong) UILabel* lastTestLabel;
@property(nonatomic, assign) BOOL hasValidSite;
@property(nonatomic, strong) wsServerObject* objectToAdd;


@property(nonatomic, strong) JVFloatLabeledTextField* titleField;
@property(nonatomic, strong) JVFloatLabeledTextField* urlField;
@property(nonatomic, strong) BButton* addButton;


@end



@implementation WSAddNewLocationViewController

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
    
    self.view.backgroundColor = kPreviewBackgroundColor;
    self.view.autoresizingMask = UIViewAutoresizingNone;
    self.view.frame = CGRectMake(0, 0, 300, 320);
    
    
//    self.view.backgroundColor = [UIColor clearColor];
//    self.view.superview.backgroundColor = [UIColor clearColor];
    
//    self.imageBackgroundView = [UIImageView new];
//    self.imageBackgroundView.frame = self.view.frame;
//    self.imageBackgroundView.backgroundColor = [UIColor clearColor];
//    backgroundView.alpha = 0.5;
    
//    [self.view addSubview:self.imageBackgroundView];
    
//    self.contentView = [UIView new];
//    self.contentView.frame = CGRectMake(0, 0, 320,320);
//    self.contentView.backgroundColor = kColorCollectionItemBackground;
//    self.contentView.center = CGPointMake(self.view.center.x, self.contentView.center.y);
//    self.contentView.center = self.view.center;

    self.view.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.view.layer.borderWidth = 1.0f;
//    self.contentView.layer.cornerRadius = 4.0;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityIndicator.hidesWhenStopped= YES;
    self.activityIndicator.frame = CGRectMake(4, 4, 20, 20);
    [self.view addSubview:self.activityIndicator];
    
    CGFloat topOffset = [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height;
    
    topOffset += 15;
    
    self.lastTestLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, topOffset, 260, 35)];
    self.lastTestLabel.numberOfLines = 1;
    self.lastTestLabel.textAlignment = NSTextAlignmentCenter;
    self.lastTestLabel.textColor = kPreviewDetailFontColor;
    self.lastTestLabel.text = @"To add a new server, enter the URL below";
    self.lastTestLabel.font = kPreviewDetailFont;
    
    [self.view addSubview:self.lastTestLabel];
    
    topOffset += self.lastTestLabel.frame.size.height + 15;
    
    
    JVFloatLabeledTextField *urlField = [[JVFloatLabeledTextField alloc] initWithFrame:
                                         CGRectMake(kJVFieldHMargin, topOffset, self.view.frame.size.width - 40, kJVFieldHeight)];
    
    
    if ([urlField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor lightGrayColor];
        urlField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"URL", @"") attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
    
    
    urlField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    urlField.autocorrectionType = UITextAutocorrectionTypeNo;
    urlField.delegate = self;
    urlField.font = kAddItemFont;
    urlField.keyboardAppearance = UIKeyboardAppearanceDark;
    urlField.placeholder = NSLocalizedString(@"URL", @"");
    urlField.textColor = kAddItemFontColor;
    urlField.tintColor = kAddItemTintColor;
    
    urlField.floatingLabel.font = kAddItemFloatingLabelFont;
    urlField.floatingLabelTextColor = kAddItemFloatingLabelColor;
    
    self.urlField = urlField;
    [self.view addSubview:urlField];
    

    topOffset += urlField.frame.size.height + 15;

    UIView *div1 = [UIView new];
    div1.frame = CGRectMake(kJVFieldHMargin, topOffset,
                            260, 1.0f);
    div1.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div1];
    
    
    topOffset += div1.frame.size.height + 15;
    
    
    JVFloatLabeledTextField *titleField = [[JVFloatLabeledTextField alloc] initWithFrame:
                                           CGRectMake(kJVFieldHMargin, topOffset, self.view.frame.size.width - 2 * kJVFieldHMargin, kJVFieldHeight)];
    
    if ([titleField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor lightGrayColor];
        titleField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Server name", @"") attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }

    titleField.autocorrectionType = UITextAutocorrectionTypeNo;
    titleField.clearButtonMode = UITextFieldViewModeWhileEditing;
    titleField.delegate = self;
    titleField.font = kAddItemFont;
    titleField.keyboardAppearance = UIKeyboardAppearanceDark;
    titleField.placeholder = NSLocalizedString(@"Server name", @"");
    titleField.textColor = kAddItemFontColor;
    titleField.tintColor = kAddItemTintColor;


    titleField.floatingLabel.font = kAddItemFloatingLabelFont;
    titleField.floatingLabelTextColor = kAddItemFloatingLabelColor;
    
    self.titleField = titleField;
    
    [self.view addSubview:titleField];

    topOffset += titleField.frame.size.height + 15;

    UIView *div2 = [UIView new];
    div2.frame = CGRectMake(kJVFieldHMargin, topOffset,
                            260, 1.0f);
    div2.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div2];
    
    topOffset += div2.frame.size.height + 30;

    
    self.addButton = [[BButton alloc] initWithFrame:CGRectMake(20, topOffset, 260, 44)
                                                   type:BButtonTypeSuccess
                                                  style:BButtonStyleBootstrapV3];
    
    [self.addButton setTitle:@"Add Server" forState:UIControlStateNormal];
    self.addButton.titleLabel.font = kAddItemFont;
    self.addButton.enabled = NO;
    [self.addButton addTarget:self action:@selector(addURL:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addButton];
    
    [urlField becomeFirstResponder];
}


- (void) testURL:(id) sender
{
    NSURL* baseURL = [NSURL URLWithString:[self.urlField.text lowercaseString]];
    
    if (baseURL.scheme && baseURL.host) {
        
        [self validateURL:baseURL];
    
    }
    else {
        
        NSURL* httpURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", [self.urlField.text lowercaseString]]];
        
        [self validateURL:httpURL];
    }
//    else {
//        self.lastTestLabel.text = @"Invalid url";
//    }
}

-(void) validateURL:(NSURL*) baseURL {
    
    [self.activityIndicator startAnimating];
    
    NSURL* testURL = [baseURL URLByAppendingPathComponent:@"api/v1/server"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:testURL.absoluteString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary* responseDict = (NSDictionary*)responseObject;
        
        self.lastTestLabel.text = @"Valid MBF server √";
        
        self.objectToAdd = [wsBiolucidaServerObject new];
        self.objectToAdd.description = responseDict[@"description"];
        self.objectToAdd.url = baseURL;
        
        self.hasValidSite = YES;
        [self.titleField becomeFirstResponder];
        
        [self.activityIndicator stopAnimating];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        self.lastTestLabel.text =@"Not a valid server type";
        [self.activityIndicator stopAnimating];
        
    }];
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    // Find the next entry field
//    if ([textField isEqual:self.urlField]) {
//        
//        if (self.urlField.text.length == 0) {
//            self.urlField.text = @"http://173.9.92.122";
//        }
//        else{
//            
//            [self testURL:nil];
//            
//        }
//        
//        return YES;
//    }else
    
    if([textField isEqual:self.titleField]){
        
        if (self.titleField.text.length == 0) {
            self.titleField.text = @"MBF @ 173.9.92.122";
            
            if (self.hasValidSite) {
                
                self.objectToAdd.title = self.titleField.text;
                self.addButton.enabled = YES;
            }
        }
        else{
            
            [self addURL:nil];
            
        }
    }
    
    return NO;
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.titleField]) {
        
        [self testURL:nil];
        
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([textField isEqual:self.titleField]){
        self.addButton.enabled = (self.titleField.text.length > 0 && self.hasValidSite);
    }
    
    return YES;
}



- (void) addURL:(id)sender {

    
    if (self.hasValidSite)
    {
        
        self.objectToAdd.title = self.titleField.text;
        
        NSLog(@"adding server to %@", self.sourceObject);
        
        NSDictionary* msg = @{@"source": self.sourceObject,
                              @"object": self.objectToAdd};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAddObjectSuccess object:msg];
        
        
    }
    else {
        
        self.lastTestLabel.text = @"Please check the url first.";
        
    }
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
