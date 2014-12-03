//
//  Users.h
//  WebSiteTest
//
//  Created by Ryan Farrell on 11/17/14.
//  Copyright (c) 2014 Ryan Farrell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Users : NSManagedObject

@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSString * display_name;

@end
