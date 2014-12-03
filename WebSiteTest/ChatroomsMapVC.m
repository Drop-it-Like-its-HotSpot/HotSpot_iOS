//
//  ChatroomsMapVC.m
//  WebSiteTest
//
//  Created by Ryan Farrell on 11/23/14.
//  Copyright (c) 2014 Ryan Farrell. All rights reserved.
//

#import "ChatroomsMapVC.h"
#import "MessagesTVC.h"
#import "ProfileTBC.h"
#import "AppDelegate.h"
#import "Chatroom.h"
#import <MapKit/MapKit.h>
#import "MapAnnotation.h"

@interface ChatroomsMapVC () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *ErrorCheck;
@property (nonatomic, strong) NSArray *chatrooms;
@property (nonatomic, strong) NSArray *joinedChatrooms;
@property (nonatomic, strong) NSString *Session_ID;
@property (nonatomic, strong) NSString *Latitude;
@property (nonatomic, strong) NSString *Longitude;
@property (nonatomic, strong) NSString *LoginID;
@property (nonatomic, strong) NSString *Password;

@end

@implementation ChatroomsMapVC

@synthesize chatrooms = _chatrooms;
@synthesize joinedChatrooms = _joinedChatrooms;
@synthesize Session_ID = _Session_ID;
@synthesize Latitude = _Latitude;
@synthesize Longitude = _Longitude;
@synthesize LoginID = _LoginID;
@synthesize Password = _Password;

-(void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    self.mapView.delegate = self;
}

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
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    _managedObjectContext = [appDelegate managedObjectContext];
    
    ProfileTBC *tabBar =  (ProfileTBC *)self.tabBarController;
    self.Session_ID = (NSString *)tabBar.Session_ID;
    self.LoginID = (NSString *)tabBar.LoginID;
    self.Password = (NSString *)tabBar.Password;
    self.Latitude = (NSString *)tabBar.Latitude;
    self.Longitude = (NSString *)tabBar.Longitude;
    
    [self UpdateLocation];
    
}

-(void)setChatrooms:(NSArray *)chatrooms
{
    if (!_chatrooms) {
        _chatrooms = [[NSArray alloc] init];
    }
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    for (NSDictionary *chatroom in chatrooms) {
        
        /* MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
         
         CLLocationCoordinate2D coordinate;
         coordinate.latitude = [[chatroom valueForKeyPath:@"Latitude"] doubleValue];
         coordinate.longitude = [[chatroom valueForKeyPath:@"Longitude"] doubleValue];
         annotation.coordinate = coordinate;
         
         annotation.title = [chatroom valueForKeyPath:@"Chat_title"];
         annotation.subtitle = [chatroom valueForKeyPath:@"Chat_Dscrpn"];
         
         [temp addObject:annotation];*/
        
        MapAnnotation *anot = [[MapAnnotation alloc] init];
        anot.chat_title = [chatroom valueForKeyPath:@"Chat_title"];
        anot.chat_dscrpn = [chatroom valueForKeyPath:@"Chat_Dscrpn"];
        anot.latitude = [chatroom valueForKeyPath:@"Latitude"];
        anot.longitude = [chatroom valueForKeyPath:@"Longitude"];
        anot.chat_id = [chatroom valueForKeyPath:@"chat_id"];
        anot.chat_type = @"chatroom";
        
        [temp addObject:anot];
        
        /*Chatroom *chatroomObj = [[Chatroom alloc] init];
         [chatroomObj setTitle:[chatroom valueForKeyPath:@"Chat_title"]];
         [chatroomObj setSubtitle:[chatroom valueForKeyPath:@"Chat_Dscrpn"]];
         [chatroomObj setLatitude:[chatroom valueForKeyPath:@"Latitude"]];
         [chatroomObj setLongitude:[chatroom valueForKeyPath:@"Longitude"]];
         [chatroomObj setRoom_admin:[chatroom valueForKeyPath:@"Room_Admin"]];
         [chatroomObj setChat_id:[chatroom valueForKeyPath:@"chat_id"]];
         [temp addObject:chatroomObj];*/
        
    }
    
    /*for (NSDictionary *chatroom in chatrooms) {
     Chatroom *chatroomObj = [[Chatroom alloc] init];
     [chatroomObj setTitle:[chatroom valueForKeyPath:@"Chat_title"]];
     [chatroomObj setSubtitle:[chatroom valueForKeyPath:@"Chat_Dscrpn"]];
     [chatroomObj setLatitude:[chatroom valueForKeyPath:@"Latitude"]];
     [chatroomObj setLongitude:[chatroom valueForKeyPath:@"Longitude"]];
     [chatroomObj setRoom_admin:[chatroom valueForKeyPath:@"Room_Admin"]];
     [chatroomObj setChat_id:[chatroom valueForKeyPath:@"chat_id"]];
     [temp addObject:chatroomObj];
     }*/
    
    _chatrooms = [temp copy];
    
    [self updateMapViewAnnotations];
}

