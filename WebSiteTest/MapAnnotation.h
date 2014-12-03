//
//  MapAnnotation.h
//  WebSiteTest
//
//  Created by Ryan Farrell on 11/23/14.
//  Copyright (c) 2014 Ryan Farrell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapAnnotation : NSObject <MKAnnotation>

@property (nonatomic, retain) NSNumber * chat_id;
@property (nonatomic, retain) NSString * chat_title;
@property (nonatomic, retain) NSString * chat_dscrpn;
@property (nonatomic, retain) NSDecimalNumber * latitude;
@property (nonatomic, retain) NSDecimalNumber * longitude;
@property (nonatomic, retain) NSNumber * room_admin;
@property (nonatomic, retain) NSDate * time_stamp;
@property (nonatomic, retain) NSString * chat_type;


@end
