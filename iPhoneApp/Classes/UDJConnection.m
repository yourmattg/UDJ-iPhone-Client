//
//  UDJConnection.m
//  UDJ
//
//  Created by Matthew Graf on 12/13/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJConnection.h"
#import "AuthenticateViewController.h"
#import "PartyListViewController.h"
#import "UDJAppDelegate.h"

static UDJConnection* sharedUDJConnection = nil;

@implementation UDJConnection

@synthesize serverPrefix, ticket, client, userID;

#pragma mark Singleton Methods
// allows UDJConnection to be used anywhere in the  application
+ (id)sharedConnection {
    @synchronized(self) {
        if (sharedUDJConnection == nil)
            sharedUDJConnection = [[self alloc] init];
    }
    return sharedUDJConnection;
}
// this creates the RKClient and sets its base URL to 'prefix'
- (void) initWithServerPrefix:(NSString *)prefix{
    ticket=nil;
    acceptingAuth=false; // don't want to accept authorization response yet
    client = [RKClient clientWithBaseURL:prefix];
}

// **************************** CurrentController Methods ********************************

- (void) setCurrentController:(id)controller{
    currentController = controller;
}



// **************************** Authorization Methods ********************************

// sends a POST with the username and password
- (void) authenticate:(NSString*)username password:(NSString*)pass{
    acceptingAuth=true;
    // make sure the right api version is being passed in
    NSDictionary* nameAndPass = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", pass, @"password", @"0.2", @"udj_api_version", nil]; 
    [client post:@"/auth" params:nameAndPass delegate:self];
}

// handle authorization response
- (void)handleAuth:(RKResponse*)response{
    if(acceptingAuth){
        NSDictionary* headerDict = [response allHeaderFields];
        ticket=[headerDict valueForKey:@"X-Udj-Ticket-Hash"];
        userID=[headerDict valueForKey:@"X-Udj-User-Id"];
        acceptingAuth=false; // this is so we don't get further responses
        
        // load the party list view
        PartyListViewController* partyListViewController = [[PartyListViewController alloc] initWithNibName:@"PartyListViewController" bundle:[NSBundle mainBundle]];
         [currentController.navigationController pushViewController:partyListViewController animated:YES];
        [partyListViewController release];
    }
}

// called by outside classes to cancel authorization
- (void)authCancel{
    acceptingAuth=false;
}

// called when username/pass is incorrect
- (void)denyAuth{
    acceptingAuth = false;
    [currentController.navigationController popViewControllerAnimated:YES];
    UIAlertView* authNotification = [UIAlertView alloc];
    [authNotification initWithTitle:@"Login Failed" message:@"The username or password you entered is invalid." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
}

// handles responses from the server
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSLog(@"Got a response from the server");
    if ([request isGET]) {
        // Handling GET /foo.xml
        
        if([response isOK]) {
            // Success! Let's take a look at the data
            NSLog(@"Retrieved XML: %@", [response bodyAsString]);
        }
        
    } else if([request isPOST]) {
        
        // Handling POST /other.json
        if([response isJSON]) {
            NSLog(@"Got a JSON response back from our POST!");
        }
        else if([response isOK]) {
            // this automatically assumes its for authorization, should change
           // NSLog(@"Retrieved XML from our POST: %@", [response bodyAsString]);
            [self handleAuth:response];
        }
        // we are waiting for an authorization, but credentials were invalid
        else if(acceptingAuth){ // may have to add that it is a 403 status code
            NSLog(@"denied");
            [self denyAuth];
        }
    } else if([request isDELETE]) {
        
        // Handling DELETE /missing_resource.txt
        if([response isNotFound]) {
            NSLog(@"The resource path '%@' was not found.", [request resourcePath]);
        }
    }
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
    [serverPrefix release];
    [ticket release];
    [client release];
}

@end
