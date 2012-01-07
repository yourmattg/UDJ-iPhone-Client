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
#import "UDJSong.h"
#import "UDJPlaylist.h"

static UDJConnection* sharedUDJConnection = nil;

@implementation UDJConnection

@synthesize serverPrefix, ticket, client, userID, headers, playlistView, currentRequests;

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
    currentRequests = [NSMutableDictionary new];
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
        //TODO: may need to change userID to [userID intValue]
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
    [authNotification release];
}


// **************************** Event Loading and Searching ********************************

// sendEventSearch: request all the events with a similiar name
- (void) sendEventSearch:(NSString *)name{
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

// sendNearbyEventSearch: requests all the events near the client's location
- (void) sendNearbyEventSearch{
    acceptEvents=true;
    float latitude = [self getLatitude];
    float longitude = [self getLongitude];
    
    // create URL
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingString:@"/events/"];
    urlString = [urlString stringByAppendingFormat:@"%f",latitude];
    urlString = [urlString stringByAppendingString:@"/"];
    urlString = [urlString stringByAppendingFormat:@"%f",longitude];
    NSURL* url = [NSURL URLWithString:urlString];
    
    // create GET request
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
    NSMutableArray* cList = [NSMutableArray new];
    RKJSONParserJSONKit* parser = [RKJSONParserJSONKit new];
    NSArray* eventArray = [parser objectFromString:[response bodyAsString] error:nil];
    for(int i=0; i<[eventArray count]; i++){
        NSDictionary* eventDict = [eventArray objectAtIndex:i];
        UDJEvent* event = [UDJEvent eventFromDictionary:eventDict];
        [cList addObject:event];
    }
    [EventList sharedEventList].currentList = cList;
    acceptEvents=NO;
    [cList release];
    [parser release];
}

- (void) acceptEvents:(BOOL)value{
    acceptEvents = value;
}

// enterEventRequest: attempts to log in user to party, returns status code of response
- (NSInteger) enterEventRequest{
    //create url
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingString:@"/events/"];
    urlString = [urlString stringByAppendingFormat:@"%d",[EventList sharedEventList].currentEvent.eventId];
    urlString = [urlString stringByAppendingString:@"/users/"];
    urlString = [urlString stringByAppendingFormat:@"%i", [userID intValue]];
    //set up request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
    request.method = RKRequestMethodPUT;
    request.additionalHTTPHeaders = headers;
    //send request, handle results
    RKResponse* response = [request sendSynchronously];
    return response.statusCode;
}

- (NSInteger) leaveEventRequest{
    //create url
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingString:@"/events/"];
    urlString = [urlString stringByAppendingFormat:@"%d",[EventList sharedEventList].currentEvent.eventId];
    urlString = [urlString stringByAppendingString:@"/users/"];
    urlString = [urlString stringByAppendingFormat:@"%d", [userID intValue]];
    //set up request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
    request.method = RKRequestMethodDELETE;
    request.additionalHTTPHeaders = headers;
    //send request, handle results
    RKResponse* response = [request sendSynchronously];
    return response.statusCode;
}

// **************************** Location Finding ********************************

// getLongitude: INCOMPLETE
- (float)getLongitude{
    return (float)40;
}

// getLatitude: INCOMPLETE
- (float)getLatitude{
    return (float)80;
}

// **************************** Playlist Methods ********************************

// sendPlaylistRequest: requests playlist from server, seperate from handling because
// we want client to be able to do other things while we wait for it to refresh
- (void)sendPlaylistRequest:(NSInteger)eventId{
    //create url [GET] {prefix}/events/event_id/active_playlist
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingString:@"/events/"];
    urlString = [urlString stringByAppendingFormat:@"%d",eventId];
    urlString = [urlString stringByAppendingString:@"/active_playlist"];
    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
    request.queue = client.requestQueue;
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = headers;
    //send request
    acceptPlaylist=YES;
    [request send];
}

// handlePlaylistResponse: this is done asynchronously from the send method so the client can do other things meanwhile
// NOTE: this calls [playlistView refreshTableList] for you!
- (void)handlePlaylistResponse:(RKResponse*)response{
    acceptPlaylist=NO;
    NSMutableArray* playlist = [NSMutableArray new];
    RKJSONParserJSONKit* parser = [RKJSONParserJSONKit new];
    // response dict: holds current song and array of songs
    NSDictionary* responseDict = [parser objectFromString:[response bodyAsString] error:nil];
    UDJSong* currentSong = [UDJSong songFromDictionary:[responseDict objectForKey:@"current_song"]];
    
    // the array holding the songs on the playlist
    NSArray* songArray = [responseDict objectForKey:@"active_playlist"];
    for(int i=0; i<[songArray count]; i++){
        NSDictionary* songDict = [songArray objectAtIndex:i];
        UDJSong* song = [UDJSong songFromDictionary:songDict];
        [playlist addObject:song];
        
        NSNumber* songIdAsNumber = [NSNumber numberWithInteger:song.songId];
        // if this song hasnt been added to the playlist before i.e. isnt in the voteRecordKeeper
        if([[UDJPlaylist sharedUDJPlaylist].voteRecordKeeper objectForKey:songIdAsNumber]==nil){
            // set its songId to NO, meaning the user hasn't voted for it yet
            NSNumber* no =[NSNumber numberWithBool:NO];
            [[UDJPlaylist sharedUDJPlaylist].voteRecordKeeper setObject:no forKey:songIdAsNumber];
        }
    }
    [[UDJPlaylist sharedUDJPlaylist] setPlaylist:playlist];
    [[UDJPlaylist sharedUDJPlaylist] setCurrentSong:currentSong];
    if(playlistView!=nil) [playlistView refreshTableList];
    [playlist release];
}

// **************************** Voting Methods ********************************

// sendVoteRequest: first parameter specifies an up (YES) or down (NO) vote, second specifies song id
-(void)sendVoteRequest:(BOOL)up songId:(NSInteger)songId eventId:(NSInteger)eventId{
    //create url [POST] {prefix}/udj/events/event_id/active_playlist/playlist_id/users/user_id/upvote
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingFormat:@"%@%d%@%d%@%d%@", @"/events/", eventId, @"/active_playlist/",songId,@"/users/",[userID intValue],@"/"];
    if(up) urlString = [urlString stringByAppendingString:@"upvote"];
    else urlString = [urlString stringByAppendingString:@"downvote"];
    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
    request.queue = client.requestQueue;
    request.method = RKRequestMethodPOST;
    request.additionalHTTPHeaders = headers;
    //send request
    acceptPlaylist=YES;
    //[currentRequests setObject:@"voteRequest" forKey:request]; was causing error
    [request send];    
}

-(void)handleVoteResponse:(RKResponse*)response{
    
}


// **************************** General Response Handling ********************************

// handles responses from the server
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSLog(@"Got a response from the server");
    if ([request isGET]) {
        // playlist
        if(acceptPlaylist){
            [self handlePlaylistResponse:response];
        }
        
    } else if([request isPOST]) {
        
        // authorization
        if(acceptAuth) {
            // valid credentials
            if([response isOK]) [self handleAuth:response];
            // invalid credentials
            else [self denyAuth];
        }/* was causing error
        if([currentRequests objectForKey:request]==@"voteRequest"){
            if(response.statusCode==408){
                NSLog(@"vote request timed out");
                [request send];
            }
            else if([response isOK]) [self handleVoteResponse:response];
        }*/

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
    [currentRequests release];
    [super dealloc];
}

@end
