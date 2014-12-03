//
//  ChatroomsCreate.m
//  WebSiteTest
//
//  Created by Ryan Farrell on 11/29/14.
//  Copyright (c) 2014 Ryan Farrell. All rights reserved.
//

#import "ChatroomsCreate.h"
#import "ProfileTBC.h"

@interface ChatroomsCreate ()

@property (nonatomic, strong) NSString *Session_ID;
@property (nonatomic, strong) NSString *Latitude;
@property (nonatomic, strong) NSString *Longitude;
@property (nonatomic, strong) NSString *LoginID;
@property (nonatomic, strong) NSString *Password;

@end

@implementation ChatroomsCreate

@synthesize Session_ID = _Session_ID;
@synthesize Latitude = _Latitude;
@synthesize Longitude = _Longitude;
@synthesize LoginID = _LoginID;
@synthesize Password = _Password;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    /*if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
     {
     [self.locationManager requestWhenInUseAuthorization];
     }*/
    
    [locationManager startUpdatingLocation];
    
    ProfileTBC *tabBar =  (ProfileTBC *)self.tabBarController;
    self.Session_ID = (NSString *)tabBar.Session_ID;
    self.LoginID = (NSString *)tabBar.LoginID;
    self.Password = (NSString *)tabBar.Password;
    self.Latitude = (NSString *)tabBar.Latitude;
    self.Longitude = (NSString *)tabBar.Longitude;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)UpdateLocation {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:@"http://54.172.35.180:8080/api/updatelocation"]];
    
    NSMutableString *param = [[NSMutableString alloc] init];
    
    NSLog(@"Text: %@", self.Latitude);
    
    NSLog(@"Text: %@", self.Longitude);
    
    [param appendString:[NSString stringWithFormat:@"%@=%@", @"session_id", self.Session_ID]];
    
    [param appendString:[NSString stringWithFormat:@"&%@=%@", @"latitude", self.Latitude]];
    
    [param appendString:[NSString stringWithFormat:@"&%@=%@", @"longitude", self.Longitude]];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[param dataUsingEncoding:NSUTF8StringEncoding]];
    
    // another configuration option is backgroundSessionConfiguration (multitasking API required though)
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    
    // create the session without specifying a queue to run completion handler on (thus, not main queue)
    // we also don't specify a delegate (since completion handler is all we need)
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error)
        {
            if ([request.URL isEqual:[NSURL URLWithString:@"http://54.172.35.180:8080/api/updatelocation"]]) {
                NSLog(@"Text: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                NSNumber *success = (NSNumber *)[json objectForKey:@"success"];
                if([success boolValue] == NO) {
                    NSString *jsonError = [json valueForKeyPath:@"error_code"];
                    if([jsonError isEqualToString:@"101"])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{[self UpdateSessionID:@"UpdateLocation"];});
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{[self UpdateChatrooms];});
                    
                }
            }
        }
        else
        {
            _ErrorCheck.text = @"Network/Server Error";
        }
    }];
    
    [task resume];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