-(void)setJoinedChatrooms:(NSArray *)joinedChatrooms
{
    if (!_joinedChatrooms) {
        _joinedChatrooms = [[NSArray alloc] init];
    }
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    for (NSDictionary *chatroom in joinedChatrooms) {
        
        /* MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
         
         CLLocationCoordinate2D coordinate;
         coordinate.latitude = [[chatroom valueForKeyPath:@"Latitude"] doubleValue];
         coordinate.longitude = [[chatroom valueForKeyPath:@"Longitude"] doubleValue];
         annotation.coordinate = coordinate;
         
         annotation.title = [chatroom valueForKeyPath:@"Chat_title"];
         annotation.subtitle = [chatroom valueForKeyPath:@"Chat_Dscrpn"];
         
         [temp addObject:annotation];*/
        
        MapAnnotation *anot = [[MapAnnotation alloc] init];
        anot.chat_title = [chatroom valueForKeyPath:@"Chat_title"];
        anot.chat_dscrpn = [chatroom valueForKeyPath:@"Chat_Dscrpn"];
        anot.latitude = [chatroom valueForKeyPath:@"Latitude"];
        anot.longitude = [chatroom valueForKeyPath:@"Longitude"];
        anot.chat_id = [chatroom valueForKeyPath:@"chat_id"];
        anot.chat_type = @"joinedChatroom";
        
        [temp addObject:anot];
        
        /*Chatroom *chatroomObj = [[Chatroom alloc] init];
         [chatroomObj setTitle:[chatroom valueForKeyPath:@"Chat_title"]];
         [chatroomObj setSubtitle:[chatroom valueForKeyPath:@"Chat_Dscrpn"]];
         [chatroomObj setLatitude:[chatroom valueForKeyPath:@"Latitude"]];
         [chatroomObj setLongitude:[chatroom valueForKeyPath:@"Longitude"]];
         [chatroomObj setRoom_admin:[chatroom valueForKeyPath:@"Room_Admin"]];
         [chatroomObj setChat_id:[chatroom valueForKeyPath:@"chat_id"]];
         [temp addObject:chatroomObj];*/
        
    }
    
    /*for (NSDictionary *chatroom in chatrooms) {
     Chatroom *chatroomObj = [[Chatroom alloc] init];
     [chatroomObj setTitle:[chatroom valueForKeyPath:@"Chat_title"]];
     [chatroomObj setSubtitle:[chatroom valueForKeyPath:@"Chat_Dscrpn"]];
     [chatroomObj setLatitude:[chatroom valueForKeyPath:@"Latitude"]];
     [chatroomObj setLongitude:[chatroom valueForKeyPath:@"Longitude"]];
     [chatroomObj setRoom_admin:[chatroom valueForKeyPath:@"Room_Admin"]];
     [chatroomObj setChat_id:[chatroom valueForKeyPath:@"chat_id"]];
     [temp addObject:chatroomObj];
     }*/
    
    _joinedChatrooms = [temp copy];
    
    [self UpdateChatrooms];
}

