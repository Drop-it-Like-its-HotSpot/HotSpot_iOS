//
//  SignUpViewController.m
//  WebSiteTest
//
//  Created by Ryan Farrell on 11/11/14.
//  Copyright (c) 2014 Ryan Farrell. All rights reserved.
//

#import "SignUpViewController.h"
#import "ProfileTBC.h"

@interface SignUpViewController ()
//@property (nonatomic, strong) NSString *User_ID;
@property (nonatomic, strong) NSString *Session_ID;
@property (nonatomic, strong) NSString *Latitude;
@property (nonatomic, strong) NSString *Longitude;
@property (weak, nonatomic) IBOutlet UITextField *Email;
@property (weak, nonatomic) IBOutlet UITextField *DisplayName;
@property (weak, nonatomic) IBOutlet UITextField *Password;
@property (weak, nonatomic) IBOutlet UITextField *ReEnterPassword;
@property (weak, nonatomic) IBOutlet UITextField *Radius;
@property (weak, nonatomic) IBOutlet UILabel *ErrorCheck;
@property (weak, nonatomic) IBOutlet UIButton *SignIn;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation SignUpViewController

//@synthesize User_ID = _User_ID;
@synthesize Session_ID = _Session_ID;
@synthesize Latitude = _Latitude;
@synthesize Longitude = _Longitude;

-(void)viewDidLoad
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
}

- (IBAction)hideKeyBoard:(id)sender {
    if ([_Email isFirstResponder]) {
        [_Email resignFirstResponder];
    }
    else if ([_DisplayName isFirstResponder]) {
        [_DisplayName resignFirstResponder];
    }
    if ([_Password isFirstResponder]) {
        [_Password resignFirstResponder];
    }
    else if ([_ReEnterPassword isFirstResponder]) {
        [_ReEnterPassword resignFirstResponder];
    }
    else if ([_Radius isFirstResponder]) {
        [_Radius resignFirstResponder];
    }
}

/*- (void)setUser_ID:(NSString *)User_ID
{
    if (!_User_ID) {
        _User_ID = [[NSString alloc] init];
    }
    _User_ID = User_ID;
}*/

- (void)setSession_ID:(NSString *)Session_ID
{
    if (!_Session_ID) {
        _Session_ID = [[NSString alloc] init];
    }
    _Session_ID = Session_ID;
}

- (void)setLatitude:(NSString *)Latitude
{
    if (!_Latitude) {
        _Latitude = [[NSString alloc] init];
    }
    _Latitude = Latitude;
}

- (void)setLongitude:(NSString *)Longitude
{
    if (!_Longitude) {
        _Longitude = [[NSString alloc] init];
    }
    _Longitude = Longitude;
}

-(IBAction)returnKeyButton:(id)sender
{
    [sender resignFirstResponder];
}

- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self deregisterFromKeyboardNotifications];
    
    [super viewWillDisappear:animated];
    
}

- (void)keyboardWasShown:(NSNotification *)notification {
    
    NSDictionary* info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGPoint buttonOrigin = self.SignIn.frame.origin;
    
    CGFloat buttonHeight = self.SignIn.frame.size.height;
    
    CGRect visibleRect = self.view.frame;
    
    visibleRect.size.height -= keyboardSize.height;
    
    if (!CGRectContainsPoint(visibleRect, buttonOrigin)){
        
        CGPoint scrollPoint = CGPointMake(0.0, buttonOrigin.y - visibleRect.size.height + buttonHeight);
        
        [self.scrollView setContentOffset:scrollPoint animated:YES];
        
    }
    
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    
}

- (void)CheckSignUpResults:(NSDictionary *) dictionary
{
    NSNumber *success = (NSNumber *)[dictionary objectForKey:@"success"];
    
    NSLog(@"Text: %@", success);
    
    if ([success boolValue] == YES) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:@"http://54.172.35.180:8080/api/login"]];
        
        NSMutableString *param = [[NSMutableString alloc] init];
        
        [param appendString:[NSString stringWithFormat:@"%@=%@", @"email_id", self.Email.text]];
        
        [param appendString:[NSString stringWithFormat:@"&%@=%@", @"password", self.Password.text]];
        
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
                    dispatch_async(dispatch_get_main_queue(), ^{[self CheckLoginResults:json];});
                }
            }
            else
            {
                _ErrorCheck.text = @"Network/Server Error";
            }
        }];
        
        [task resume];

    }
    else {
        _ErrorCheck.text = @"Invalid Sign Up";
    }
}

- (void)CheckLoginResults:(NSDictionary *) dictionary
{
    NSNumber *success = (NSNumber *)[dictionary objectForKey:@"success"];
    
    NSLog(@"Text: %@", success);
    if ([success boolValue] == YES) {
        //self.User_ID = [dictionary objectForKey:@"user_id"];
        self.Session_ID = [dictionary objectForKey:@"session_id"];
        [self performSegueWithIdentifier:@"GoToProfileFromSignUp" sender:self];
    }
    else {
        _ErrorCheck.text = @"Invalid Login";
    }
}

- (IBAction)SignUp:(id)sender {
    
    if (self.Email.text.length > 0 && self.DisplayName.text.length > 0 && self.Password.text.length > 0 && self.ReEnterPassword.text.length > 0 && self.Radius.text.length > 0) {
        if ([self.Password.text isEqualToString:self.ReEnterPassword.text]){
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:@"http://54.172.35.180:8080/api/users"]];
            
            NSMutableString *param = [[NSMutableString alloc] init];
            
            [param appendString:[NSString stringWithFormat:@"%@=%@", @"email_id", self.Email.text]];
            
            [param appendString:[NSString stringWithFormat:@"&%@=%@", @"password", self.Password.text]];
            
            [param appendString:[NSString stringWithFormat:@"&%@=%@", @"latitude", self.Latitude]];
            
            [param appendString:[NSString stringWithFormat:@"&%@=%@", @"longitude", self.Longitude]];
            
            [param appendString:[NSString stringWithFormat:@"&%@=%@", @"displayname", self.DisplayName.text]];
            
            [param appendString:[NSString stringWithFormat:@"&%@=%@", @"radius", self.Radius.text]];
            
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[param dataUsingEncoding:NSUTF8StringEncoding]];
            
            //[request setHTTPBody:jsonData];
            
            // another configuration option is backgroundSessionConfiguration (multitasking API required though)
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
            
            // create the session without specifying a queue to run completion handler on (thus, not main queue)
            // we also don't specify a delegate (since completion handler is all we need)
            NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
            
            NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (!error)
                {
                    if ([request.URL isEqual:[NSURL URLWithString:@"http://54.172.35.180:8080/api/users"]]) {
                        NSLog(@"Text: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                        dispatch_async(dispatch_get_main_queue(), ^{[self CheckSignUpResults:json];});
                    }
                }
                else
                {
                    _ErrorCheck.text = @"Network/Server Error";
                }

            }];
            
            [task resume];
        }
        else {
            _ErrorCheck.text = @"Passwords Do Not Match";
        }
    }
    else {
        _ErrorCheck.text = @"Incomplete Registration Form";
    }
    
}

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GoToProfileFromSignUp"]) {
        if ([segue.destinationViewController isKindOfClass:[ProfileTBC class]]) {
            ProfileTBC *ptbc = (ProfileTBC *)segue.destinationViewController;
            ptbc.Session_ID = self.Session_ID;
            ptbc.LoginID = self.Email.text;
            ptbc.Password = self.Password.text;
            ptbc.Latitude = self.Latitude;
            ptbc.Longitude = self.Longitude;
        }
    }
}

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
