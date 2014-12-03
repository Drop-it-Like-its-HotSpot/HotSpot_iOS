//
//  Chatroomusers.h
//  WebSiteTest
//
//  Created by Ryan Farrell on 11/17/14.
//  Copyright (c) 2014 Ryan Farrell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Chatroomusers : NSManagedObject

@property (nonatomic, retain) NSString * chat_id;
@property (nonatomic, retain) NSString * user_id;

@end
