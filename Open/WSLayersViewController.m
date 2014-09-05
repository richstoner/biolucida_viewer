//
//  WSLayersViewController.m
//  Open
//
//  Created by Rich Stoner on 8/29/14.
//  Copyright (c) 2014 WholeSlide. All rights reserved.
//

#import "WSLayersViewController.h"

@interface WSLayersViewController () <UIWebViewDelegate>

@property(nonatomic, strong) wsDataObject* obj;

@end

@implementation WSLayersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIWebView* webView = (UIWebView*)self.view;
    
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.delegate = self;
    webView.backgroundColor = UIColorFromRGB(0x003399);
    //    [view addSubview:self.webView];
    
    NSMutableString* htmlString = [NSMutableString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"olviewer" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    [webView loadHTMLString:htmlString baseURL:baseURL];
    
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
    //    NSString *result = [webView stringByEvaluatingJavaScriptFromString:function];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingTaskDidStartNotification object:nil];
    
}

-(void) webViewDidFinishLoad:(UIWebView *)webView
{
//    VerboseLog("%@", self.obj);
    
    wsBiolucidaRemoteImageObject *img = (wsBiolucidaRemoteImageObject*)self.obj;
    
    NSString* str = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"loadBiolucidaImage('%@', '%@')", img.url, img.url_id]];
    NSLog(@"%@", str);
    
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
