//
// Created by JS on 8/26/13.
// Copyright (c) 2013 TappyTaps. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class TSAppHTMLMessageController;


@protocol TSAppHTMLURLHandlerDelegate
    - (BOOL)messageController:(TSAppHTMLMessageController *)messageController shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
@end


@interface TSAppHTMLMessageController : UIViewController<UIWebViewDelegate>


-(id)initWithMessageParams:(NSDictionary *)params;


@property(nonatomic, strong) UIActivityIndicatorView *loading;
@property(nonatomic, strong) UINavigationBar *navigationBar;
@property(nonatomic, strong) UIBarButtonItem *closeButton;
@property(nonatomic, strong) UINavigationItem *messageTitle;
@property(nonatomic, strong) UIWebView *webView;
@property(nonatomic, strong) NSDictionary *messageParams;
@end