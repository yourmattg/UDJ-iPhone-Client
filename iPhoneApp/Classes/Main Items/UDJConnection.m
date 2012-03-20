//
//  UDJConnection.m
//  UDJ
//
//  Created by Matthew Graf on 12/13/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJConnection.h"
#import "AuthenticateViewController.h"
#import "EventSearchViewController.h"
#import "UDJAppDelegate.h"
#import "UDJEvent.h"
#import "UDJSong.h"
#import "UDJPlaylist.h"
#import "LibraryResultsController.h"
#import "UDJSongList.h"
#import "UDJMappableArray.h"
#import "UDJEventGoer.h"
#import "EventGoerViewController.h"
#import "UDJEventGoerList.h"

static UDJConnection* sharedUDJConnection = nil;

@implementation UDJConnection

@synthesize serverPrefix, ticket, client, userID, headers, playlistView, currentRequests, acceptLibSearch, navigationController, locationManager;

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
    
    // we don't care about valid certificates
    self.client.disableCertificateValidation = YES;
    
    currentRequests = [NSMutableDictionary new];
    clientRequestCount = 1;
    locationManager = [[LocationManager alloc] init];
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
        EventSearchViewController* eventSearchViewController = [[EventSearchViewController alloc] initWithNibName:@"EventSearchViewController" bundle:[NSBundle mainBundle]];
        [currentController.navigationController pushViewController:eventSearchViewController animated:YES];
    }
}

// authCancel: called by outside classes to cancel authorization
- (void)authCancel{
    acceptAuth=false;
}

// denyAuth: called when username/pass is incorrect
- (void)denyAuth:(RKResponse*)response{
    acceptAuth = false;
    [currentController.navigationController popViewControllerAnimated:YES];
    UIAlertView* authNotification = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"The username or password you entered is invalid." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [authNotification show];
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
    RKRequest* request = [[RKRequest alloc] initWithURL:url delegate:self];
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = headers;
    
    // send request and handle response
    RKResponse* response = [request sendSynchronously];
    [self handleEventResults:response isNearbySearch:NO];
}

// sendNearbyEventSearch: requests all the events near the client's location
- (void) sendNearbyEventSearch{
    acceptEvents=true;
    
    // use location manager to get long/latitude
    float latitude = [locationManager getLatitude];
    float longitude = [locationManager getLongitude];
    
    // create URL
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingString:@"/events/"];
    urlString = [urlString stringByAppendingFormat:@"%f",latitude];
    urlString = [urlString stringByAppendingString:@"/"];
    urlString = [urlString stringByAppendingFormat:@"%f",longitude];
    NSURL* url = [NSURL URLWithString:urlString];
    
    // create GET request
    RKRequest* request = [[RKRequest alloc] initWithURL:url delegate:self];
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = headers;
    
    // send request and handle response
    RKResponse* response = [request sendSynchronously];
    [self handleEventResults:response isNearbySearch:NO];
}

// handleEventResults: get the list of returned events from either the name or location search
- (void) handleEventResults:(RKResponse*)response isNearbySearch:(BOOL)isNearbySearch{
    NSMutableArray* cList = [NSMutableArray new];
    RKJSONParserJSONKit* parser = [RKJSONParserJSONKit new];
    NSArray* eventArray = [parser objectFromString:[response bodyAsString] error:nil];
    for(int i=0; i<[eventArray count]; i++){
        NSDictionary* eventDict = [eventArray objectAtIndex:i];
        UDJEvent* event = [UDJEvent eventFromDictionary:eventDict];
        [cList addObject:event];
    }
    [UDJEventData sharedEventData].currentList = cList;
    acceptEvents=NO;
    
    // if no events found, alert the user

}

- (void) acceptEvents:(BOOL)value{
    acceptEvents = value;
}

// enterEventRequest: attempts to log in user to party, returns status code of response
- (NSInteger) enterEventRequest{
    //create url
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingString:@"/events/"];
    urlString = [urlString stringByAppendingFormat:@"%d",[UDJEventData sharedEventData].currentEvent.eventId];
    urlString = [urlString stringByAppendingString:@"/users/"];
    urlString = [urlString stringByAppendingFormat:@"%i", [userID intValue]];
    //set up request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
    request.method = RKRequestMethodPUT;
    request.additionalHTTPHeaders = headers;
    //send request, handle results
    RKResponse* response = [request sendSynchronously];
    // if user is already in another event, set currentEvent to that event
    if(response.statusCode==409){
        RKJSONParserJSONKit* parser = [RKJSONParserJSONKit new];
        NSDictionary* eventDict = [parser objectFromString:[response bodyAsString] error:nil];
        [UDJEventData sharedEventData].currentEvent = [UDJEvent eventFromDictionary:eventDict];
    }
    return response.statusCode;
}

