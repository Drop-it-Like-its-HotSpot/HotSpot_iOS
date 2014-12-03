//
//  MessagesTVC.m
//  WebSiteTest
//
//  Created by Ryan Farrell on 11/23/14.
//  Copyright (c) 2014 Ryan Farrell. All rights reserved.
//

/*#import "MessagesTVC.h"
#import "AppDelegate.h"
#import "Chatroom.h"
#import "Messages.h"
#import <CoreData/CoreData.h>

@interface MessagesTVC ()
@property (nonatomic, strong) NSMutableArray *messages;
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MessagesTVC

@synthesize messages = _messages;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    _managedObjectContext = [appDelegate managedObjectContext];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //NSFetchRequest *request = [[NSFetchRequest alloc]init];
     //NSEntityDescription *chatroomObj = [NSEntityDescription entityForName:@"Chatroom" inManagedObjectContext:_managedObjectContext];
     //[request setEntity:chatroomObj];
     //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"chat_title" ascending:YES];
     //NSArray *sortDescriptors = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
     //[request setSortDescriptors:sortDescriptors];
     
     //NSError *error = nil;
     //_messages = [[_managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
     //if(_messages == nil)
     //{
     //handle error
     //}
     
     //[self.tableView reloadData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setMessages:(NSMutableArray *)messages
{
    if (!_messages) {
        _messages = [[NSMutableArray alloc] init];
    }
    _messages = messages;
}


-(void)setProfileURL:(NSURL *)profileURL
{
    if (!_profileURL) {
        _profileURL = [[NSURL alloc] init];
    }
    _profileURL = profileURL;
    
    [self startDownloadingProfile];
}

-(void)updateMessages:(NSArray *)messages
{
    for (NSDictionary *message in messages) {
        Messages *messageObj = [NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:_managedObjectContext];
        [messageObj setChat_id:[message valueForKeyPath:@"Room_id"]];
        [messageObj setM_id:[message valueForKeyPath:@"m_id"]];
        [messageObj setUser_id:[message valueForKeyPath:@"User_id"]];
        //[messageObj setTime_stamp:(NSDate *)[message valueForKeyPath:@"TimeStamp"]];
        
        NSString *myDateString = [message valueForKeyPath:@"TimeStamp"];
        
        NSLog(@"Text%@", myDateString);
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:locale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
        
        NSDate *myDate = [dateFormatter dateFromString:myDateString];
        NSLog(@"Text%@", myDate);
        
        [messageObj setTime_stamp:myDate];
        [messageObj setMessage:[message valueForKeyPath:@"Message"]];
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    request.predicate = [NSPredicate predicateWithFormat:@"chat_id = %@", self.Room_ID];
    NSEntityDescription *messageObj = [NSEntityDescription entityForName:@"Messages" inManagedObjectContext:_managedObjectContext];
    [request setEntity:messageObj];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"time_stamp" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    _messages = [[_managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
    if(_messages == nil)
    {
        //handle error
    }
    
    [self.tableView reloadData];
}

- (void)joinChat:(NSNumber *)success
{
    if ([success boolValue] == YES) {
        
        NSFetchRequest *req = [[NSFetchRequest alloc]init];
        req.predicate = [NSPredicate predicateWithFormat:@"chat_id = %@", self.Room_ID];
        NSEntityDescription *chatroomObj = [NSEntityDescription entityForName:@"Chatroom" inManagedObjectContext:_managedObjectContext];
        [req setEntity:chatroomObj];
        
        NSError *error = nil;
        NSArray *room = [[_managedObjectContext executeFetchRequest:req error:&error]mutableCopy];
        Chatroom *chat = (Chatroom *)[room objectAtIndex:0];
        
        NSDate *pastDate = [chat time_stamp];
        NSDateComponents *comps =[[NSDateComponents alloc] init];
        [comps setDay:-10];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        pastDate = [calendar dateByAddingComponents:comps toDate:pastDate options:0];
        NSLog(@"Text: %@", pastDate);
        NSDate *currentDate = [NSDate date];
        NSLog(@"Text: %@", currentDate);
        
        [chat setValue:currentDate forKeyPath:@"time_stamp"];
        
        [self.managedObjectContext save:nil];
        
        NSString *str = @"http://54.172.35.180:8080/api/messages/room_id/";
        str = [str stringByAppendingString: [NSString stringWithFormat:@"%@/%@/%@", self.Room_ID, pastDate, self.Session_ID]];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        NSLog(@"Text: %@", str);
        
        NSLog(@"Test: %@", request.URL.description);
        
        //NSMutableString *param = [[NSMutableString alloc] init];
        
        //[param appendString:[NSString stringWithFormat:@"%@=%@", @"session_id", self.Session_ID]];
        //[param appendString:[NSString stringWithFormat:@"&%@=%@", @"user_id", self.User_ID]];
        //[param appendString:[NSString stringWithFormat:@"&%@=%@", @"room_id", self.Room_ID]];
        
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
                NSArray *messages = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                NSLog(@"Text: %@", messages);
                dispatch_async(dispatch_get_main_queue(), ^{[self updateMessages:messages];});
            }
        }];
        
        [task resume];
        
    }
}

- (void)startDownloadingProfile
{
    //self.chatrooms = nil;
    
    if (self.profileURL)
    {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.profileURL];
        
        NSMutableString *param = [[NSMutableString alloc] init];
        
        [param appendString:[NSString stringWithFormat:@"%@=%@", @"session_id", self.Session_ID]];
        //[param appendString:[NSString stringWithFormat:@"&%@=%@", @"user_id", self.User_ID]];
        [param appendString:[NSString stringWithFormat:@"&%@=%@", @"room_id", self.Room_ID]];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[param dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSLog(@"Text: %@", request.URL.description);
        
        // another configuration option is backgroundSessionConfiguration (multitasking API required though)
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
        // create the session without specifying a queue to run completion handler on (thus, not main queue)
        // we also don't specify a delegate (since completion handler is all we need)
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error)
            {
                if ([request.URL isEqual:self.profileURL]) {
                    NSLog(@"Text: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                    NSDictionary *joinChat = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                    NSLog(@"Text: %@", joinChat);
                    //NSNumber *success = (NSNumber *)[joinChat objectForKey:@"success"];
                    NSNumber *success = [[NSNumber alloc ] initWithBool:TRUE];
                    NSLog(@"Text: %@", success);
                    dispatch_async(dispatch_get_main_queue(), ^{[self joinChat:success];});
                }
            }
        }];
        
        [task resume];
    }
}

#pragma mark - Table view data source

#pragma mark - UITableViewDataSource

// the methods in this protocol are what provides the View its data
// (remember that Views are not allowed to own their data)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section (we only have one)
    NSLog(@"Text: %lu", (unsigned long)[self.messages count]);
    
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // we must be sure to use the same identifier here as in the storyboard!
    static NSString *CellIdentifier = @"MessageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    // get the photo out of our Model
    Messages *message = (Messages *)[self.messages objectAtIndex:indexPath.row];
    
    NSLog(@"Text: %@", [message user_id]);
    NSLog(@"Text: %@", [message message]);
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[message user_id]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[message message]];
    
    // update UILabels in the UITableViewCell
    // valueForKeyPath: supports "dot notation" to look inside dictionaries at other dictionaries
    
    return cell;
}

-(void)updateMessagesForSentMessage:(NSDictionary *)message
{
    Messages *messageObj = [NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:_managedObjectContext];
    [messageObj setChat_id:[message valueForKeyPath:@"Room_id"]];
    [messageObj setM_id:[message valueForKeyPath:@"m_id"]];
    [messageObj setUser_id:[message valueForKeyPath:@"User_id"]];
    //[messageObj setTime_stamp:(NSDate *)[message valueForKeyPath:@"TimeStamp"]];
    
    NSString *myDateString = [message valueForKeyPath:@"TimeStamp"];
    
    NSLog(@"Text%@", myDateString);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    
    NSDate *myDate = [dateFormatter dateFromString:myDateString];
    NSLog(@"Text%@", myDate);
    
    [messageObj setTime_stamp:myDate];
    [messageObj setMessage:[message valueForKeyPath:@"Message"]];
    
    [_messages addObject:messageObj];
    [self.tableView reloadData];
}

- (IBAction)sendMessage:(id)sender {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:@"http://54.172.35.180:8080/api/messages"]];
    
    NSMutableString *param = [[NSMutableString alloc] init];
    
    [param appendString:[NSString stringWithFormat:@"%@=%@", @"session_id", self.Session_ID]];
    //[param appendString:[NSString stringWithFormat:@"&%@=%@", @"user_id", self.User_ID]];
    [param appendString:[NSString stringWithFormat:@"&%@=%@", @"room_id", self.Room_ID]];
    [param appendString:[NSString stringWithFormat:@"&%@=%@", @"message", self.messageField.text]];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[param dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"Text: %@", request.URL.description);
    
    // another configuration option is backgroundSessionConfiguration (multitasking API required though)
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    // create the session without specifying a queue to run completion handler on (thus, not main queue)
    // we also don't specify a delegate (since completion handler is all we need)
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error)
        {
            NSLog(@"Text: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSDictionary *message = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            NSLog(@"Text: %@", message);
            dispatch_async(dispatch_get_main_queue(), ^{[self updateMessagesForSentMessage:message];});
        }
    }];
    
    [task resume];
}

@end */

