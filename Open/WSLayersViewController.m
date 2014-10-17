//
//  WSLayersViewController.m
//  Open
//
//  Created by Rich Stoner on 8/29/14.
//  Copyright (c) 2014 WholeSlide. All rights reserved.
//

#import "WSLayersViewController.h"

#import "wsBiolucidaRemoteImageObject.h"
#import "wsDataObject.h"
#import "wsObject.h"

//#import <WebKit/WebKit.h>



//@interface WSLayersViewController () <WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate>

@interface WSLayersViewController () <UIWebViewDelegate>





@property(nonatomic, strong) wsDataObject* obj;



//#if USE_WEBKITVIEW

/**
 
 */
//@property(nonatomic, strong) WKWebView* activeWebView;

//#else

/**
 
 */
@property(nonatomic, strong) UIWebView* activeWebView;

//#endif

@end

@implementation WSLayersViewController

/**
 
 */
@synthesize activeWebView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    if (!(self.activeWebView)) {
        [self createWebkitview];
    }
    
    [self.view addSubview:self.activeWebView];
    
    NSURL* html_path = [[NSBundle mainBundle] URLForResource:@"olviewer" withExtension:@"html" subdirectory:@"web"];
    NSString* htmlString = [NSString stringWithContentsOfURL:html_path encoding:NSUTF8StringEncoding error:nil];
    
    [self.activeWebView loadHTMLString:htmlString baseURL:[html_path URLByDeletingLastPathComponent]];

}

-(void)createWebkitview {
    
//#if USE_WEBKITVIEW

//    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
//
//    WKUserContentController* controller = [[WKUserContentController alloc] init];
//    [controller addScriptMessageHandler:self name:@"callbackHandler"];
//    config.userContentController = controller;
//    
//    self.activeWebView = [[WKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds configuration:config];
//    
//    self.activeWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    self.activeWebView.navigationDelegate = self;
//    self.activeWebView.UIDelegate = self;
//    self.activeWebView.allowsBackForwardNavigationGestures = NO;
//    
//    self.activeWebView.backgroundColor = kCollectionViewBackgroundColor;
    
//#else
    
    self.activeWebView = [[UIWebView alloc] initWithFrame:self.view.frame];
    self.activeWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.activeWebView.delegate = self;
    self.activeWebView.backgroundColor = kCollectionViewBackgroundColor;
    
}

//#endif

#pragma mark - WebKit delegate methods




//#if USE_WEBKITVIEW
//
//
//-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
//    VerboseLog(@"Message %@", message.body);
//}
//
//
//-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
//    
////    VerboseLog(@"%@", navigation.request.URL.absoluteString);
//    
//    [self performSelector:@selector(loadImageDelayed) withObject:nil afterDelay:10];
//}
//
//-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
//    VerboseLog(@"%@", navigation);
//}


//-(void) loadImageDelayed {
//    
//    wsBiolucidaRemoteImageObject *img = (wsBiolucidaRemoteImageObject*) self.obj;
//    
//    VerboseLog(@"%@", img.url);
//
//    NSString* new_url = [img.url.absoluteString stringByReplacingOccurrencesOfString:@"http://" withString:@"http://107.170.194.205:1234/"];
//    
//    [self.activeWebView evaluateJavaScript:[NSString stringWithFormat:@"loadBiolucidaImage('%@', '%@')", [NSURL URLWithString:new_url], img.url_id] completionHandler:^(id obj, NSError *err) {
//        
//        NSLog(@"JS completed: %@", obj);
//        
//        if (err) {
//            NSLog(@"Error: %@", err.localizedDescription);
//        }
//    }];
//
//    
//}


//#endif



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(wsObject*) getCurrentObject
{
    return self.obj;
}

- (void) updateWithObject:(wsDataObject*) theObject
{
    VerboseLog(@"Adding object to viewer");
    
    self.obj = theObject;
}


#pragma mark - webview delegate methods -

//#if !USE_WEBKITVIEW

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    
    VerboseLog();
//        NSString *result = [webView stringByEvaluatingJavaScriptFromString:function];
//        [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingTaskDidStartNotification object:nil];
    
}

-(void) webViewDidFinishLoad:(UIWebView *)webView
{
    VerboseLog("%@", self.obj);
    
    wsBiolucidaRemoteImageObject *img = (wsBiolucidaRemoteImageObject*)self.obj;
    
    
    
    NSString* str = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"loadBiolucidaImage('%@', '%@')", img.url, img.url_id]];
    VerboseLog(@"%@", str);
    
}

-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    VerboseLog(@"%@", error.localizedDescription);
}

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    VerboseLog(@"%@", request.URL.absoluteString);
    
    return YES;
}

//#endif

@end
