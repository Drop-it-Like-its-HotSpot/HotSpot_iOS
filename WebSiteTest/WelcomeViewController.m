//
//  WelcomeViewController.m
//  WebSiteTest
//
//  Created by Ryan Farrell on 7/11/14.
//  Copyright (c) 2014 Ryan Farrell. All rights reserved.
//

#import "LoginViewController.h"
#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GoToLogin"]) {
        if ([segue.destinationViewController isKindOfClass:[LoginViewController class]]) {
            LoginViewController *lvc = (LoginViewController *)segue.destinationViewController;
        }
    }
}

@end
