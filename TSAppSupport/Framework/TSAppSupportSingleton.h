//
// Created by JS on 8/26/13.
// Copyright (c) 2013 TappyTaps. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>
#import "GCDMulticastDelegate.h"
#import "TSAppSupportMessage.h"

typedef void (^TSMaintananceResultBlock)(BOOL, NSString *);

@class TSAppSupportSingleton;

@protocol TSAppSupportDelegate

- (void)appSupportSingleton:(TSAppSupportSingleton *)appSupportSingleton didUpdateCurrentMessage:(TSAppSupportMessage *)message;

@end

@interface TSAppSupportSingleton : NSObject

+ (TSAppSupportSingleton*)sharedInstance;

- (BOOL)supportsUniqueIdentifier;
- (void)launchWithAppId:(NSString *)appId additionalVariables:(NSDictionary *)additional;
- (void)cachedLoadNewMessages;
- (void)launchWithAppId:(NSString *)appId;
- (void)loadNewMessageFromServer;
- (void)pinMessage:(TSAppSupportMessage *)message;
- (void)unpinMessage;
- (void)markMessageAsRead:(TSAppSupportMessage *)message;
- (void)checkMaintananceMode:(TSMaintananceResultBlock)resultBlock;

@property GCDMulticastDelegate<TSAppSupportDelegate> *delegate;
@property NSString *appUrl;

@property(nonatomic, strong) TSAppSupportMessage *currentMessage;
@property(nonatomic, strong) NSDictionary *additionalParams;
@property NSDictionary *perUserRemoteSettings;

@end