- (IBAction)manualDownload:(id)sender {
    [self UpdateLocation];
}

- (void)updateMapViewAnnotations
{
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (MapAnnotation *chatroom in _joinedChatrooms) {
        [temp addObject:chatroom];
    }
    for (MapAnnotation *chatroom in _chatrooms) {
        [temp addObject:chatroom];
    }
    _chatrooms = [temp copy];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:self.chatrooms];
    [self.mapView showAnnotations:self.chatrooms animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *reuseId = @"ChatroomsMapVC";
    //MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    
    //if (!view) {
        MKPinAnnotationView *view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                               reuseIdentifier:reuseId];
            MapAnnotation *test = annotation;
    if([test.chat_type isEqualToString:@"joinedChatroom"])
    {
        view.pinColor = MKPinAnnotationColorGreen;
    }
                view.canShowCallout = YES;
        //UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 46, 46)];
        //view.leftCalloutAccessoryView = imageView;
        UIButton *disclosureButton = [[UIButton alloc] init];
        [disclosureButton setBackgroundImage:[UIImage imageNamed:@"disclosure"] forState:UIControlStateNormal];
        [disclosureButton sizeToFit];
        view.rightCalloutAccessoryView = disclosureButton;
    //}

    view.annotation = annotation;
    
    return view;
}

// called when the right callout accessory view is tapped
// (it is the only accessory view we have that inherits from UIControl)
// will crash the program if this View Controller does not have a @"Show Photo" segue
// in the storyboard

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"GoToMessagesFromMap" sender:view];
}

#pragma mark - Navigation

// if the annotation is a Photo, this passes its imageURL to vc (if vc is an ImageViewController)

- (void)prepareChatroomViewController:(MessagesTVC *)mtvc toShowAnnotation:(id <MKAnnotation>)annotation
{
    MapAnnotation *anot = (MapAnnotation *)annotation;
    
    //crvc.User_ID = self.User_ID;
    
    NSLog(@"Text: %@", anot.chat_id);
    NSLog(@"Text: %@", anot.title);
    
    //mtvc.Session_ID = self.Session_ID;
    mtvc.Room_ID = anot.chat_id;
    mtvc.chat_type = anot.chat_type;
    mtvc.Session_ID = self.Session_ID;
    mtvc.LoginID = self.LoginID;
    mtvc.Password = self.Password;
    //mtvc.profileURL = [NSURL URLWithString: @"http://54.172.35.180:8080/api/chatroomusers"];
    //crvc.imageURL = [NSURL URLWithString: @"http://54.172.35.180:8080/api/chatrooms"];
    mtvc.title = anot.title;
}

/*- (void)prepareViewController:(id)vc
                     forSegue:(NSString *)segueIdentifier
             toShowAnnotation:(id <MKAnnotation>)annotation
{
    Photo *photo = nil;
    if ([annotation isKindOfClass:[Photo class]]) {
        photo = (Photo *)annotation;
    }
    if (photo) {
        if (![segueIdentifier length] || [segueIdentifier isEqualToString:@"Show Photo"]) {
            if ([vc isKindOfClass:[ImageViewController class]]) {
                ImageViewController *ivc = (ImageViewController *)vc;
                ivc.imageURL = [NSURL URLWithString:photo.imageURL];
                ivc.title = photo.title;
            }
        }
    }
}*/

// if sender is an MKAnnotationView, this calls prepareViewController:forSegue:toShowAnnotation:

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GoToMessagesFromMap"]) {
        if ([sender isKindOfClass:[MKAnnotationView class]]) {
            [self prepareChatroomViewController:segue.destinationViewController toShowAnnotation:((MKAnnotationView *)sender).annotation];
        }
    }
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
                    if([jsonError isEqualToString:@"103"])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{[self UpdateSessionID:@"UpdateLocation"];});
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{[self UpdateJoinedChatrooms];});
                    
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

