//
// Created by JS on 8/26/13.
// Copyright (c) 2013 TappyTaps. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

#import "GCDMulticastDelegate.h"


@protocol TSAppSupportDelegate
    -(void)messageType:(NSString *)messageType withParams:(NSDictionary *)params;
@end

@interface TSAppSupportSingleton : NSObject
+(TSAppSupportSingleton*)sharedInstance;


- (void)launchWithAppId:(NSString *)appId additionalVariables:(NSDictionary *)additional;

- (void)launchWithAppId:(NSString *)appId;


- (void)markMessageAsRead:(NSString *)messageId;

@property GCDMulticastDelegate<TSAppSupportDelegate> *appSupportDelagate;
@property NSString *appUrl;

@end