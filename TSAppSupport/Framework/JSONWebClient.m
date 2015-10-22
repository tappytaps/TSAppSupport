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
        [self setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate]];
    }
    return self;
}




@end