//
// Created by JS on 20/01/15.
// Copyright (c) 2015 TappyTaps. All rights reserved.
//

#import "TSAppHTMLMessageWithBar.h"
#import "TSAppHTMLMessageController.h"


@implementation TSAppHTMLMessageWithBar {

}

-(id)initWithMessageParams:(NSDictionary *)dict {
    TSAppHTMLMessageController *messageController = [[TSAppHTMLMessageController alloc] initWithMessageParams:dict];
    messageController.embeddedInNavigationController = YES;
    [self pushViewController:messageController animated:YES];
    return self;
}

@end