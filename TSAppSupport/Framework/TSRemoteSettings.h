//
// Created by sarsonj on 5/30/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@interface TSRemoteSettings : NSObject

@property(nonatomic, copy) NSString *urlString;
@property(strong, readonly) NSDictionary *settings;

- (void)reload;

- (void)reloadAndCallAfter:(void (^)(BOOL))emptyBlock;

- (BOOL)bKey:(NSString *)name default:(BOOL)deflt;

-(void)mergeWithPerUserSettings: (NSDictionary *)perUserSettings;

+(TSRemoteSettings*)sharedInstance;

@property NSString *appUrl;

@end