#import "MessagesTVC.h"
#import "AppDelegate.h"
#import "Chatroom.h"
#import "Messages.h"
#import <CoreData/CoreData.h>
#import "ProfileTBC.h"

@interface MessagesTVC ()
@property (nonatomic, strong) NSArray *messages;
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *ErrorCheck;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation MessagesTVC

@synthesize messages = _messages;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    _managedObjectContext = [appDelegate managedObjectContext];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //NSFetchRequest *request = [[NSFetchRequest alloc]init];
    //NSEntityDescription *chatroomObj = [NSEntityDescription entityForName:@"Chatroom" inManagedObjectContext:_managedObjectContext];
    //[request setEntity:chatroomObj];
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"chat_title" ascending:YES];
    //NSArray *sortDescriptors = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
    //[request setSortDescriptors:sortDescriptors];
    
    //NSError *error = nil;
    //_messages = [[_managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
    //if(_messages == nil)
    //{
    //handle error
    //}
    
    //[self.tableView reloadData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    

    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *send = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(sendMessage)];
    [toolbar setItems:[[NSArray alloc] initWithObjects:extraSpace, send, nil]];
    
    self.messageField.inputAccessoryView = toolbar;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(UpdateMessages) userInfo:nil repeats:YES];
    
    if([_chat_type isEqualToString:@"joinedChatroom"]){
        [self UpdateMessages];
    }
    else {
        [self UpdateChatroom];
    }

    
}

