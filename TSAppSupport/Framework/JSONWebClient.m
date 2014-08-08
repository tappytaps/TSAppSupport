//
// Created by JS on 9/12/13.
// Copyright (c) 2013 TappyTaps. All rights reserved.
//


#import "JSONWebClient.h"
#import "AFJSONRequestOperation.h"


@implementation JSONWebClient {

}

static NSObject<SecureCommunicationProtocol> *secureProcessor;

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        [self setParameterEncoding:AFJSONParameterEncoding];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObjects:@"text/plain", nil]];
    }
    return self;
}


+ (void)setSecureProcessor:(NSObject <SecureCommunicationProtocol> *)pSecureProcessor {
    secureProcessor = pSecureProcessor;
}

+ (NSObject <SecureCommunicationProtocol> *)secureProcessor {
    return secureProcessor;
}


- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    AFHTTPRequestOperation *operation =  [super HTTPRequestOperationWithRequest:urlRequest success:success failure:failure];
    operation.SSLPinningMode = AFSSLPinningModeCertificate;
    return operation;
}


- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
     withTimeout:(NSTimeInterval)timeout
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure

{
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
    [request setTimeoutInterval:timeout];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}




@end