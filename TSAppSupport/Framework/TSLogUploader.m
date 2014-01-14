//
// Created by JS on 14.01.14.
// Copyright (c) 2014 TappyTaps. All rights reserved.
//

#import "TSLogUploader.h"
#import "JSONWebClient.h"

#include <stdint.h>
#include <stdio.h>
#include <CommonCrypto/CommonDigest.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import <CocoaLumberjack/DDLog.h>


// In bytes
#define FileHashDefaultChunkSizeForReadingData 4096

#ifdef DEBUG
static int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static int ddLogLevel = LOG_LEVEL_WARN;
#endif

// Function
CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,
        size_t chunkSizeForReadingData) {

    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;

    // Get the file URL
    CFURLRef fileURL =
            CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                    (CFStringRef)filePath,
                    kCFURLPOSIXPathStyle,
                    (Boolean)false);
    if (!fileURL) goto done;

    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;

    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);

    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }

    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,
                (UInt8 *)buffer,
                (CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,
                (const void *)buffer,
                (CC_LONG)readBytesCount);
    }

    // Check if the read operation succeeded
    didSucceed = !hasMoreData;

    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);

    // Abort if the read operation failed
    if (!didSucceed) goto done;

    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,
            (const char *)hash,
            kCFStringEncodingUTF8);

    done:

    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}


// Cryptography

@implementation TSLogUploader {
    AFHTTPClient *webClient;
}
- (void)setServerUrl:(NSString *)serverUrl {
    _serverUrl = [serverUrl mutableCopy];
    webClient = [[JSONWebClient alloc] initWithBaseURL:[NSURL URLWithString:_serverUrl]];
}

+ (TSLogUploader *)instance {
    static TSLogUploader *_instance = nil;
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}

-(BOOL)uploadFilesForApp:(NSString *)appId user:(NSString *)user files:(NSArray *)files {
    @synchronized (self) {
        if (self.uploading) {
            return NO;
        }
        self.uploading = YES;
    }

    NSMutableDictionary *filesDictionary = [[NSMutableDictionary alloc] init];
    for (NSString *file in files) {
        filesDictionary[[file lastPathComponent]] = file;
    }

    // first - count MD5 for files to see, if we don't have them already
    NSMutableArray *filesJson = [[NSMutableArray alloc] init];
    DDLogVerbose(@"Start upload...");
    for (NSString *file in files) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
            CFStringRef md5hash = FileMD5HashCreateWithPath((__bridge CFStringRef)file,
                    FileHashDefaultChunkSizeForReadingData);
            DDLogVerbose(@"MD5 hash of file at path \"%@\": %@",
            [file lastPathComponent], (__bridge NSString *)md5hash);
            NSString *hash = (__bridge NSString *)md5hash;
            if (hash) {
                CFRelease(md5hash);
                [filesJson addObject:@{@"name": [file lastPathComponent], @"md5": hash}];
            }
        }
    }
    NSDictionary *uploadJson = @{
            @"appId": appId,
            @"user": user,
            @"files": filesJson
    };
    [webClient postPath:@"checkUpload" parameters:uploadJson success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = responseObject;
        DDLogVerbose(@"Files to upload %@", response[@"files"]);
        if (response[@"files"] != nil && [response[@"files"] count] > 0) {
            // do upload
            int __block filesToUpload = [response[@"files"] count];
            for (NSString  *file in response[@"files"]) {
                NSData *fileData = [NSData dataWithContentsOfFile:filesDictionary[file]];
                NSMutableURLRequest *request = [webClient multipartFormRequestWithMethod:@"POST" path:@"upload" parameters: @{@"appId": appId, @"user": user} constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                    [formData appendPartWithFileData:fileData name:@"fileToUpload" fileName:file mimeType:@"text/plain"];
                }];
                AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                NSString __block *blockFile  = file;
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    DDLogVerbose(@"File uploaded: %@", blockFile);
                    @synchronized (self) {
                        filesToUpload--;
                        if (filesToUpload == 0) {
                            self.uploading = NO;
                            DDLogVerbose(@"Upload - all done");
                        }
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    DDLogError(@"Upload failure: %@", [error description]);
                    @synchronized (self) {
                        filesToUpload--;
                        if (filesToUpload == 0) {
                            self.uploading = NO;
                            DDLogVerbose(@"Upload - all done");
                        }
                    }
                }];
                [webClient enqueueHTTPRequestOperation:operation];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // when error. do nothing
        DDLogError(@"Error when calling upload WS function %@", [error description]);
        @synchronized (self) {
            self.uploading = NO;
        }
    }];

    return YES;
}

@end



