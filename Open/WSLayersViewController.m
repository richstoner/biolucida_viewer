//
//  WSLayersViewController.m
//  Open
//
//  Created by Rich Stoner on 8/29/14.
//  Copyright (c) 2014 WholeSlide. All rights reserved.
//

#import "WSLayersViewController.h"
#import <WebKit/WebKit.h>

@interface WSLayersViewController () <UIWebViewDelegate, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate>

@property(nonatomic, strong) wsDataObject* obj;

@property(nonatomic, strong) WKWebView* webView;

@end

@implementation WSLayersViewController

@synthesize webView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    if (!(self.webView)) {
        [self createWebkitview];
    }
    
//    self.webView.frame = self.view.frame;
    
//    UIWebView* webView = (UIWebView*)self.view;
//    
//    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    webView.delegate = self;
//    webView.backgroundColor = UIColorFromRGB(0x003399);
    //    [view addSubview:self.webView];
    
    [self.view addSubview:self.webView];
    
    NSMutableString* htmlString = [NSMutableString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"olviewer" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    [self.webView loadHTMLString:htmlString baseURL:baseURL];
    

}

-(void)createWebkitview {
    
    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];

    WKUserContentController* controller = [[WKUserContentController alloc] init];
    [controller addScriptMessageHandler:self name:@"callbackHandler"];
    
    config.userContentController = controller;
    
    self.webView = [[WKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds configuration:config];
//    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.allowsBackForwardNavigationGestures = NO;
    
    
    self.webView.backgroundColor = UIColorFromRGB(0x003399);
    
}

#pragma mark - WebKit delegate methods

//-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
//{
//    
//}

-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    VerboseLog(@"%@", message.body);
}


-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    VerboseLog(@"%@", navigation.request.URL.absoluteString);
    
    wsBiolucidaRemoteImageObject *img = (wsBiolucidaRemoteImageObject*)self.obj;

    
    [webView evaluateJavaScript:[NSString stringWithFormat:@"loadBiolucidaImage('%@', '%@')", img.url, img.url_id] completionHandler:^(id obj, NSError *err) {
       
        NSLog(@"JS completed: %@", err);
        
        if (err) {
            NSLog(@"%@", err.localizedDescription);
        }
        
        
        
    }];
    
//        NSString* str = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"loadBiolucidaImage('%@', '%@')", img.url, img.url_id]];
    //    NSLog(@"%@", str);
    

}

-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {

    VerboseLog(@"%@", navigation);
}



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

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    
    VerboseLog();
    //    NSString *result = [webView stringByEvaluatingJavaScriptFromString:function];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingTaskDidStartNotification object:nil];
    
}

-(void) webViewDidFinishLoad:(UIWebView *)webView
{

    VerboseLog("%@", self.obj);
    
    wsBiolucidaRemoteImageObject *img = (wsBiolucidaRemoteImageObject*)self.obj;
    
//    NSString* str = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"loadBiolucidaImage('%@', '%@')", img.url, img.url_id]];
//    NSLog(@"%@", str);
    
    //    [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingTaskDidFinishNotification object:nil];
    
}

-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    VerboseLog(@"%@", error.localizedDescription);
    //    [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingTaskDidFinishNotification object:nil];
}

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    VerboseLog();
    
    NSString *requestString = [[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    //NSLog(requestString);
    
    if ([requestString hasPrefix:@"ios-log:"]) {
        NSString* logString = [[requestString componentsSeparatedByString:@":#iOS#"] objectAtIndex:1];
        NSLog(@"UIWebView console: %@", logString);
        return NO;
    }
    
    
    
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
