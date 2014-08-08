//
// Created by JS on 9/12/13.
// Copyright (c) 2013 TappyTaps. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@protocol SecureCommunicationProtocol;


@interface JSONWebClient : AFHTTPClient
- (void)postPath:(NSString *)path parameters:(NSDictionary *)parameters withTimeout:(NSTimeInterval)timeout success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+(void)setSecureProcessor:(NSObject<SecureCommunicationProtocol> *)pSecureProcessor;
+(NSObject<SecureCommunicationProtocol> *)secureProcessor;


@end