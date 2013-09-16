//
// Created by JS on 8/26/13.
// Copyright (c) 2013 TappyTaps. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TSAppSupportSingleton.h"
#import "AFHTTPClient.h"
#import "GCDMulticastDelegate.h"
#import "AFJSONRequestOperation.h"
#import "JSONWebClient.h"
#include <sys/types.h>
#include <sys/sysctl.h>

#define LIB_VERSION 1
#define API_URL @"http://appsupport.tappytaps.com"


@implementation TSAppSupportSingleton {
    NSString *_appId;
    AFHTTPClient *webClient;
}


-(NSString *)getUniqueIdentifier {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    } else {
        return @"<iOS6";
    }
}


+(TSAppSupportSingleton*)sharedInstance {
    static TSAppSupportSingleton *sharedMyInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyInstance = [[self alloc] init];
    });
    return sharedMyInstance;
}



- (id)init {
    self = [super init];
    if (self) {
        self.appSupportDelagate = (GCDMulticastDelegate <TSAppSupportDelegate> *)[[GCDMulticastDelegate alloc] init];
        [self setAppUrl:API_URL];
    }
    return self;
}

- (void)setAppUrl:(NSString *)appUrl {
    _appUrl = appUrl;
    webClient = [[JSONWebClient alloc] initWithBaseURL:[NSURL URLWithString:self.appUrl]];
/*
    [webClient setParameterEncoding:AFJSONParameterEncoding];
    [webClient setDefaultHeader:@"Accept" value:@"application/json"];
    [webClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
*/
}


- (NSString *) platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}


-(NSMutableDictionary *)userStateDictionary {
    NSMutableDictionary *toRet = [NSMutableDictionary dictionary];
    toRet[@"version"] = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    toRet[@"libVersion"] = @LIB_VERSION;
    toRet[@"iosVersion"] = [UIDevice currentDevice].systemVersion;
    toRet[@"platform"] = [self platform];
    toRet[@"lang"] =[[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    return toRet;
}

-(NSMutableDictionary *)messageHeader {
    return [NSMutableDictionary dictionaryWithDictionary:
             @{@"vendorId": [self getUniqueIdentifier],
             @"appId": _appId}];
}

- (void)launchWithAppId:(NSString *)appId {
    [self launchWithAppId:appId additionalVariables:nil];
}



-(void)markMessageAsRead:(NSString *)messageId {
    assert(webClient);
    [self.appSupportDelagate didReadMessage:messageId];
    NSMutableDictionary *params = [self messageHeader];
    params[@"messageId"] = messageId;
    [webClient postPath:@"/messageReaded" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

-(void)checkMaintananceMode:(TSMaintananceResultBlock)resultBlock {
    assert(webClient);
    [webClient postPath:@"/maintenance" parameters: [self messageHeader] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *ret = responseObject;
        if ([ret[@"maintenance"] isEqualToString:@"yes"]) {
            resultBlock(YES, ret[@"message"]);
        } else {
            resultBlock(NO, @"");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error %@", error);
        resultBlock(NO, @"");
    }
    ];
}

-(void)launchWithAppId:(NSString *)appId additionalVariables:(NSDictionary *)additional {
    self.additionalParams = additional;
    _appId = appId;
}

-(void)loadNewMessageFromServer {
    assert(webClient);
    if ([self getUniqueIdentifier]) {
        NSMutableDictionary *launchParams = [self userStateDictionary];
        [launchParams addEntriesFromDictionary:[self messageHeader]];
        [launchParams addEntriesFromDictionary:self.additionalParams];
        [webClient postPath:@"/appLaunched" parameters:launchParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Success!");
            NSDictionary *responseDictionary = responseObject;
            if (responseDictionary != nil) {
                self.currentMessage = responseDictionary;
                [self.appSupportDelagate messageType:responseDictionary[@"type"] withParams:responseDictionary[@"params"]];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Fail! %@", [error description]);
        }];
    } else {
        // don't do anything - old iOS version
        // messages not supported on <iOS6
    }
}


@end