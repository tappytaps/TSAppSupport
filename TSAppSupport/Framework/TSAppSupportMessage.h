//
//  TSAppSupportMessage.h
//  TSAppSupport
//
//  Created by Lukas Boura on 04/02/2020.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TSAppSupportMessageType) {
    TSAppSupportMessageTypeHtml,
    TSAppSupportMessageTypeEmail,
    TSAppSupportMessageTypeLove,
};

@interface TSAppSupportMessage : NSObject <NSCoding>

@property (readonly) NSString *messageId;
@property (readonly) TSAppSupportMessageType type;
@property (readonly) NSString *title;
@property (readonly) NSString *url;

@property (readonly, nonatomic) BOOL pinned;
@property (readonly) NSDate *pinnedUntil;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithType:(TSAppSupportMessageType)type title:(NSString *)title url:(NSString *)url;

- (void)pinUntil:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
