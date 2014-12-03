//
//  Chatroom+Annotation.m
//  WebSiteTest
//
//  Created by Ryan Farrell on 11/21/14.
//  Copyright (c) 2014 Ryan Farrell. All rights reserved.
//

#import "Chatroom+Annotation.h"

@implementation Chatroom (Annotation)

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    
    coordinate.latitude = [self.latitude doubleValue];
    coordinate.longitude = [self.longitude doubleValue];
    
    return coordinate;
}

@end
