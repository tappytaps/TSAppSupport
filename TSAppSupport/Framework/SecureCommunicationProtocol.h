//
// Created by JS on 07/08/14.
// Copyright (c) 2014 TappyTaps. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPRequestOperation;

@protocol SecureCommunicationProtocol <NSObject>


- (void)secureOperation:(AFHTTPRequestOperation  *)operation;

@end