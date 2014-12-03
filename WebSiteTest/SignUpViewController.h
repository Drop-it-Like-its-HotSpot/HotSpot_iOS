//
//  SignUpViewController.h
//  WebSiteTest
//
//  Created by Ryan Farrell on 11/11/14.
//  Copyright (c) 2014 Ryan Farrell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SignUpViewController : UIViewController <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}

@end
