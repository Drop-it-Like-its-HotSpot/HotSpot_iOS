//
//  CreateChatroom.m
//  WebSiteTest
//
//  Created by Ryan Farrell on 11/29/14.
//  Copyright (c) 2014 Ryan Farrell. All rights reserved.
//

#import "CreateChatroom.h"
#import "ProfileTBC.h"

@interface CreateChatroom ()

@property (nonatomic, strong) NSString *Session_ID;
@property (nonatomic, strong) NSString *Latitude;
@property (nonatomic, strong) NSString *Longitude;
@property (nonatomic, strong) NSString *LoginID;
@property (nonatomic, strong) NSString *Password;
@property (weak, nonatomic) IBOutlet UITextField *Title;
@property (weak, nonatomic) IBOutlet UITextField *Description;
@property (weak, nonatomic) IBOutlet UILabel *ErrorCheck;

@end

@implementation CreateChatroom

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
    // Do any additional setup after loading the view.
    
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Text: ");
    if ([_Title isFirstResponder]) {
        [_Title resignFirstResponder];
    }
    else if ([_Description isFirstResponder]) {
        [_Description resignFirstResponder];
    }
}

-(IBAction)returnKeyButton:(id)sender
{
    [sender resignFirstResponder];
}

- (IBAction)CreateChatroom:(id)sender {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:@"http://54.172.35.180:8080/api/chatroom"]];
    
    NSMutableString *param = [[NSMutableString alloc] init];
    
    [param appendString:[NSString stringWithFormat:@"%@=%@", @"latitude", self.Latitude]];
    
    [param appendString:[NSString stringWithFormat:@"&%@=%@", @"longitude", self.Longitude]];
    
    [param appendString:[NSString stringWithFormat:@"&%@=%@", @"chat_title", self.Title.text]];
    
    [param appendString:[NSString stringWithFormat:@"&%@=%@", @"chat_dscrpn", self.Description.text]];
    
    [param appendString:[NSString stringWithFormat:@"&%@=%@", @"session_id", self.Session_ID]];
    
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
            if ([request.URL isEqual:[NSURL URLWithString:@"http://54.172.35.180:8080/api/chatroom"]]) {
                NSLog(@"Text: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                NSNumber *success = (NSNumber *)[json objectForKey:@"success"];
                if([success boolValue] == NO) {
                    NSString *jsonError = [json valueForKeyPath:@"error_code"];
                    if([jsonError isEqualToString:@"103"])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{[self UpdateSessionID:@"CreateChatroom"];});
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{[self CheckResults:json];});
                    
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

- (void)CheckResults:(NSDictionary *)dictionary
{
    NSNumber *success = (NSNumber *)[dictionary objectForKey:@"success"];
    
    NSLog(@"Text: %@", success);
    
    self.Title.text = @"";
    self.Description.text = @"";
    
    if ([success boolValue] == YES) {
        _ErrorCheck.text = @"Room Created";
    }
    else {
        _ErrorCheck.text = @"Failed Room Creation";
    }
}

- (void)UpdateSessionID:(NSString *)method
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:@"http://54.172.35.180:8080/api/login"]];
    
    NSMutableString *param = [[NSMutableString alloc] init];
    
    NSLog(@"Text: %@", self.LoginID);
    
    NSLog(@"Text: %@", self.Password);
    
    [param appendString:[NSString stringWithFormat:@"%@=%@", @"email_id", self.LoginID]];
    
    [param appendString:[NSString stringWithFormat:@"&%@=%@", @"password", self.Password]];
    
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
            if ([request.URL isEqual:[NSURL URLWithString:@"http://54.172.35.180:8080/api/login"]]) {
                NSLog(@"Text: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                dispatch_async(dispatch_get_main_queue(), ^{[self CheckResults:json:method];});
            }
        }
        else
        {
            _ErrorCheck.text = @"Network/Server Error";
        }
    }];
    
    [task resume];
}

- (void)CheckResults:(NSDictionary *)dictionary :(NSString *)method
{
    NSNumber *success = (NSNumber *)[dictionary objectForKey:@"success"];
    
    NSLog(@"Text: %@", success);
    
    if ([success boolValue] == YES) {
        ProfileTBC *tabBar =  (ProfileTBC *)self.tabBarController;
        tabBar.Session_ID = [dictionary objectForKey:@"session_id"];
        self.Session_ID = tabBar.Session_ID;
        if([method isEqualToString:@"CreateChatroom"]){
            [self CreateChatroom:self];
        }
    }
    else {
        _ErrorCheck.text = @"Invalid Session Update";
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //CLLocation *OldLocation = [locations objectAtIndex:[locations indexOfObject:[locations lastObject]]-1];
    CLLocation *NewLocation = [locations lastObject];
    //NSLog(@"OldLocation %f %f", OldLocation.coordinate.latitude, OldLocation.coordinate.longitude);
    //NSLog(@"NewLocation %f %f", NewLocation.coordinate.latitude, NewLocation.coordinate.longitude);
    //NSString *str = @"NewLocation: ";
    //str = [str stringByAppendingString: [NSString stringWithFormat:@"%f %f", NewLocation.coordinate.latitude, NewLocation.coordinate.longitude]];
    self.Latitude = [NSString stringWithFormat:@"%f", NewLocation.coordinate.latitude];
    self.Longitude = [NSString stringWithFormat:@"%f", NewLocation.coordinate.longitude];
    //_ErrorCheck.text = str;
}

@end
