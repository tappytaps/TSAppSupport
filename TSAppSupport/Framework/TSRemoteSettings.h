//
// Created by sarsonj on 5/30/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

#define NOTIFICATION_REMOTE_SETTINGS_UPDATED    @"com.tappytaps.remotesettings.updated"


// helper macros
#define RS_INT(p_name, p_default)  [[TSRemoteSettings sharedInstance] iKey: p_name default:p_default]
#define RS_BOOL(p_name, p_default)  [[TSRemoteSettings sharedInstance] bKey: p_name default:p_default]
#define RS_STRING(p_name, p_default)  [[TSRemoteSettings sharedInstance] sKey: p_name default:p_default]

@interface TSRemoteSettings : NSObject

@property(nonatomic, copy) NSString *urlString;
@property(strong, readonly) NSDictionary *settings;

- (void)reload;

- (void)reloadAndCallAfter:(void (^)(BOOL))emptyBlock;

-(BOOL)bKey:(NSString *)name default:(BOOL)deflt;
-(int)iKey:(NSString*)name default:(int)deflt;
-(NSString*)sKey:(NSString*)name default:(NSString *)deflt;

-(void)mergeWithPerUserSettings: (NSDictionary *)perUserSettings;

+(TSRemoteSettings*)sharedInstance;

@property NSString *appUrl;

@end


