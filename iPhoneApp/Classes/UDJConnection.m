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

static UDJConnection* sharedUDJConnection = nil;

@implementation UDJConnection

@synthesize serverPrefix, ticket, client;

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
    authCancelled=false;
    client = [RKClient clientWithBaseURL:prefix];
}

// **************************** CurrentController Methods ********************************

- (void) setCurrentController:(id)controller{
    currentController = controller;
}



// **************************** Authorization Methods ********************************

// sends a POST with the username and password
- (void) authenticate:(NSString*)username password:(NSString*)pass{
    authCancelled=false;
    // make sure the right api version is being passed in
    NSDictionary* nameAndPass = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", pass, @"password", @"0.2", @"udj_api_version", nil]; 
    [client post:@"/auth" params:nameAndPass delegate:self];
    NSLog(@"attemping to authenticate");
}

// handle authorization response
- (void)handleAuth:(RKResponse*)response{
    NSLog(@"handling auth");
    if(!authCancelled){
        NSLog(@"auth");
        ticket=@"ticket";
        authCancelled=true; // this is so we don't get further responses
        // load the party list view
        PartyListViewController* partyListViewController = [[PartyListViewController alloc] initWithNibName:@"PartyListViewController" bundle:[NSBundle mainBundle]];
         [currentController.navigationController pushViewController:partyListViewController animated:YES];
        [partyListViewController release];
    }
}

// called by outside classes to cancel authorization
- (void)authCancel{
    authCancelled=true;
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
            NSLog(@"Retrieved XML from our POST: %@", [response bodyAsString]);
            [self handleAuth:response];
        }
        // Handle
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
