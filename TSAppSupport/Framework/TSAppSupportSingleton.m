//
// Created by JS on 8/26/13.
// Copyright (c) 2013 TappyTaps. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TSAppSupportSingleton.h"
#import "GCDMulticastDelegate.h"
#import "JSONWebClient.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "DDLog.h"
#import "TSRemoteSettings.h"

#if TARGET_OS_IPHONE
#import "AdSupport/ASIdentifierManager.h"

#endif
#define LIB_VERSION 2
#define API_URL @"http://appsupport.tappytaps.com"
#define EMPTY_WHEN_NULL(x) (x == nil)?[NSNull null]:x


#define UPDATE_MESSAGES_EVERY 3600.0 * 0.25

static const int ddLogLevel = LOG_LEVEL_INFO;

@implementation TSAppSupportSingleton {
    NSString *_appId;
    JSONWebClient *webClient;
    NSTimeInterval latestMessagesDownload;
}

#if TARGET_OS_IPHONE

- (NSString *)getUniqueIdentifier {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        NSUUID *uuid = [[UIDevice currentDevice] identifierForVendor];
        if (uuid != nil) {
            return [uuid UUIDString];
        } else{
            return @"unknown";
        }
    } else {
        return @"<iOS6";
    }
}

- (NSString *)getGlobalIdentifier {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        NSUUID *uuid = [[UIDevice currentDevice] identifierForVendor];
        if (uuid != nil) {
            return [uuid UUIDString];
        } else{
            return @"unknown";
        }
    } else {
        return @"<iOS6";
    }
}

- (BOOL)supportsUniqueIdentifier {
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
        serialNumberAsNSString = [NSString stringWithString:(__bridge NSString *)serialNumberAsCFString];
        CFRelease(serialNumberAsCFString);
    }
    return serialNumberAsNSString;
}

-(NSString *)getGlobalIdentifier {
    return [self getUniqueIdentifier];
}

-(BOOL)supportsUniqueIdentifier {
    return ([self getUniqueIdentifier] != NULL);
}

#endif

+ (TSAppSupportSingleton*)sharedInstance {
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
        self.delegate = (GCDMulticastDelegate <TSAppSupportDelegate> *)[[GCDMulticastDelegate alloc] init];
        [self setAppUrl:API_URL];
        latestMessagesDownload = 0;
    }
    return self;
}

- (void)setAppUrl:(NSString *)appUrl {
    _appUrl = appUrl;
    webClient = [[JSONWebClient alloc] initWithBaseURL:[NSURL URLWithString:self.appUrl]];
    [webClient.requestSerializer setTimeoutInterval:3.0];
}


#if TARGET_OS_IPHONE
- (NSString *) platform {
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

- (NSMutableDictionary *)userStateDictionary {
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

- (NSMutableDictionary *)messageHeader {
    return [NSMutableDictionary dictionaryWithDictionary:
             @{@"vendorId": EMPTY_WHEN_NULL([self getUniqueIdentifier]),
             @"globalId": EMPTY_WHEN_NULL([self getGlobalIdentifier]),
             @"appId": EMPTY_WHEN_NULL(_appId)}];
}

- (void)launchWithAppId:(NSString *)appId {
    [self launchWithAppId:appId additionalVariables:nil];
}

- (void)pinMessage:(TSAppSupportMessage *)message {
    if (message.pinned) {
        return;
    }
    [message pinUntil:[NSDate dateWithTimeIntervalSinceNow:60*60*24*3]]; // 3 days
    
    self.currentMessage = message;
    
    NSData *messageData = [NSKeyedArchiver archivedDataWithRootObject:message];
    [[NSUserDefaults standardUserDefaults] setObject:messageData forKey:@"pinnedMessage"];
    
    [self notifyDelegateAboutCurrentMessageUpdate];
    [self markMessageAsReadOnServer:message];
}

- (void)unpinMessage {
    self.currentMessage = nil;
    [self deletePinnedMessage];
    [self notifyDelegateAboutCurrentMessageUpdate];
}

- (TSAppSupportMessage *)getPinnedMessage {
    NSData *messageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"pinnedMessage"];
    if (messageData != nil) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:messageData];
    }
    return nil;
}

