//
// Created by sarsonj on 5/30/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TSRemoteSettings.h"


#import "JSONWebClient.h"


@implementation TSRemoteSettings {
    NSString *_urlString;
    NSMutableDictionary *_settings;
    JSONWebClient *webClient;
}
@synthesize urlString = _urlString;
@synthesize settings = _settings;


- (void)setAppUrl:(NSString *)appUrl {
    _appUrl = appUrl;
    webClient = [[JSONWebClient alloc] initWithBaseURL:[NSURL URLWithString:self.appUrl]];
    _settings = [[NSMutableDictionary alloc] init];
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
        [webClient GET:self.urlString parameters:nil success:^(NSURLSessionTask *operation, id responseObject) {
            NSDictionary *globalSettings = responseObject;
            for (NSString *key in globalSettings.allKeys) {
                if (!_settings[key]) {
                    _settings[key] = globalSettings[key];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REMOTE_SETTINGS_UPDATED object:nil];
            callAfter(YES);
        } failure:^(NSURLSessionTask *operation, NSError *error) {
//            self.settings = nil;
            NSLog(@"Error with loading remote settings %@", [error description]);
            callAfter(NO);
        }];
    }
}


/**
* complex key can use dots to traverse in hiearchy
* like networkOptimilizer.minFrame
*/
-(NSObject *)getObjectByKey:(NSString *)complexKey {
    NSArray *keys = [complexKey componentsSeparatedByString:@"."];
    NSObject *currentObj = self.settings;
    for (NSString *key in keys) {
        if ([currentObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = currentObj;
            currentObj = dict[key];
        } else {
            return nil;
        }
    }
    return currentObj;
};

-(BOOL)bKey:(NSString*)name default:(BOOL)deflt {
    BOOL toRet = deflt;
    NSObject *obj = [self getObjectByKey:name];
    if ([obj isKindOfClass:[NSNumber class]]) {
        toRet = [(NSNumber *)obj boolValue];
    }
    return toRet;
}

-(int)iKey:(NSString*)name default:(int)deflt {
    int toRet = deflt;
    NSObject *obj = [self getObjectByKey:name];
    if ([obj isKindOfClass:[NSNumber class]]) {
        toRet = [(NSNumber *)obj intValue];
    }
    return toRet;
}

-(NSString*)sKey:(NSString*)name default:(NSString*)deflt {
    NSString* toRet = deflt;
    NSObject *obj = [self getObjectByKey:name];
    if ([obj isKindOfClass:[NSString class]]) {
        toRet = (NSString *)obj;
    }
    return toRet;
}



- (void)mergeWithPerUserSettings:(NSDictionary *)perUserSettings {
    for (NSString *key in perUserSettings.allKeys) {
        _settings[key] = perUserSettings[key];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REMOTE_SETTINGS_UPDATED object:nil];
}


- (void)setUrlString:(NSString *)anUrl {
    _urlString = anUrl;
}


@end