- (NSInteger) leaveEventRequest{
    //create url
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingString:@"/events/"];
    urlString = [urlString stringByAppendingFormat:@"%d",[UDJEventData sharedEventData].currentEvent.eventId];
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

- (void) sendEventGoerRequest:(NSInteger)eventId delegate:(NSObject*)delegate{
    // [GET] /udj/events/event_id/users
    NSString* urlString = [NSString stringWithFormat:@"%@%@%d%@", client.baseURL, @"/events/", eventId, @"/users"];
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:delegate];
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = headers;
    request.queue = client.requestQueue;
    
    acceptEventGoers=YES;
    [request send];
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
    UDJSong* currentSong = [UDJSong songFromDictionary:[responseDict objectForKey:@"current_song"] isLibraryEntry:NO];
    
    // the array holding the songs on the playlist
    NSArray* songArray = [responseDict objectForKey:@"active_playlist"];
    for(int i=0; i<[songArray count]; i++){
        NSDictionary* songDict = [songArray objectAtIndex:i];
        UDJSong* song = [UDJSong songFromDictionary:songDict isLibraryEntry:NO];
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
}

- (void)sendSongRemoveRequest:(NSInteger)songId eventId:(NSInteger)eventId{
    //[DELETE] /events/event_id/active_playlist/playlist_id
    NSString* urlString = [NSString stringWithFormat:@"%@%@%d%@%d", client.baseURL, @"/events/", eventId, @"/active_playlist/songs/", songId];
    // set up request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
    request.queue = client.requestQueue;
    request.method = RKRequestMethodDELETE;
    request.additionalHTTPHeaders = headers;
    
    [request send];    
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
    //[currentRequests setObject:@"voteRequest" forKey:request]; was causing error
    [request send];    
}

-(void)handleVoteResponse:(RKResponse*)response{
    acceptEventGoers=NO;
}

// **************************** Library Search Methods ********************************

-(void)sendLibSearchRequest:(NSString *)param eventId:(NSInteger)eventId maxResults:(NSInteger)maxResults{
    //create url [GET] /udj/events/event_id/available_music?query=query{&max_results=maximum_number_of_results}
    NSString* urlString = client.baseURL;
    param = [param stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    urlString = [urlString stringByAppendingFormat:@"%@%d%@%@%@%d",@"/events/",eventId,@"/available_music?query=",param,@"&max_results=",maxResults];
    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
    request.queue = client.requestQueue;
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = headers;
    //send request
    acceptLibSearch=YES;
    [request send]; 
}

-(void)sendRandomSongRequest:(NSInteger)eventId maxResults:(NSInteger)maxResults{
    //create url [GET] /udj/events/event_id/available_music/random_songs{?max_randoms=number_desired}
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingFormat:@"%@%d%@%d",@"/events/",eventId,@"/available_music/random_songs?max_randoms=",maxResults];
    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
    request.queue = client.requestQueue;
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = headers;
    //send request
    acceptLibSearch=YES;
    [request send]; 
}

-(void)handleLibSearchResults:(RKResponse *)response{
    acceptLibSearch=NO;
    UDJSongList* tempList = [UDJSongList new];
    RKJSONParserJSONKit* parser = [RKJSONParserJSONKit new];
    NSArray* songArray = [parser objectFromString:[response bodyAsString] error:nil];
    for(int i=0; i<[songArray count]; i++){
        NSDictionary* songDict = [songArray objectAtIndex:i];
        UDJSong* song = [UDJSong songFromDictionary:songDict isLibraryEntry:YES];
        [tempList addSong:song];
    }
    LibraryResultsController* libraryResultsController = [[LibraryResultsController alloc] initWithNibName:@"LibraryResultsController" bundle:[NSBundle mainBundle]];
    [self.navigationController popViewControllerAnimated:NO];
    [self.navigationController pushViewController:libraryResultsController animated:YES];
    // set tempList to be the tableList of the libsearch results screen
    libraryResultsController.resultList = tempList;
}