- (IBAction)hideKeyboard:(id)sender {
    if ([_messageField isFirstResponder]) {
        [_messageField resignFirstResponder];
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
    
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound){
        [self.timer invalidate];
        [self.navigationController popViewControllerAnimated:NO];
    }
    
    [self deregisterFromKeyboardNotifications];
    
    [super viewWillDisappear:animated];
    
}

- (void)keyboardWasShown:(NSNotification *)notification {
    
    NSDictionary* info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGPoint buttonOrigin = self.messageField.frame.origin;
    
    CGFloat buttonHeight = self.messageField.frame.size.height;
    
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

-(IBAction)returnKeyButton:(id)sender
{
    [sender resignFirstResponder];
}

/*-(UIToolbar *)toolbar
{
    if (!_toolbar) {
        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
        UIBarButtonItem *send = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(sendMessage:)];
        [_toolbar setItems:[[NSArray alloc] initWithObjects:send, nil]];
    }
    return _toolbar;
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setChat_type:(NSString *)chat_type
{
    if (!_chat_type) {
        _chat_type = [[NSString alloc] init];
    }
    _chat_type = chat_type;
    
}

-(void)setMessages:(NSArray *)messages
{
    if (!_messages) {
        _messages = [[NSArray alloc] init];
    }
    _messages = messages;
    
    [self.tableView reloadData];
}

/*-(void)updateMessages:(NSArray *)messages
{
    for (NSDictionary *message in messages) {
        Messages *messageObj = [NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:_managedObjectContext];
        [messageObj setChat_id:[message valueForKeyPath:@"Room_id"]];
        [messageObj setM_id:[message valueForKeyPath:@"m_id"]];
        [messageObj setUser_id:[message valueForKeyPath:@"User_id"]];
        //[messageObj setTime_stamp:(NSDate *)[message valueForKeyPath:@"TimeStamp"]];
        
        NSString *myDateString = [message valueForKeyPath:@"TimeStamp"];
        
        NSLog(@"Text%@", myDateString);
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:locale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
        
        NSDate *myDate = [dateFormatter dateFromString:myDateString];
        NSLog(@"Text%@", myDate);
        
        [messageObj setTime_stamp:myDate];
        [messageObj setMessage:[message valueForKeyPath:@"Message"]];
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    request.predicate = [NSPredicate predicateWithFormat:@"chat_id = %@", self.Room_ID];
    NSEntityDescription *messageObj = [NSEntityDescription entityForName:@"Messages" inManagedObjectContext:_managedObjectContext];
    [request setEntity:messageObj];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"time_stamp" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    _messages = [[_managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
    if(_messages == nil)
    {
        //handle error
    }
    
    [self.tableView reloadData];
}*/

/*-(void) viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound){
        [self.timer invalidate];
        [self.navigationController popViewControllerAnimated:NO];
    }
    [super viewWillDisappear:animated];
}*/

- (IBAction)LeaveChatroom:(id)sender {
    
    [self.timer invalidate];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:@"http://54.172.35.180:8080/api/chatroomusers/delete"]];
    
    NSMutableString *param = [[NSMutableString alloc] init];
    
    [param appendString:[NSString stringWithFormat:@"%@=%@", @"session_id", self.Session_ID]];
    //[param appendString:[NSString stringWithFormat:@"&%@=%@", @"user_id", self.User_ID]];
    [param appendString:[NSString stringWithFormat:@"&%@=%@", @"room_id", self.Room_ID]];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[param dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"Text: %@", request.URL.description);
    
    // another configuration option is backgroundSessionConfiguration (multitasking API required though)
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    // create the session without specifying a queue to run completion handler on (thus, not main queue)
    // we also don't specify a delegate (since completion handler is all we need)
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error)
        {
            NSLog(@"Text: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSDictionary *message = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            NSLog(@"Text: %@", message);
            NSNumber *success = (NSNumber *)[message objectForKey:@"success"];
            if([success boolValue] == NO) {
                NSString *jsonError = [message valueForKeyPath:@"error_code"];
                if([jsonError isEqualToString:@"103"])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{[self UpdateSessionID:@"LeaveChatroom"];});
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{[self.navigationController popViewControllerAnimated:NO];});
                //dispatch_async(dispatch_get_main_queue(), ^{self.ErrorCheck.text = @"Left Chatroom";});
            }
        }
        else
        {
            _ErrorCheck.text = @"Network/Server Error";
        }
    }];
    
    [task resume];
}

