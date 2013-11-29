//
// Created by JS on 8/26/13.
// Copyright (c) 2013 TappyTaps. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

#import "GCDMulticastDelegate.h"


typedef void (^TSMaintananceResultBlock)(BOOL, NSString *);

@protocol TSAppSupportDelegate
    -(void)messageType:(NSString *)messageType withParams:(NSDictionary *)params;
    -(void)didReadMessage:(NSString *)messageId;
@end

@interface TSAppSupportSingleton : NSObject
- (BOOL)supportsUniqueIdentifier;

+(TSAppSupportSingleton*)sharedInstance;

- (void)launchWithAppId:(NSString *)appId additionalVariables:(NSDictionary *)additional;

- (void)cachedLoadNewMessages;

- (void)loadNewMessageFromServer;

- (void)launchWithAppId:(NSString *)appId;

- (void)markMessageAsRead:(NSString *)messageId;

- (void)checkMaintananceMode:(TSMaintananceResultBlock)resultBlock;

@property GCDMulticastDelegate<TSAppSupportDelegate> *appSupportDelagate;
@property NSString *appUrl;

@property(nonatomic, strong) NSDictionary *currentMessage;
@property(nonatomic, strong) NSDictionary *additionalParams;
@end