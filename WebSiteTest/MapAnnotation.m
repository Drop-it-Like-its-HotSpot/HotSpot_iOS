//
//  MapAnnotation.m
//  WebSiteTest
//
//  Created by Ryan Farrell on 11/23/14.
//  Copyright (c) 2014 Ryan Farrell. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation

/*-(id)initWithCoordinates:(CLLocation *)location placeName:(NSString *)placeName description:(NSString *)description {
    self = [super init];
    
    if(self != nil) {
        
    }
}*/

- (NSString *)title
{
    NSString *title = self.chat_title;
    
    return title;
}

- (NSString *)subtitle
{
    NSString *subtitle = self.chat_dscrpn;
    
    return subtitle;
}


- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    
    coordinate.latitude = [self.latitude doubleValue];
    coordinate.longitude = [self.longitude doubleValue];
    
    return coordinate;
}

@end
