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
//
//  WSBrowserTabViewController.m
//  Open
//
//  Created by Rich Stoner on 10/27/13.
//

#import "WSBrowserTabViewController.h"

#import "wsWebServerObject.h"
#import "wsWebPageObject.h"

@interface WSBrowserTabViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;

@property(nonatomic, strong) wsDataObject* obj;

@end



@implementation WSBrowserTabViewController

@synthesize obj;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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



- (void)viewDidLoad
{
    VerboseLog();
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.webView.delegate = self;
    
    [self.view addSubview:self.webView];
    
    if ([self.obj isKindOfClass:[wsWebPageObject class]]) {
        
        wsWebPageObject* wpo = (wsWebPageObject*)self.obj;
        
        // check if valid url present, then load
        if(wpo.url)
        {
            [self.webView loadRequest:[NSURLRequest requestWithURL:wpo.url]];
        }
        else
        {
         
            // else try to load it's associated local file
            
            NSMutableString* htmlString = [NSMutableString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:wpo.basePath ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
            NSString *path = [[NSBundle mainBundle] bundlePath];
            NSURL *baseURL = [NSURL fileURLWithPath:path];
            
            [self.webView loadHTMLString:htmlString baseURL:baseURL];
            
        }
        
        
    }
    else if ([self.obj isKindOfClass:[wsWebServerObject class]]) {
        
        wsWebServerObject* wpo = (wsWebServerObject*)self.obj;
        
        if(wpo.url)
        {
            [self.webView loadRequest:[NSURLRequest requestWithURL:wpo.url]];
        }
        else
        {
            [self.webView loadHTMLString:@"Invalid server URL" baseURL:nil];

        }

    }
    else
    {
        
        if (self.obj.helpPage)
        {
            
            NSMutableString* htmlString = [NSMutableString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.obj.helpPage ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
            NSString *path = [[NSBundle mainBundle] bundlePath];
            NSURL *baseURL = [NSURL fileURLWithPath:path];
            
            
            [self.webView loadHTMLString:htmlString baseURL:baseURL];
        }
        else
        {
            NSString *path = [[NSBundle mainBundle] bundlePath];
            NSURL *baseURL = [NSURL fileURLWithPath:path];
            [self.webView loadHTMLString:[WSMetaDataStore metadataStringForObject:self.obj] baseURL:baseURL];
            
        }
        
        
    }
    
}

#pragma mark - webview delegate methods -

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingTaskDidStartNotification object:nil];

}

-(void) webViewDidFinishLoad:(UIWebView *)webView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingTaskDidFinishNotification object:nil];

}

-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
     [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingTaskDidFinishNotification object:nil];   
}

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
