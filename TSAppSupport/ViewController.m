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
#import "TSRemoteSettings.h"
#import "TSLogUploader.h"
#import "DDASLLogger.h"

#define API_URL @"http://appsupport.apiary.io/"
//#define LOGS_URL @"http://logsuploader.apiary.io"
#define LOGS_URL @"http://localhost:8011/"




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

    // server settings test
    [[TSRemoteSettings sharedInstance] setAppUrl:@"https://babyam.tappytaps.com"];
    [[TSRemoteSettings sharedInstance] setUrlString:@"/baby3gsettings.json"];
    [[TSRemoteSettings sharedInstance] reloadAndCallAfter:^(BOOL b) {
        NSLog(@"Loaded? %i, Content of settings: %@",b,((TSRemoteSettings *) [TSRemoteSettings sharedInstance]).settings);
    }];


    // create temp files
    NSArray *paths = NSSearchPathForDirectoriesInDomains
            (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *file1Path = [NSString stringWithFormat:@"%@/test1.txt", documentsDirectory];
    [@"pokushokus" writeToFile:file1Path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSString *file2Path = [NSString stringWithFormat:@"%@/test2.txt", documentsDirectory];
    [@"hokus2" writeToFile:file2Path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    // logs test
    [[TSLogUploader instance] setServerUrl:LOGS_URL];
    [[TSLogUploader instance] uploadFilesForApp:@"com.tappytaps.test" user:@"sarsonj@gmail.com" files:@[file1Path, file2Path]];


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
