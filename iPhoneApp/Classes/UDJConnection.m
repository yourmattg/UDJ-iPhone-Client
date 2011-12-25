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
#import "UDJEvent.h"

static UDJConnection* sharedUDJConnection = nil;

@implementation UDJConnection

@synthesize serverPrefix, ticket, client, userID, headers;

// **************************** General UDJConnection Methods ********************************

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
    acceptAuth=false; // don't want to accept authorization response yet
    acceptEvents=false;
    client = [RKClient clientWithBaseURL:prefix];
}

- (void) setCurrentController:(id)controller{
    currentController = controller;
}


// **************************** Authorization Methods ********************************

// authenticate: sends a POST with the username and password
- (void) authenticate:(NSString*)username password:(NSString*)pass{
    acceptAuth=true;
    // make sure the right api version is being passed in
    NSDictionary* nameAndPass = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", pass, @"password", @"0.2", @"udj_api_version", nil]; 
    [client post:@"/auth" params:nameAndPass delegate:self];
}

// handleAuth: handle authorization response if credentials are valid
- (void)handleAuth:(RKResponse*)response{
    // only handle if we are waiting for an auth response
    if(acceptAuth){
        NSDictionary* headerDict = [response allHeaderFields];
        ticket=[headerDict valueForKey:@"X-Udj-Ticket-Hash"];
        userID=[headerDict valueForKey:@"X-Udj-User-Id"];
        acceptAuth=false; // this is so we don't get further responses
        headers = [NSDictionary dictionaryWithObjectsAndKeys:ticket, @"X-Udj-Ticket-Hash", userID, @"X-Udj-User-Id", nil];
        
        // load the party list view
        PartyListViewController* partyListViewController = [[PartyListViewController alloc] initWithNibName:@"PartyListViewController" bundle:[NSBundle mainBundle]];
         [currentController.navigationController pushViewController:partyListViewController animated:YES];
        [partyListViewController release];
    }
}

// authCancel: called by outside classes to cancel authorization
- (void)authCancel{
    acceptAuth=false;
}

// denyAuth: called when username/pass is incorrect
- (void)denyAuth{
    acceptAuth = false;
    [currentController.navigationController popViewControllerAnimated:YES];
    UIAlertView* authNotification = [UIAlertView alloc];
    [authNotification initWithTitle:@"Login Failed" message:@"The username or password you entered is invalid." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [authNotification show];
}


// **************************** Event Loading and Searching ********************************

// sendEventSearch: request all the events with a similiar name
- (void) sendEventSearch:(NSString *)name{
    NSLog(@"event search");
    acceptEvents=true;
    
    // create the URL
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingString:@"/events?name="];
    urlString = [urlString stringByAppendingString:name];
    NSURL* url = [NSURL URLWithString:urlString];
    
    //create GET request with correct parameters and headers
    RKRequest* request = [RKRequest new];
    [request initWithURL:url delegate:self];
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = headers;
    
    // send request and handle response
    RKResponse* response = [request sendSynchronously];
    [self handleEventResults:response];
}

// handleEventResults: get the list of returned events from either the name or location search
- (void) handleEventResults:(RKResponse*)response{
    NSLog(@"Handling events...");
    
    NSMutableArray* currentList = [NSMutableArray new];
    RKJSONParserJSONKit* parser = [RKJSONParserJSONKit new];
    NSArray* eventArray = [parser objectFromString:[response bodyAsString] error:nil];
    for(int i=0; i<[eventArray count]; i++){
        UDJEvent* event = [UDJEvent new];
        NSDictionary* eventDict = [eventArray objectAtIndex:i];
        event.name = [eventDict objectForKey:@"name"];
        event.eventId = [[eventDict objectForKey:@"id"] integerValue];
        event.hostId = [[eventDict objectForKey:@"host_id"] integerValue];
        event.latitude = [[eventDict objectForKey:@"latitude"] doubleValue];
        event.longitude = [[eventDict objectForKey:@"longitude"] doubleValue];
        [currentList addObject:event];
    }
    [[EventList sharedEventList] setCurrentList:currentList];
    acceptEvents=false;
}

- (void) acceptEvents:(BOOL)value{
    acceptEvents = value;
}


// **************************** General Response Handling ********************************

// handles responses from the server
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSLog(@"Got a response from the server");
    if ([request isGET]) {
        // event lists
        /*if(acceptEvents){
            // got a list of events back
            if([response isOK]){
                [self handleEventResults:response];
            }
        }*/
        
    } else if([request isPOST]) {
        
        // authorization
        if(acceptAuth) {
            // valid credentials
            if([response isOK]) [self handleAuth:response];
            // invalid credentials
            else [self denyAuth];
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