- (void)UpdateMessages
{
    NSDate *pastDate = [NSDate date];
    NSDateComponents *comps =[[NSDateComponents alloc] init];
    [comps setDay:-30];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    pastDate = [calendar dateByAddingComponents:comps toDate:pastDate options:0];
    NSLog(@"Text: %@", pastDate);
    
    NSString *str = @"http://54.172.35.180:8080/api/messages/room_id/";
    str = [str stringByAppendingString: [NSString stringWithFormat:@"%@/%@/%@", self.Room_ID, pastDate, self.Session_ID]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    NSLog(@"Text: %@", str);
    
    NSLog(@"Test: %@", request.URL.description);
    
    //NSMutableString *param = [[NSMutableString alloc] init];
    
    //[param appendString:[NSString stringWithFormat:@"%@=%@", @"session_id", self.Session_ID]];
    //[param appendString:[NSString stringWithFormat:@"&%@=%@", @"user_id", self.User_ID]];
    //[param appendString:[NSString stringWithFormat:@"&%@=%@", @"room_id", self.Room_ID]];
    
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
            NSArray *messages = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if([messages count] != 0) {
                NSLog(@"Text: %@", [messages objectAtIndex:0]);
                NSString *jsonError = [[messages objectAtIndex:0] valueForKeyPath:@"error_code"];
                if([jsonError isEqualToString:@"103"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{[self UpdateSessionID:@"UpdateMessages"];});
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{self.messages = messages;});
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

/*- (void)joinChat:(NSNumber *)success
{
    if ([success boolValue] == YES) {
        
        NSFetchRequest *req = [[NSFetchRequest alloc]init];
        req.predicate = [NSPredicate predicateWithFormat:@"chat_id = %@", self.Room_ID];
        NSEntityDescription *chatroomObj = [NSEntityDescription entityForName:@"Chatroom" inManagedObjectContext:_managedObjectContext];
        [req setEntity:chatroomObj];
        
        NSError *error = nil;
        NSArray *room = [[_managedObjectContext executeFetchRequest:req error:&error]mutableCopy];
        Chatroom *chat = (Chatroom *)[room objectAtIndex:0];
        
        NSDate *pastDate = [chat time_stamp];
        NSDateComponents *comps =[[NSDateComponents alloc] init];
        [comps setDay:-10];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        pastDate = [calendar dateByAddingComponents:comps toDate:pastDate options:0];
        NSLog(@"Text: %@", pastDate);
        NSDate *currentDate = [NSDate date];
        NSLog(@"Text: %@", currentDate);
        
        [chat setValue:currentDate forKeyPath:@"time_stamp"];
        
        [self.managedObjectContext save:nil];
        
        NSString *str = @"http://54.172.35.180:8080/api/messages/room_id/";
        str = [str stringByAppendingString: [NSString stringWithFormat:@"%@/%@/%@", self.Room_ID, pastDate, self.Session_ID]];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        NSLog(@"Text: %@", str);
        
        NSLog(@"Test: %@", request.URL.description);
        
        //NSMutableString *param = [[NSMutableString alloc] init];
        
        //[param appendString:[NSString stringWithFormat:@"%@=%@", @"session_id", self.Session_ID]];
        //[param appendString:[NSString stringWithFormat:@"&%@=%@", @"user_id", self.User_ID]];
        //[param appendString:[NSString stringWithFormat:@"&%@=%@", @"room_id", self.Room_ID]];
        
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
                NSArray *messages = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                NSLog(@"Text: %@", messages);
                dispatch_async(dispatch_get_main_queue(), ^{[self updateMessages:messages];});
            }
        }];
        
        [task resume];
        
    }
}*/

- (void)UpdateChatroom
{
    //self.chatrooms = nil;
    
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: @"http://54.172.35.180:8080/api/chatroomusers"]];
        
        NSMutableString *param = [[NSMutableString alloc] init];
        
        [param appendString:[NSString stringWithFormat:@"%@=%@", @"session_id", self.Session_ID]];
        //[param appendString:[NSString stringWithFormat:@"&%@=%@", @"user_id", self.User_ID]];
        [param appendString:[NSString stringWithFormat:@"&%@=%@", @"room_id", self.Room_ID]];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[param dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSLog(@"Text: %@", request.URL.description);
        
        // another configuration option is backgroundSessionConfiguration (multitasking API required though)
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
        // create the session without specifying a queue to run completion handler on (thus, not main queue)
        // we also don't specify a delegate (since completion handler is all we need)
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error)
            {
                if ([request.URL isEqual:[NSURL URLWithString: @"http://54.172.35.180:8080/api/chatroomusers"]]) {
                    NSLog(@"Text: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                    NSDictionary *joinChat = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                    NSLog(@"Text: %@", joinChat);
                    NSNumber *success = (NSNumber *)[joinChat objectForKey:@"success"];
                    if([success boolValue] == NO) {
                        NSString *jsonError = [joinChat valueForKeyPath:@"error_code"];
                        if([jsonError isEqualToString:@"103"])
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{[self UpdateSessionID:@"UpdateChatroom"];});
                        }
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{[self UpdateMessages];});
                        
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
        self.Session_ID = tabBar.Session_ID;
        if([method isEqualToString:@"UpdateChatroom"]){
            [self UpdateChatroom];
        }
        else if([method isEqualToString:@"UpdateMessages"]){
            [self UpdateMessages];
        }
        else if([method isEqualToString:@"sendMessage"]){
            [self sendMessage];
        }
        else if([method isEqualToString:@"leaveChatroom"]){
            [self LeaveChatroom:self];
        }
    }
    else {
        _ErrorCheck.text = @"Invalid Session Update";
    }
}


#pragma mark - Table view data source

#pragma mark - UITableViewDataSource

// the methods in this protocol are what provides the View its data
// (remember that Views are not allowed to own their data)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section (we only have one)
    NSLog(@"Text: %lu", (unsigned long)[self.messages count]);
    
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // we must be sure to use the same identifier here as in the storyboard!
    static NSString *CellIdentifier = @"MessageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    // get the photo out of our Model
    //Messages *message = (Messages *)[self.messages objectAtIndex:indexPath.row];
    
    //NSLog(@"Text: %@", [message user_id]);
    //NSLog(@"Text: %@", [message message]);
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[[self.messages objectAtIndex:indexPath.row] valueForKeyPath:@"DisplayName"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[[self.messages objectAtIndex:indexPath.row] valueForKeyPath:@"Message"]];
    
    // update UILabels in the UITableViewCell
    // valueForKeyPath: supports "dot notation" to look inside dictionaries at other dictionaries
    
    return cell;
}

