//
// Created by JS on 8/26/13.
// Copyright (c) 2013 TappyTaps. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CocoaLumberjack/DDLog.h>
//#import <Appirater/Appirater.h>
//#import <LBYouTubeView/LBYouTubePlayerViewController.h>
#import "TSAppHTMLMessageController.h"
#import "UIView+RMAdditions.h"
#import "TSAppSupportSingleton.h"

#define SYTEM_PREFIX @"system-"

@implementation TSAppHTMLMessageController


- (id)initWithMessageParams:(NSDictionary *)params {
    if ((self = [super init])) {
        self.messageParams = params;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    _loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    if (!self.embeddedInNavigationController) {

    }

    self.topEmptyView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.topEmptyView];
    _navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectZero];
    UINavigationItem *navItem;
    if (self.embeddedInNavigationController) {
        navItem = self.navigationController.navigationItem;
    } else {
        navItem = [UINavigationItem alloc];
    }
    navItem.title = @"";
    navItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close",@"") style:UIBarButtonItemStyleDone target:self action:@selector(closeMessage:)];
    [_navigationBar pushNavigationItem:navItem animated:false];

    _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    _webView.delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_loading];
    if (!self.embeddedInNavigationController) {
        [self.view addSubview:_navigationBar];
    }

    [self.view addSubview:_webView];
    [self loadMessage];
}

- (void)setMessageParams:(NSDictionary *)messageParams {
    _messageParams = messageParams;
    [self loadMessage];
}

- (void)loadMessage {
    _webView.hidden = YES;
    _loading.hidden = NO;
    [_loading startAnimating];

    // load HTML message
    self.navigationBar.topItem.title = self.messageParams[@"title"];

    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.messageParams[@"url"]]]];
}

#pragma mark WebView delegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"Error: %@", [error description]);
    [_loading stopAnimating];
    _loading.hidden = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"We were not able to load message, sorry.", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
    [alert show];
    [self closeMessage:self];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_loading stopAnimating];
    _loading.hidden = YES;
    webView.hidden = NO;
    if (![self.messageParams[@"type"] isEqualToString:@"internal"]) {
        // mark as read
        [[TSAppSupportSingleton sharedInstance] markMessageAsRead:self.messageParams[@"messageId"]];
    }
}

-(void)supportEmail:(NSString*)email {

}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *emailAddress = @"support@tappytaps.com";
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSURL *url = [request URL];
        if ([[url scheme] hasPrefix:@"mailto"]) {
            [self supportEmail:emailAddress];
            return NO;
        }

        // any URL can be pushed to iOS open URL when with prefix system-
        if ([[url scheme] hasPrefix:SYTEM_PREFIX]) {
            NSURL *newUrl = [NSURL URLWithString:[[url absoluteString] substringFromIndex:[SYTEM_PREFIX length]]];
            if (![[UIApplication sharedApplication] openURL:newUrl]) {
            };
            return NO;
        }

        if (![[url scheme] hasPrefix:@"http"]) {
                [[UIApplication sharedApplication] openURL:url];
            return NO;
        }
    }
    return YES;
};


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    if (self.view.origin.y == 0) {
        if (self.navigationBarColor) {
            self.topEmptyView.backgroundColor = self.navigationBarColor;
        }
        self.topEmptyView.width = self.view.width;
        self.topEmptyView.height = 18;
    }

    [_navigationBar sizeToFit];
    _navigationBar.origin = CGPointMake(0, self.topEmptyView.height);
    if (self.embeddedInNavigationController) {
        self.navigationBar.height = 0;
    }

    _loading.centerX = self.view.width / 2;
    _loading.centerY = (self.view.height - _navigationBar.height) / 2 + _navigationBar.height;

    _webView.left = 0;
    _webView.top = _navigationBar.bottom;
    _webView.width = self.view.width;
    _webView.height = self.view.height - _navigationBar.height;
}

- (IBAction)closeMessage:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


@end