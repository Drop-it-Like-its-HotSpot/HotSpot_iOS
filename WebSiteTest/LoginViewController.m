//
//  LoginViewController.m
//  WebSiteTest
//
//  Created by Ryan Farrell on 7/11/14.
//  Copyright (c) 2014 Ryan Farrell. All rights reserved.
//

//#import "SignUpViewController.h"
#import "ProfileTBC.h"
#import "LoginViewController.h"

@interface LoginViewController ()
//@property (nonatomic, strong) NSString *User_ID;
@property (nonatomic, strong) NSString *Session_ID;
@property (nonatomic, strong) NSString *Latitude;
@property (nonatomic, strong) NSString *Longitude;
@property (weak, nonatomic) IBOutlet UITextField *LoginID;
@property (weak, nonatomic) IBOutlet UITextField *Password;
@property (weak, nonatomic) IBOutlet UILabel *ErrorCheck;
@property (weak, nonatomic) IBOutlet UIButton *SignUp;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation LoginViewController

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

- (IBAction)hideKeyboard:(id)sender {
    if ([_LoginID isFirstResponder]) {
        [_LoginID resignFirstResponder];
    }
    else if ([_Password isFirstResponder]) {
        [_Password resignFirstResponder];
    }
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
    
    CGPoint buttonOrigin = self.SignUp.frame.origin;
    
    CGFloat buttonHeight = self.SignUp.frame.size.height;
    
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


/*-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Text: ");
    if ([_LoginID isFirstResponder]) {
        [_LoginID resignFirstResponder];
    }
    else if ([_Password isFirstResponder]) {
        [_Password resignFirstResponder];
    }
}*/


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

- (void)CheckResults:(NSDictionary *) dictionary
{
    NSNumber *success = (NSNumber *)[dictionary objectForKey:@"success"];
    
    NSLog(@"Text: %@", success);
    
    if ([success boolValue] == YES) {
        //self.User_ID = [dictionary objectForKey:@"user_id"];
        self.Session_ID = [dictionary objectForKey:@"session_id"];
        //NSLog(@"Text: %@", self.User_ID);
        NSLog(@"Text: %@", self.Session_ID);
        [self performSegueWithIdentifier:@"GoToProfileFromLogin" sender:self];
    }
    else {
        _ErrorCheck.text = @"Invalid Login";
    }
}

- (IBAction)Login:(id)sender {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:@"http://54.172.35.180:8080/api/login"]];
    
    NSMutableString *param = [[NSMutableString alloc] init];
    
    NSLog(@"Text: %@", self.LoginID.text);
    
    NSLog(@"Text: %@", self.Password.text);
    
    [param appendString:[NSString stringWithFormat:@"%@=%@", @"email_id", self.LoginID.text]];
    
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
                dispatch_async(dispatch_get_main_queue(), ^{[self CheckResults:json];});
            }
        }
        else
        {
            _ErrorCheck.text = @"Network/Server Error";
        }
    }];
    
    [task resume];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GoToProfileFromLogin"]) {
        if ([segue.destinationViewController isKindOfClass:[ProfileTBC class]]) {
            ProfileTBC *ptbc = (ProfileTBC *)segue.destinationViewController;
            NSString *str = @"http://54.172.35.180:8080/api/chatroom/";
            str = [str stringByAppendingString: self.Session_ID];
            NSLog(@"Text: %@", str);
            //pvc.User_ID = self.User_ID;
            ptbc.Session_ID = self.Session_ID;
            ptbc.LoginID = self.LoginID.text;
            ptbc.Password = self.Password.text;
            ptbc.Latitude = self.Latitude;
            ptbc.Longitude = self.Longitude;
        }
    }
    
    /*if ([segue.identifier isEqualToString:@"GoToSignUpFromLogin"]) {
        if ([segue.destinationViewController isKindOfClass:[SignUpViewController class]]) {
            //SignUpViewController *suvc = (SignUpViewController *)segue.destinationViewController;
        }
    }*/
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
