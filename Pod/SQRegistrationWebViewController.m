//
//  SQRegistrationWebViewController.m
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import "SQRegistrationWebViewController.h"
#import "SQRequestHelper.h"


@interface SQRegistrationWebViewController () <WKNavigationDelegate>

@property (copy, nonatomic) RegistrationCompletionBlock completionBlock;
@property (strong, nonatomic) WKWebView *webView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) NSURL *url;

@end



@implementation SQRegistrationWebViewController

- (id)initWithURL:(NSURL *)url andCompletionBlock:(RegistrationCompletionBlock)completionBlock {
    self = [super init];
    if (self) {
        self.completionBlock = completionBlock;
        self.url = url;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = self.view.bounds;
    rect.origin = CGPointZero;
    
    WKPreferences *preferences = [[WKPreferences alloc] init];
    preferences.javaScriptEnabled = YES;
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.preferences = preferences;
    WKWebView *webView = [[WKWebView alloc] initWithFrame:rect configuration:configuration];
    
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:webView];
    self.webView = webView;
    
    // add cancel button for viewController
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(actionCancel:)];
    [self.navigationItem setRightBarButtonItem:cancelButton animated:YES];
    
    // add activity indicator
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.titleView = self.activityIndicator;
    
    [self.activityIndicator startAnimating];
    // open login page from url with params
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
    self.webView.navigationDelegate = self;
}



#pragma mark -
#pragma mark Actions

- (void)actionCancel:(UIBarButtonItem *)sender {
    if (self.completionBlock) {
        self.webView.navigationDelegate = nil;
        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
        [result setObject:[NSNumber numberWithBool:YES] forKey:@"didCancelRegistration"];
        self.completionBlock(result);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark -
#pragma mark WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"request: %@", navigationAction.request);
    
    if ([[SQRequestHelper sharedInstance] verifyRegistrationRequestForRedirectBack:navigationAction.request]) {
        self.webView.navigationDelegate = nil;
        if (self.completionBlock) {
            self.completionBlock([[SQRequestHelper sharedInstance] parseRequest:navigationAction.request]);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        decisionHandler(WKNavigationActionPolicyCancel);
        
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    NSLog(@"response: %@", navigationResponse.response);
    
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
    NSURL *url = [response URL];
    NSString *urlString = [url absoluteString];
    
    if ([urlString containsString:@"sequencing.com/"]) {
        
        NSInteger statusCode = [response statusCode];
        NSLog(@"statusCode: %d", (int)statusCode);
        if (statusCode == 200 ||
            statusCode == 301 ||
            statusCode == 302) {
            
            decisionHandler(WKNavigationResponsePolicyAllow);
            
        } else {
            [self.activityIndicator stopAnimating];
            self.webView.navigationDelegate = nil;
            NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
            [result setObject:[NSNumber numberWithBool:YES] forKey:@"error"];
            self.completionBlock(result);
            [self dismissViewControllerAnimated:YES completion:nil];
            decisionHandler(WKNavigationResponsePolicyCancel);
        }
        
    } else {
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
}


- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    [self.activityIndicator startAnimating];
}


- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self.activityIndicator stopAnimating];
    self.webView.navigationDelegate = nil;
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setObject:[NSNumber numberWithBool:YES] forKey:@"error"];
    self.completionBlock(result);
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"%@", [error localizedDescription]);
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [self.activityIndicator stopAnimating];
}


- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self.activityIndicator stopAnimating];
    self.webView.navigationDelegate = nil;
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setObject:[NSNumber numberWithBool:YES] forKey:@"error"];
    self.completionBlock(result);
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"%@", [error localizedDescription]);
}



#pragma mark -
#pragma mark Memory helper

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
