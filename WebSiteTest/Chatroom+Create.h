//
//  Chatroom+Create.h
//  WebSiteTest
//
//  Created by Ryan Farrell on 11/17/14.
//  Copyright (c) 2014 Ryan Farrell. All rights reserved.
//

#import "Chatroom.h"

@interface Chatroom (Create)

+ (Chatroom *)ChatroomWithInfo:(NSDictionary *)chatroomDictionary;

@end