- (void)UpdateJoinedChatrooms
{
    self.joinedChatrooms = nil;
    
    //if (self.profileURL)
    //{
    NSString *str = @"http://54.172.35.180:8080/api/chatroomusers/user_id/";
    str = [str stringByAppendingString: self.Session_ID];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:str]];
    
    //NSMutableString *param = [[NSMutableString alloc] init];
    
    //[param appendString:[NSString stringWithFormat:@"%@=%@", @"session_id", self.Session_ID]];
    
    [request setHTTPMethod:@"GET"];
    //[request setHTTPBody:[param dataUsingEncoding:NSUTF8StringEncoding]];
    
    // another configuration option is backgroundSessionConfiguration (multitasking API required though)
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    
    // create the session without specifying a queue to run completion handler on (thus, not main queue)
    // we also don't specify a delegate (since completion handler is all we need)
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error)
        {
            NSLog(@"Text: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSArray *chatrooms = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if([chatrooms count] != 0) {
                NSLog(@"Text: %@", [chatrooms objectAtIndex:0]);
                NSString *jsonError = [[chatrooms objectAtIndex:0] valueForKeyPath:@"error_code"];
                if([jsonError isEqualToString:@"103"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{[self UpdateSessionID:@"UpdateJoinedChatrooms"];});
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{self.joinedChatrooms = chatrooms;});
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{self.joinedChatrooms = chatrooms;});
            }
        }
        else
        {
            _ErrorCheck.text = @"Network/Server Error";
        }
    }];
    
    [task resume];
    //}
}

- (void)UpdateChatrooms
{
    self.chatrooms = nil;
    
    //if (self.profileURL)
    //{
    NSString *str = @"http://54.172.35.180:8080/api/chatroom/";
    str = [str stringByAppendingString: self.Session_ID];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:str]];
    
    //NSMutableString *param = [[NSMutableString alloc] init];
    
    //[param appendString:[NSString stringWithFormat:@"%@=%@", @"session_id", self.Session_ID]];
    
    [request setHTTPMethod:@"GET"];
    //[request setHTTPBody:[param dataUsingEncoding:NSUTF8StringEncoding]];
    
    // another configuration option is backgroundSessionConfiguration (multitasking API required though)
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    
    // create the session without specifying a queue to run completion handler on (thus, not main queue)
    // we also don't specify a delegate (since completion handler is all we need)
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error)
        {
            NSLog(@"Text: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSArray *chatrooms = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if([chatrooms count] != 0) {
                NSLog(@"Text: %@", [chatrooms objectAtIndex:0]);
                NSString *jsonError = [[chatrooms objectAtIndex:0] valueForKeyPath:@"error_code"];
                if([jsonError isEqualToString:@"103"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{[self UpdateSessionID:@"UpdateChatrooms"];});
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{self.chatrooms = chatrooms;});
                }
            }
        }
        else
        {
            _ErrorCheck.text = @"Network/Server Error";
        }
    }];
    
    [task resume];
    //}
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
        if([method isEqualToString:@"UpdateLocation"]){
            [self UpdateLocation];
        }
        else if([method isEqualToString:@"UpdateChatrooms"]){
            [self UpdateChatrooms];
        }
        else if([method isEqualToString:@"UpdateJoinedChatrooms"]){
            [self UpdateJoinedChatrooms];
        }
    }
    else {
        _ErrorCheck.text = @"Invalid Session Update";
    }
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

- (IBAction)CreateChatroom:(id)sender {
    [self performSegueWithIdentifier:@"GoToCreateChatroomFromMap" sender:self];
}

- (IBAction)Settings:(id)sender {
    [self performSegueWithIdentifier:@"GoToSettingsFromMap" sender:self];
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
