/**
 * Copyright 2011 Matthew M. Graf
 *
 * This file is part of UDJ.
 *
 * UDJ is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * UDJ is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with UDJ.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "EventSearchViewController.h"
#import "PartyLoginViewController.h"
#import "UDJEventData.h"
#import "UDJEvent.h"
#import "PlaylistViewController.h"
#import "EventResultsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RestKit/RKJSONParserJSONKit.h"


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
    
    /*
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:(57.0/255.0) green:(97.0/255.0) blue:(127.0/255.0) alpha:1];*/
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
    
    // if search query is blank, alert the user
    if([searchParam isEqualToString:@""]){
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Query" message:@"You forgot to enter something in the search field." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
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
    self.currentRequestNumber = [NSNumber numberWithInt: -1];
    [self toggleSearchingView: NO];
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





#pragma mark Event search methods

-(void)showResultsMessage{
    
    self.searchingView.hidden = YES;
    
    if(lastSearchType == @"Name"){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No Players Found" message:@"Sorry, there were no players that matched the name you specified." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
    else if(lastSearchType == @"Nearby"){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No Players Found" message:@"Sorry, there are no active players near you." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
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
    NSLog(@"got response");
    NSLog(@"status code %d", [response statusCode]);
    
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
    
    self.currentRequestNumber = [NSNumber numberWithInt: -1];
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

