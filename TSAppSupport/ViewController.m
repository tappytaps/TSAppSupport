//
//  ViewController.m
//  TSAppSupport
//
//  Created by JS on 8/26/13.
//  Copyright (c) 2013 TappyTaps. All rights reserved.
//

#import "ViewController.h"
#import "TSAppSupportSingleton.h"
#import "TSAppHTMLMessageController.h"

#define API_URL @"http://appsupport.apiary.io/"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[TSAppSupportSingleton sharedInstance] setAppUrl:API_URL];
    [[TSAppSupportSingleton sharedInstance] launchWithAppId:@"FJAIDSOFJDOFID"];
    [[TSAppSupportSingleton sharedInstance].appSupportDelagate addDelegate: self delegateQueue:dispatch_get_main_queue()];
    [[TSAppSupportSingleton sharedInstance] checkMaintananceMode:^(BOOL b, NSString *string) {
        NSLog(@"Is in maintanance: %i", b);
        NSLog(@"Message: %@", string);
    }];
    [[TSAppSupportSingleton sharedInstance] loadNewMessageFromServer];
}

- (void)messageType:(NSString *)messageType withParams:(NSDictionary *)params {
    TSAppHTMLMessageController *messageController = [[TSAppHTMLMessageController alloc] init];
    messageController.messageParams = params;
    [self presentModalViewController:messageController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
