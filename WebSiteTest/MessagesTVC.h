//
//  MessagesTVC.h
//  WebSiteTest
//
//  Created by Ryan Farrell on 11/23/14.
//  Copyright (c) 2014 Ryan Farrell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessagesTVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic, strong) NSString *User_ID;
@property (nonatomic, strong) NSNumber *Room_ID;
@property (nonatomic, strong) NSString *chat_type;
@property (nonatomic, strong) NSString *Session_ID;
@property (nonatomic, strong) NSString *LoginID;
@property (nonatomic, strong) NSString *Password;


@end
