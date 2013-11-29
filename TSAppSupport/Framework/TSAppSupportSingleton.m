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
#import "AdSupport/ASIdentifierManager.h"

#define LIB_VERSION 2
#define API_URL @"http://appsupport.tappytaps.com"
#define EMPTY_WHEN_NULL(x) (x == nil)?[NSNull null]:x


#define UPDATE_MESSAGES_EVERY 3600 * 8

@implementation TSAppSupportSingleton {
    NSString *_appId;
    AFHTTPClient *webClient;
    NSTimeInterval latestMessagesDownload;
}


#if TARGET_OS_IPHONE

-(NSString *)getUniqueIdentifier {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    } else {
        return @"<iOS6";
    }
}

-(NSString *)getGlobalIdentifier {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    } else {
        return @"<iOS6";
    }
}


-(BOOL)supportsUniqueIdentifier {
    return  [[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)];
}

#else


-(NSString *)getUniqueIdentifier {
    io_service_t    platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault,
    IOServiceMatching("IOPlatformExpertDevice"));
    CFStringRef serialNumberAsCFString = NULL;
    if (platformExpert) {
        serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert,
        CFSTR(kIOPlatformSerialNumberKey),
        kCFAllocatorDefault, 0);
        IOObjectRelease(platformExpert);
    }
    NSString *serialNumberAsNSString = nil;
    if (serialNumberAsCFString) {
        serialNumberAsNSString = [NSString stringWithString:(NSString *)serialNumberAsCFString];
        CFRelease(serialNumberAsCFString);
    }
    return serialNumberAsNSString;
}


#endif


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
        latestMessagesDownload = 0;
    }
    return self;
}

- (void)setAppUrl:(NSString *)appUrl {
    _appUrl = appUrl;
    webClient = [[JSONWebClient alloc] initWithBaseURL:[NSURL URLWithString:self.appUrl]];
}


#if TARGET_OS_IPHONE
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
#else
- (NSString *) platform {
    {
    size_t len = 0;
    sysctlbyname("hw.model", NULL, &len, NULL, 0);

    if (len)
    {
        char *model = malloc(len*sizeof(char));
        sysctlbyname("hw.model", model, &len, NULL, 0);
        NSString *model_ns = [NSString stringWithUTF8String:model];
        free(model);
        return model_ns;
    }

    return @"unknown model"; //incase model name can't be read
}

#endif




-(NSMutableDictionary *)userStateDictionary {
    NSMutableDictionary *toRet = [NSMutableDictionary dictionary];
    toRet[@"version"] = EMPTY_WHEN_NULL([[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]);
    toRet[@"libVersion"] = @LIB_VERSION;

#if TARGET_OS_IPHONE
    toRet[@"osVersion"] = EMPTY_WHEN_NULL([UIDevice currentDevice].systemVersion);
#else
    toRet[@"osVersion"] = [[NSProcessInfo processInfo] operatingSystemVersionString];
#endif
    toRet[@"platform"] = EMPTY_WHEN_NULL([self platform]);
    toRet[@"lang"] = EMPTY_WHEN_NULL([[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0]);
    return toRet;
}

-(NSMutableDictionary *)messageHeader {
    return [NSMutableDictionary dictionaryWithDictionary:
             @{@"vendorId": EMPTY_WHEN_NULL([self getUniqueIdentifier]),
             @"globalId": EMPTY_WHEN_NULL([self getGlobalIdentifier]),
             @"appId": EMPTY_WHEN_NULL(_appId)}];
}

- (void)launchWithAppId:(NSString *)appId {
    [self launchWithAppId:appId additionalVariables:nil];
}



-(void)markMessageAsRead:(NSString *)messageId {
    assert(webClient);
    self.currentMessage = nil;
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

-(void)callDelegateForRecievedMessage:(NSDictionary *)message {
    if ([message objectForKey:@"type"] != nil && [message objectForKey:@"params"] != nil) {
        [self.appSupportDelagate messageType:self.currentMessage[@"type"] withParams:self.currentMessage[@"params"]];
    }
}

-(void)cachedLoadNewMessages {
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    if (((now - latestMessagesDownload) < UPDATE_MESSAGES_EVERY) && (self.currentMessage != nil)) {
        [self callDelegateForRecievedMessage:self.currentMessage];
    } else{
        [self loadNewMessageFromServer];
    }
}



-(void)loadNewMessageFromServer {
    assert(webClient);
    if ([self supportsUniqueIdentifier]) {
        NSMutableDictionary *launchParams = [self userStateDictionary];
        [launchParams addEntriesFromDictionary:[self messageHeader]];
        [launchParams addEntriesFromDictionary:self.additionalParams];
        [webClient postPath:@"/appLaunched" parameters:launchParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *responseDictionary = responseObject;
            if (responseDictionary != nil) {
                latestMessagesDownload = [NSDate timeIntervalSinceReferenceDate];
                self.currentMessage = responseDictionary;
                [self callDelegateForRecievedMessage:self.currentMessage];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
    } else {
        // don't do anything - old iOS version
        // messages not supported on <iOS6
    }
}


@end