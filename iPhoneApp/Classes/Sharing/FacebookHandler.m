//
//  FacebookHandler.m
//  UDJ
//
//  Created by Shao Ping Lee on 2/11/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "FacebookHandler.h"

@implementation FacebookHandler
@synthesize facebook;

static FacebookHandler *sharedFacebookHandler = nil;

+(id) sharedHandler {
    @synchronized(self) {
        if (sharedFacebookHandler == nil)
            sharedFacebookHandler = [[self alloc] init];
    }
    return sharedFacebookHandler;
}

-(void)login {
    //create instance when user decides to login
    facebook = [[Facebook alloc] initWithAppId:@"218882608209937" andDelegate:self];
    
    
    
    //check for previous token key
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    //if no previous key, prompt user to login and authorize
    if (![facebook isSessionValid]) {
        //Customized permissions
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"user_likes", 
                                @"read_stream",
                                @"offline_access",
                                @"publish_checkins",
                                @"publish_stream",
                                nil];
        
        [facebook authorize:permissions];
    }
    NSLog(@"login executed");
}

-(void)logout {
    [facebook logout];
}

//params is passed from wherever user chooses to share
-(void)postWithParam: (NSMutableDictionary* ) params {
    [facebook dialog:@"feed"
           andParams:params
         andDelegate:self];
    
}

/**
 *  Handles login based on iOS version
 **/

// Pre 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [facebook handleOpenURL:url]; 
}

// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url]; 
}

#pragma mark - FacebookSessionDelegate implementation

- (void)fbDidLogin {
    //store token when user is logged in
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    NSLog(@"Log In Successful!");
    
}
- (void)fbDidNotLogin:(BOOL)cancelled {
    
}
- (void)fbDidLogout {
    // Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
    NSLog(@"Log Out Successful!");
}
- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt {
    
}
- (void)fbSessionInvalidated {
    
}

@end
