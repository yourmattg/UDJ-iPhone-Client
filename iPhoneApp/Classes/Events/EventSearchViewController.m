//
//  EventSearchViewController.m
//  UDJ
//
//  Created by Matthew Graf on 9/24/11.
//  Copyright 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "EventSearchViewController.h"
#import "PartyLoginViewController.h"
#import "UDJConnection.h"
#import "UDJEventData.h"
#import "UDJEvent.h"
#import "PlaylistViewController.h"
#import "EventResultsViewController.h"
#import <QuartzCore/QuartzCore.h>


@implementation EventSearchViewController

@synthesize tableList, eventData, tableView, searchResultLabel, globalData, currentRequestNumber, eventNameField, findNearbyButton, eventSearchButton, lastSearchType, searchingBackgroundView, searchingView;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.tableList = [[NSMutableArray alloc] init];
  
    self.globalData = [UDJData sharedUDJData];

    // set up eventData and get nearby events
    self.eventData = [UDJEventData sharedEventData];
    self.eventData.getEventsDelegate = self;
    self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
    
    // initialize login view
    searchingBackgroundView.hidden = YES;
    searchingView.layer.cornerRadius = 8;
    searchingView.layer.borderColor = [[UIColor whiteColor] CGColor];
    searchingView.layer.borderWidth = 3;
    
    // initialize eventNameField
    eventNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [self toggleSearchingView: NO];
}

// Show or hide the "Searching events" view; active = YES will show the view
-(void) toggleSearchingView:(BOOL) active{
    searchingBackgroundView.hidden = !active;
    searchingView.hidden = !active;
    eventSearchButton.enabled = !active;
    findNearbyButton.enabled = !active;
    eventNameField.enabled = !active;
}

// Hide the keyboard when user hits return
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
	return NO;
}

