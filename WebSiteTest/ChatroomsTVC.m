//
//  ChatroomsTVC.m
//  WebSiteTest
//
//  Created by Ryan Farrell on 11/23/14.
//  Copyright (c) 2014 Ryan Farrell. All rights reserved.
//

#import "ChatroomsTVC.h"
#import "MessagesTVC.h"
#import "ProfileTBC.h"
#import "AppDelegate.h"
#import "Chatroom.h"
#import "CreateChatroom.h"

@interface ChatroomsTVC ()
@property (nonatomic, strong) NSArray *chatrooms;
@property (nonatomic, strong) NSArray *joinedChatrooms;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *ErrorCheck;
@property (nonatomic, strong) NSString *Session_ID;
@property (nonatomic, strong) NSString *Latitude;
@property (nonatomic, strong) NSString *Longitude;
@property (nonatomic, strong) NSString *LoginID;
@property (nonatomic, strong) NSString *Password;

@end

@implementation ChatroomsTVC

@synthesize chatrooms = _chatrooms;
@synthesize joinedChatrooms = _joinedChatrooms;
@synthesize Session_ID = _Session_ID;
@synthesize Latitude = _Latitude;
@synthesize Longitude = _Longitude;
@synthesize LoginID = _LoginID;
@synthesize Password = _Password;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    _managedObjectContext = [appDelegate managedObjectContext];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    /*if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
     {
     [self.locationManager requestWhenInUseAuthorization];
     }*/
    
    [locationManager startUpdatingLocation];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
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
    _chatrooms = chatrooms;
    
    [self.tableView reloadData];
}

-(void)setJoinedChatrooms:(NSArray *)joinedChatrooms
{
    if (!_joinedChatrooms) {
        _joinedChatrooms = [[NSArray alloc] init];
    }
    _joinedChatrooms = joinedChatrooms;
    
    [self UpdateChatrooms];
}

