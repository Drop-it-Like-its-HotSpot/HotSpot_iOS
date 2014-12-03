//
//  Messages.h
//  WebSiteTest
//
//  Created by Ryan Farrell on 11/18/14.
//  Copyright (c) 2014 Ryan Farrell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Messages : NSManagedObject

@property (nonatomic, retain) NSNumber * chat_id;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSDate * time_stamp;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * m_id;

@end
