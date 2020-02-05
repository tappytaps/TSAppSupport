//
//  TSAppSupportMessage.m
//  TSAppSupport
//
//  Created by Lukas Boura on 04/02/2020.
//

#import "TSAppSupportMessage.h"

@interface TSAppSupportMessage ()

@property (readonly) NSDictionary *dictionary;

@end

@implementation TSAppSupportMessage

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    NSString *messageId = dictionary[@"messageId"];
    NSString *messageType = dictionary[@"type"];
    NSDictionary *messageParams = dictionary[@"params"];
    
    if ([messageType isEqualToString:@"html"]) {
        _type = TSAppSupportMessageTypeHtml;
    } else if ([messageType isEqualToString:@"love"]) {
        _type = TSAppSupportMessageTypeLove;
    } else if ([messageType isEqualToString:@"email"]) {
        _type = TSAppSupportMessageTypeEmail;
    } else {
        return nil;
    }
    
    _messageId = messageId;
    _title = messageParams[@"title"];
    _url = messageParams[@"url"];
    _dictionary = dictionary;
    
    return self;
}

- (instancetype)initWithType:(TSAppSupportMessageType)type title:(NSString *)title url:(NSString *)url {
    self = [super init];
    _messageId = [NSUUID UUID].UUIDString;
    _type = type;
    _title = title;
    _url = url;
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    NSDictionary *dictionary = [coder decodeObjectForKey:@"dictionary"];
    self = [self initWithDictionary:dictionary];
    if (self) {
        _pinnedUntil = [coder decodeObjectForKey:@"pinnedUntil"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_dictionary forKey:@"dictionary"];
    [coder encodeObject:_pinnedUntil forKey:@"pinnedUntil"];
}

- (void)pinUntil:(NSDate *)date {
    _pinnedUntil = date;
}

- (BOOL)pinned {
    return _pinnedUntil != nil;
}

@end
