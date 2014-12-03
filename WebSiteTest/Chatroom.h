//
//  Chatroom.h
//  WebSiteTest
//
//  Created by Ryan Farrell on 11/21/14.
//  Copyright (c) 2014 Ryan Farrell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Chatroom : NSManagedObject

@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSNumber * chat_id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDecimalNumber * latitude;
@property (nonatomic, retain) NSDecimalNumber * longitude;
@property (nonatomic, retain) NSNumber * room_admin;
@property (nonatomic, retain) NSDate * time_stamp;

@end