- (IBAction)manualDownload:(id)sender {
    [self UpdateLocation];
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

#pragma mark - UITableViewDataSource

// the methods in this protocol are what provides the View its data
// (remember that Views are not allowed to own their data)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return @"Joined Chatrooms";
    }
    else
    {
        return @"Nearby Chatrooms";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section (we only have one)
    if(section == 0)
    {
        return [self.joinedChatrooms count];
    }
    else
    {
        return [self.chatrooms count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // we must be sure to use the same identifier here as in the storyboard!
    static NSString *CellIdentifier = @"ChatroomCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    // get the photo out of our Model
    NSDictionary *chatroom;
    if(indexPath.section == 0)
    {
       chatroom = self.joinedChatrooms[indexPath.row];
    }
    else
    {
        chatroom = self.chatrooms[indexPath.row];
    }
    
    // update UILabels in the UITableViewCell
    // valueForKeyPath: supports "dot notation" to look inside dictionaries at other dictionaries
    cell.textLabel.text = [chatroom valueForKeyPath:@"Chat_title"];
    cell.detailTextLabel.text = [chatroom valueForKeyPath:@"Chat_Dscrpn"];
    
    return cell;
}

// prepares the given ImageViewController to show the given photo
// used either when segueing to an ImageViewController
//   or when our UISplitViewController's Detail view controller is an ImageViewController

- (void)prepareChatroomViewController:(MessagesTVC *)mtvc toDisplayRoom:(NSDictionary *)chatroom chatType:(NSString *)type
{
    
    
    //crvc.User_ID = self.User_ID;
    //mtvc.Session_ID = self.Session_ID;
    mtvc.Room_ID = [chatroom valueForKeyPath:@"chat_id"];
    mtvc.chat_type = type;
    mtvc.Session_ID = self.Session_ID;
    mtvc.LoginID = self.LoginID;
    mtvc.Password = self.Password;
    //mtvc.profileURL = [NSURL URLWithString: @"http://54.172.35.180:8080/api/chatroomusers"];
    //crvc.imageURL = [NSURL URLWithString: @"http://54.172.35.180:8080/api/chatrooms"];
    mtvc.title = [chatroom valueForKeyPath:@"Chat_title"];
}

// In a story board-based application, you will often want to do a little preparation before navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        // find out which row in which section we're seguing from
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        /*UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
         
         NSString *chatTitle = cell.textLabel.text;
         NSString *chatDescription = cell.detailTextLabel.text;*/
        if (indexPath.section == 0) {
            // found it ... are we doing the Display Photo segue?
            if ([segue.identifier isEqualToString:@"GoToMessagesFromChatrooms"]) {
                // yes ... is the destination an ImageViewController?
                if ([segue.destinationViewController isKindOfClass:[MessagesTVC class]]) {
                    // yes ... then we know how to prepare for that segue!
                    /*Chatroom *chatroomObj = [NSEntityDescription insertNewObjectForEntityForName:@"Chatroom" inManagedObjectContext:_managedObjectContext];
                    [chatroomObj setTitle:[self.chatrooms[indexPath.row] valueForKeyPath:@"Chat_title"]];
                    [chatroomObj setSubtitle:[self.chatrooms[indexPath.row] valueForKeyPath:@"Chat_Dscrpn"]];
                    [chatroomObj setChat_id:[self.chatrooms[indexPath.row] valueForKeyPath:@"chat_id"]];
                    [chatroomObj setRoom_admin:[self.chatrooms[indexPath.row] valueForKeyPath:@"Room_Admin"]];
                    [chatroomObj setLatitude:[self.chatrooms[indexPath.row] valueForKeyPath:@"Latitude"]];
                    [chatroomObj setLongitude:[self.chatrooms[indexPath.row] valueForKeyPath:@"Longitude"]];
                    NSDate *currentDate = [NSDate date];
                    [chatroomObj setTime_stamp:currentDate];
                    
                    NSLog(@"Text: %@", currentDate);*/
                    [self prepareChatroomViewController:segue.destinationViewController toDisplayRoom:self.joinedChatrooms[indexPath.row]chatType:@"joinedChatroom"];
                }
            }

        }
        else if (indexPath) {
            // found it ... are we doing the Display Photo segue?
            if ([segue.identifier isEqualToString:@"GoToMessagesFromChatrooms"]) {
                // yes ... is the destination an ImageViewController?
                if ([segue.destinationViewController isKindOfClass:[MessagesTVC class]]) {
                    // yes ... then we know how to prepare for that segue!
                    /*Chatroom *chatroomObj = [NSEntityDescription insertNewObjectForEntityForName:@"Chatroom" inManagedObjectContext:_managedObjectContext];
                    [chatroomObj setTitle:[self.chatrooms[indexPath.row] valueForKeyPath:@"Chat_title"]];
                    [chatroomObj setSubtitle:[self.chatrooms[indexPath.row] valueForKeyPath:@"Chat_Dscrpn"]];
                    [chatroomObj setChat_id:[self.chatrooms[indexPath.row] valueForKeyPath:@"chat_id"]];
                    [chatroomObj setRoom_admin:[self.chatrooms[indexPath.row] valueForKeyPath:@"Room_Admin"]];
                    [chatroomObj setLatitude:[self.chatrooms[indexPath.row] valueForKeyPath:@"Latitude"]];
                    [chatroomObj setLongitude:[self.chatrooms[indexPath.row] valueForKeyPath:@"Longitude"]];
                    NSDate *currentDate = [NSDate date];
                    [chatroomObj setTime_stamp:currentDate];
                    
                    NSLog(@"Text: %@", currentDate);*/
                    [self prepareChatroomViewController:segue.destinationViewController toDisplayRoom:self.chatrooms[indexPath.row]chatType:@"chatroom"];
                }
            }
        }
    }
    
    /*if ([segue.identifier isEqualToString:@"GoToCreateChatroomFromList"]) {
        if ([segue.destinationViewController isKindOfClass:[CreateChatroom class]]) {
            CreateChatroom *ptbc = (CreateChatroom *)segue.destinationViewController;
        }
    }*/
}

- (IBAction)CreateChatroom:(id)sender {
    [self performSegueWithIdentifier:@"GoToCreateChatroomFromList" sender:self];
}

- (IBAction)Settings:(id)sender {
    [self performSegueWithIdentifier:@"GoToSettingsFromList" sender:self];
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
