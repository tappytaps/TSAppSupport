//
// Created by JS on 8/26/13.
// Copyright (c) 2013 TappyTaps. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TSAppHTMLMessageController.h"
#import "UIView+RMAdditions.h"
#import "TSAppSupportSingleton.h"

@implementation TSAppHTMLMessageController {
}


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
    // mark as read
    [[TSAppSupportSingleton sharedInstance] markMessageAsRead:self.messageParams[@"messageId"]];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    [_navigationBar sizeToFit];
    _navigationBar.origin = CGPointZero;
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