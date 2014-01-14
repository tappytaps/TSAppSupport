//
// Created by sarsonj on 5/30/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TSRemoteSettings.h"


#import "AFHTTPRequestOperation.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "JSONWebClient.h"


@implementation TSRemoteSettings {
    NSString *_urlString;
    NSDictionary *_settings;
    AFHTTPClient *webClient;
}
@synthesize urlString = _urlString;
@synthesize settings = _settings;


- (void)setAppUrl:(NSString *)appUrl {
    _appUrl = appUrl;
    webClient = [[JSONWebClient alloc] initWithBaseURL:[NSURL URLWithString:self.appUrl]];
/*
    [webClient setParameterEncoding:AFJSONParameterEncoding];
    [webClient setDefaultHeader:@"Accept" value:@"application/json"];
    [webClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
*/
}

+(TSRemoteSettings*)sharedInstance {
    static TSRemoteSettings *sharedMyInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyInstance = [[self alloc] init];
    });
    return sharedMyInstance;
}

-(void)reload {
    [self reloadAndCallAfter:^(BOOL b) {

    }
    ];
}

-(void)reloadAndCallAfter: (void(^)(BOOL))callAfter {
    if (self.urlString != nil) {
        [webClient getPath:self.urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.settings = responseObject;
            callAfter(YES);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            self.settings = nil;
            NSLog(@"Error with loading remote settings %@", [error description]);
            callAfter(NO);
        }];
    }
}

-(BOOL)bKey:(NSString*)name default:(BOOL)deflt {
    BOOL toRet = deflt;
    if ((self.settings)[name]) {
        toRet = [(self.settings)[name] boolValue];
    }
    return toRet;
}


- (void)setUrlString:(NSString *)anUrl {
    _urlString = anUrl;
}


@end