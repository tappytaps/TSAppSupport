//
// Created by JS on 14.01.14.
// Copyright (c) 2014 TappyTaps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSLogUploader : NSObject
@property(nonatomic, copy) NSString *serverUrl;
@property BOOL uploading;

+ (TSLogUploader *)instance;

- (BOOL)uploadFilesForApp:(NSString *)appId user:(NSString *)user otherParams:(NSArray *)other files:(NSArray *)files;

@end