/*-(void)updateMessagesForSentMessage:(NSDictionary *)message
{
    Messages *messageObj = [NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:_managedObjectContext];
    [messageObj setChat_id:[message valueForKeyPath:@"Room_id"]];
    [messageObj setM_id:[message valueForKeyPath:@"m_id"]];
    [messageObj setUser_id:[message valueForKeyPath:@"User_id"]];
    //[messageObj setTime_stamp:(NSDate *)[message valueForKeyPath:@"TimeStamp"]];
    
    NSString *myDateString = [message valueForKeyPath:@"TimeStamp"];
    
    NSLog(@"Text%@", myDateString);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    
    NSDate *myDate = [dateFormatter dateFromString:myDateString];
    NSLog(@"Text%@", myDate);
    
    [messageObj setTime_stamp:myDate];
    [messageObj setMessage:[message valueForKeyPath:@"Message"]];
    
    [_messages addObject:messageObj];
    [self.tableView reloadData];
}*/

- (void)sendMessage/*:(id)sender*/ {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:@"http://54.172.35.180:8080/api/messages"]];
    
    NSMutableString *param = [[NSMutableString alloc] init];
    
    [param appendString:[NSString stringWithFormat:@"%@=%@", @"session_id", self.Session_ID]];
    //[param appendString:[NSString stringWithFormat:@"&%@=%@", @"user_id", self.User_ID]];
    [param appendString:[NSString stringWithFormat:@"&%@=%@", @"room_id", self.Room_ID]];
    [param appendString:[NSString stringWithFormat:@"&%@=%@", @"message", self.messageField.text]];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[param dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"Text: %@", request.URL.description);
    
    // another configuration option is backgroundSessionConfiguration (multitasking API required though)
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    // create the session without specifying a queue to run completion handler on (thus, not main queue)
    // we also don't specify a delegate (since completion handler is all we need)
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error)
        {
            NSLog(@"Text: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSDictionary *message = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            NSLog(@"Text: %@", message);
            NSNumber *success = (NSNumber *)[message objectForKey:@"success"];
            if([success boolValue] == NO) {
                NSString *jsonError = [message valueForKeyPath:@"error_code"];
                if([jsonError isEqualToString:@"103"])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{[self UpdateSessionID:@"sendMessage"];});
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{self.messageField.text = @"";});
                
            }
        }
        else
        {
            _ErrorCheck.text = @"Network/Server Error";
        }
    }];
    
    [task resume];
}

@end
