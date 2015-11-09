//
// Created by JS on 9/12/13.
// Copyright (c) 2013 TappyTaps. All rights reserved.
//


#import "JSONWebClient.h"


@implementation JSONWebClient {

}


- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = YES;
        [self setSecurityPolicy:securityPolicy];

        
        
//        [self setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate]];
//        securityPolicy.allowInvalidCertificates = YES;
//        securityPolicy.validatesDomainName = YES;

    }
    return self;
}




@end