// logOutOfEvent: log the client out of the current event
- (void)logOutOfEvent{
    NSInteger statusCode = [[UDJConnection sharedConnection] leaveEventRequest];
    if(statusCode==200){
        [UDJEventData sharedEventData].currentEvent=nil;
        [[UDJPlaylist sharedUDJPlaylist] clearPlaylist];
        UIAlertView* loggedOut = [[UIAlertView alloc] initWithTitle:@"Logout Success" message:@"You are no longer logged into any events." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [loggedOut show];
    }
}

// rejoinEvent: rejoin the event the user was in
- (void)rejoinEvent{
    PlaylistViewController* playlistViewController = [[PlaylistViewController alloc] initWithNibName:@"NewPlaylistViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:playlistViewController animated:YES];
}

#pragma mark Button click methods

// check if this is a valid query
-(BOOL) isValidSearchQuery:(NSString*)string{
    NSCharacterSet *alphaSet = [NSCharacterSet alphanumericCharacterSet];
    NSString* testString = [NSString stringWithString: string];
    testString = [testString stringByReplacingOccurrencesOfString:@" " withString:@""];
    BOOL valid = [[testString stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""];
    return valid;
}

-(IBAction)searchButtonClick:(id)sender{
    
    NSString* searchParam = eventNameField.text;
    
    // if the search query is invalid, alert the user
    if(![self isValidSearchQuery:searchParam]){
        UIAlertView* invalidSearchParam = [[UIAlertView alloc] initWithTitle:@"Invalid Query" message:@"Your search query can only contain alphanumeric characters. This includes A-Z, 0-9." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [invalidSearchParam show];
        return;
    }
    
    // otherwise, send a search request
    else{
        self.lastSearchType = @"Name";
        self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
        [self toggleSearchingView: YES];
        [eventData getEventsByName: searchParam];
    }
}

-(IBAction)findNearbyButtonClick:(id)sender{
    self.lastSearchType = @"Nearby";
    self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
    [self toggleSearchingView: YES];
    [eventData getNearbyEvents];
}

// When user presses cancel, hide login view and let controller know
// we aren't waiting on any requests
-(IBAction)cancelButtonClick:(id)sender{
    self.currentRequestNumber = nil;
    [self toggleSearchingView: NO];
}

// handle button clicks from alertview (pop up message boxes)
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.title == @"Event Conflict"){
        // log out of the current event
        if(buttonIndex==0){
            [self logOutOfEvent];
        }
        // go back to the current event
        if(buttonIndex==1){
            [self rejoinEvent];
        }
    }
    else if(alertView.title == @"No Events Found"){
        [self toggleSearchingView: NO];
    }
}

- (void)refreshTableList{
    [tableList removeAllObjects];
    int size = [eventData.currentList count];
    for(int i=0; i<size; i++){
        UDJEvent* event = [eventData.currentList objectAtIndex:i];
        NSString* partyName = event.name;
        [tableList addObject:partyName];
    }
    [self.tableView reloadData];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

// overridden so that party table refreshes
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self toggleSearchingView:NO];
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [tableList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)TableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [TableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	
	NSString* cellValue = [tableList objectAtIndex:indexPath.row];
	cell.textLabel.text = cellValue;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:24];
	cell.textLabel.textColor=[UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    // Configure the cell...
    return cell;
}





#pragma mark -
#pragma mark Table view delegate

// user selects a cell: attempt to enter that party
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // get the party and remember the event we are trying to join
    NSInteger index = [indexPath indexAtPosition:1];
    [UDJEventData sharedEventData].currentEvent = [[UDJEventData sharedEventData].currentList objectAtIndex:index];
    // there's a password: go the password screen
	if([UDJEventData sharedEventData].currentEvent.hasPassword){
        PartyLoginViewController* partyLoginViewController = [[PartyLoginViewController alloc] initWithNibName:@"PartyLoginViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:partyLoginViewController animated:YES];
    }
    // no password: go straight to playlist
    else{
        NSInteger statusCode = [[UDJConnection sharedConnection] enterEventRequest];
        // 200: join success
        if(statusCode==201){
            PlaylistViewController* playlistViewController = [[PlaylistViewController alloc] initWithNibName:@"NewPlaylistViewController" bundle:[NSBundle mainBundle]];
            [self.navigationController pushViewController:playlistViewController animated:YES];
        }
        else if(statusCode==404){
            UIAlertView* nonExistantEvent = [[UIAlertView alloc] initWithTitle:@"Join Failed" message:@"The event you are trying to join does not exist. Sorry!" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [nonExistantEvent show];
        }
        else if(statusCode==409){
            NSString* msg = [NSString stringWithFormat:@"%@%@%@", @"You are already logged into another event, \"", [UDJEventData sharedEventData].currentEvent.name, @"\". Would you like to log out of that event or rejoin it?", nil];
            UIAlertView* alreadyInEvent = [[UIAlertView alloc] initWithTitle:@"Event Conflict" message: msg delegate: self cancelButtonTitle:@"Log Out" otherButtonTitles:@"Rejoin",nil];
            [alreadyInEvent show];
        }
        // TODO: add other event possibilities (see API)
    }
}

#pragma mark Event search methods

-(void)showResultsMessage{
    
    self.searchingView.hidden = YES;
    
    if(lastSearchType == @"Name"){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No Events Found" message:@"Sorry, there were no events that matched the name you specified." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
    else if(lastSearchType == @"Nearby"){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No Events Found" message:@"Sorry, there are no public events near you." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];        
    }
    
    lastSearchType = nil;
}

// handleEventResults: get the list of returned events from either the name or location search
- (void) handleEventResults:(RKResponse*)response{
    
    // Parse the response into an array of UDJEvents
    NSMutableArray* cList = [NSMutableArray new];
    RKJSONParserJSONKit* parser = [RKJSONParserJSONKit new];
    NSArray* eventArray = [parser objectFromString:[response bodyAsString] error:nil];
    for(int i=0; i<[eventArray count]; i++){
        NSDictionary* eventDict = [eventArray objectAtIndex:i];
        UDJEvent* event = [UDJEvent eventFromDictionary:eventDict];
        [cList addObject:event];
    }
    
    // Update the global event list
    [UDJEventData sharedEventData].currentList = cList;

    // show "No Events Found" message if there were no events,
    if([cList count] == 0) [self showResultsMessage];
    
    // otherwise push the event results page
    else {
        self.lastSearchType = nil;
        
        EventResultsViewController* viewController = [[EventResultsViewController alloc] initWithNibName:@"EventResultsViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

// Handle responses from the server
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSNumber* requestNumber = request.userData;
    
    if(![requestNumber isEqualToNumber: currentRequestNumber]) return;
    
    // check if the event has ended
    if(response.statusCode == 410){
        //[self resetToEventView];
    }
    else if ([request isGET]) {
        // TODO: change isNearbySearch accordingly
        [self handleEventResults:response];        
    }
    
    self.currentRequestNumber = nil;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}




@end