- (void)deletePinnedMessage {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"pinnedMessage"];
}

- (void)markMessageAsRead:(TSAppSupportMessage *)message {
    DDLogInfo(@"MessageReadWS: %@ was marked as read", message.messageId);
    assert(webClient);
    self.currentMessage = nil;
    [self deletePinnedMessage];
    [self notifyDelegateAboutCurrentMessageUpdate];
    [self markMessageAsReadOnServer:message];
}

- (void)markMessageAsReadOnServer:(TSAppSupportMessage *)message {
    NSMutableDictionary *params = [self messageHeader];
    params[@"messageId"] = message.messageId;
    [webClient POST:@"/messageReaded" parameters:params success:^(NSURLSessionTask *operation, id responseObject) {
    } failure:^(NSURLSessionTask *operation, NSError *error) {
    }];
}

- (void)checkMaintananceMode:(TSMaintananceResultBlock)resultBlock {
    assert(webClient);

    [webClient POST:@"/maintenance" parameters: [self messageHeader] success:^(NSURLSessionTask *operation, id responseObject) {
        NSDictionary *ret = responseObject;
        if ([ret[@"maintenance"] isEqualToString:@"yes"]) {
            DDLogInfo(@"CheckManitananceWS: YES, %@", ret[@"message"]);
            resultBlock(YES, ret[@"message"]);
        } else {
            DDLogInfo(@"CheckManitananceWS: NO");
            resultBlock(NO, @"");
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        DDLogError(@"CheckManitananceWS: err %@", [error description]);
        resultBlock(NO, @"");
    }];
}

- (void)launchWithAppId:(NSString *)appId additionalVariables:(NSDictionary *)additional {
    self.additionalParams = additional;
    _appId = appId;
}

- (void)notifyDelegateAboutCurrentMessageUpdate {
    [self.delegate appSupportSingleton:self didUpdateCurrentMessage:self.currentMessage];
}

- (void)cachedLoadNewMessages {
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    if (((now - latestMessagesDownload) < UPDATE_MESSAGES_EVERY) && (self.currentMessage != nil)) {
        [self notifyDelegateAboutCurrentMessageUpdate];
    } else{
        [self loadNewMessageFromServer];
    }
}

- (void)loadNewMessageFromServer {
    NSDate *now = [NSDate date];
    TSAppSupportMessage *pinnedMessage = [self getPinnedMessage];
    if (pinnedMessage != nil && [pinnedMessage.pinnedUntil compare:now] == NSOrderedDescending) {
        NSLog(@"PINNED UNTIL: %@", pinnedMessage.pinnedUntil);
        self.currentMessage = pinnedMessage;
        [self notifyDelegateAboutCurrentMessageUpdate];
        return;
    }
    [self deletePinnedMessage];
    
    assert(webClient);
    
    if ([self supportsUniqueIdentifier]) {
        NSMutableDictionary *launchParams = [self userStateDictionary];
        [launchParams addEntriesFromDictionary:[self messageHeader]];
        if (self.additionalParams) {
            launchParams[@"additionalParams"] = self.additionalParams;
        }
        DDLogInfo(@"App launched WS");
        [webClient POST:@"/appLaunchedv2" parameters:launchParams success:^(NSURLSessionTask *operation, id responseObject) {
            NSDictionary *responseDictionary = responseObject;
            // set latest message
            if (responseDictionary[@"message"] != nil) {
                latestMessagesDownload = [NSDate timeIntervalSinceReferenceDate];
                TSAppSupportMessage *message = [[TSAppSupportMessage alloc] initWithDictionary:responseDictionary[@"message"]];
                self.currentMessage = message;
                [self notifyDelegateAboutCurrentMessageUpdate];
            }
            if (responseDictionary[@"remoteSettings"] != nil) {
                [[TSRemoteSettings sharedInstance] mergeWithPerUserSettings:responseDictionary[@"remoteSettings"]];
            }
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            DDLogError(@"appLaunchedWS - %@", [error description]);
        }];
    } else {
        // don't do anything - old iOS version
        // messages not supported on <iOS6
    }
}

@end
