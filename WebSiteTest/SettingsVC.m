//
//  SettingsVC.m
//  WebSiteTest
//
//  Created by Ryan Farrell on 11/30/14.
//  Copyright (c) 2014 Ryan Farrell. All rights reserved.
//

#import "SettingsVC.h"
#import "ProfileTBC.h"

@interface SettingsVC ()
@property (weak, nonatomic) IBOutlet UILabel *ErrorCheck;
@property (nonatomic, strong) NSString *Session_ID;
@property (nonatomic, strong) NSString *Latitude;
@property (nonatomic, strong) NSString *Longitude;
@property (nonatomic, strong) NSString *LoginID;
@property (nonatomic, strong) NSString *Password;

@end

@implementation SettingsVC

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

- (IBAction)UpdateProfile:(id)sender {
    [self performSegueWithIdentifier:@"GoToUpdateProfileFromSettings" sender:self];
}

- (IBAction)Logout:(id)sender {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:@"http://54.172.35.180:8080/api/logout"]];
    
    NSMutableString *param = [[NSMutableString alloc] init];
    
    [param appendString:[NSString stringWithFormat:@"%@=%@", @"email_id", self.LoginID]];
    
    //[param appendString:[NSString stringWithFormat:@"&%@=%@", @"session_id", self.Session_ID]];
    
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
            if ([request.URL isEqual:[NSURL URLWithString:@"http://54.172.35.180:8080/api/logout"]]) {
                NSLog(@"Text: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                NSNumber *success = (NSNumber *)[json objectForKey:@"success"];
                if([success boolValue] == NO) {
                    NSString *jsonError = [json valueForKeyPath:@"error_code"];
                    if([jsonError isEqualToString:@"103"])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{[self UpdateSessionID:@"Logout"];});
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{[self dismissViewControllerAnimated:YES completion:nil];});
                    
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
        if([method isEqualToString:@"Logout"]){
            [self Logout:self];
        }
    }
    else {
        _ErrorCheck.text = @"Invalid Session Update";
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //
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