-(void)sendAddSongRequest:(NSInteger)librarySongId eventId:(NSInteger)eventId{
    //create url [PUT] /udj/events/event_id/active_playlist/songs
    NSString* urlString = [NSString stringWithFormat:@"%@%@%d%@",client.baseURL,@"/events/",eventId,@"/active_playlist/songs"];
    
    // make a dictionary for the song request, with a "lib_id" and "client_request_id"
    NSMutableDictionary* songAddDictionary = [NSMutableDictionary new];
    NSDate *currentDate = [NSDate date];
    NSNumber* clientRequestIdAsNumber = [NSNumber numberWithDouble:[currentDate timeIntervalSinceReferenceDate]];
    NSNumber* libraryIdAsNumber = [NSNumber numberWithInt:librarySongId];
    [songAddDictionary setObject:clientRequestIdAsNumber forKey:@"client_request_id"];
    [songAddDictionary setObject:libraryIdAsNumber forKey:@"lib_id"];
    
    // then make an array to hold this song dictionary, convert it to JSON string
    NSMutableArray* arrayToSend = [NSMutableArray arrayWithObject:songAddDictionary];;
    NSString* songAsJSONArray = [arrayToSend JSONString];
    
    // set up, send request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
    request.queue = client.requestQueue;
    request.method = RKRequestMethodPUT;
    NSMutableDictionary* headersWithContentType = [NSMutableDictionary dictionaryWithDictionary:self.headers];
    [headersWithContentType setObject:@"text/json" forKey:@"Content-Type"];
    request.additionalHTTPHeaders = headersWithContentType;
    request.HTTPBodyString = songAsJSONArray;
    
    //TODO: find a way to keep track of the requests
    //[currentRequests setObject:@"songAdd" forKey:request];
    [request send]; 
    
}

-(void)handleFailedSongAdd:(RKRequest *)request{
    UIAlertView* notification = [[UIAlertView alloc] initWithTitle:@"Song Add Failed" message:@"Your song was not confirmed as having been added to the playlist, would you like to try adding it again?" delegate:nil cancelButtonTitle:@"Yes" otherButtonTitles: nil];
    [notification show];
    [request send];
}

// **************************** Errors ********************************

// resetAcceptResponses: set acceptAuth, acceptEvents, etc. to NO
-(void)resetAcceptResponses{
    acceptAuth=NO;
    acceptEvents=NO;
    acceptPlaylist=NO;
    acceptLibSearch=NO;
}

// resetToEventView: return user to the event screen and reset all variables associated with the event
-(void)resetToEventView{
    NSString* msg = [NSString stringWithFormat:@"%@%@", [UDJEventData sharedEventData].currentEvent.name, @" has ended. You will be returned to the event search screen.", nil];
    UIAlertView* notification = [[UIAlertView alloc] initWithTitle:@"Event Ended" message: msg delegate: nil cancelButtonTitle:@"Back" otherButtonTitles:nil];
    [notification show];
    while(![self.navigationController.topViewController isMemberOfClass:[EventSearchViewController class]]){
        [self.navigationController popViewControllerAnimated:NO];
    }
    [self resetAcceptResponses];
    // dont need to reset sharedEventData, UDJPlaylist
}


// **************************** General Response Handling ********************************

// handles responses from the server
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSLog(@"Got a response from the server");
    // check if the event has ended
    if(response.statusCode == 410){
        [self resetToEventView];
    }
    else if ([request isGET]) {
        // playlist
        if(acceptPlaylist){
            [self handlePlaylistResponse:response];
        }
        else if(acceptLibSearch){
            [self handleLibSearchResults:response];
        }
        
    } else if([request isPOST]) {
        
        // authorization
        if(acceptAuth) {
            // valid credentials
            if([response isOK]) [self handleAuth:response];
            // invalid credentials
            else [self denyAuth:response];
        }/* was causing error
        if([currentRequests objectForKey:request]==@"voteRequest"){
            if(response.statusCode==408){
                NSLog(@"vote request timed out");
                [request send];
            }
            else if([response isOK]) [self handleVoteResponse:response];
        }*/
        

    } else if([request isPUT]){
       // do something (probably with a newly added song)
        /*if([currentRequests objectForKey:request]==@"songAdd" && response.statusCode==408){
            [self handleFailedSongAdd:request];
        }*/
        
    } else if([request isDELETE]) {
        
        // Handling DELETE /missing_resource.txt
        if([response isNotFound]) {
            NSLog(@"The resource path '%@' was not found.", [request resourcePath]);
        }
    }
}


@end
