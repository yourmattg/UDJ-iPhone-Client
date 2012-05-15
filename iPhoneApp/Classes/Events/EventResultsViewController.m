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

#import "EventResultsViewController.h"
#import "UDJEvent.h"
#import "PartyLoginViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation EventResultsViewController

@synthesize tableList, tableView, eventData, currentRequestNumber, globalData, joiningView, joiningBackgroundView, cancelButton;

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    // handle event conflicts
    if([alertView.title isEqualToString:@"Event Conflict"]){
        
        // log the user out of the last event
        if(buttonIndex == 0){
            [self toggleJoiningView:NO];
            self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
            //[[UDJEventData sharedEventData] leaveEvent];
        }
        // join the event the user was logged into
        else if(buttonIndex == 1){
            [self joinEvent];
        }
    }
    
    // send a join request with a password
    else if([alertView.title isEqualToString:@"Password Required"]){
        if(buttonIndex == 1){
            // send an event join request with the password specified
            [self toggleJoiningView: YES];
            self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
            [[UDJEventData sharedEventData] enterEvent: [alertView textFieldAtIndex:0].text];
        }
        else{
            [self.tableView reloadData];
        }
    }
}

// Show or hide the "joining event..." view; active = YES will show the view
-(void) toggleJoiningView:(BOOL) active{
    joiningBackgroundView.hidden = !active;
}

// When user presses cancel, hide login view and let controller know
// we aren't waiting on any requests
-(IBAction)cancelButtonClick:(id)sender{
    self.currentRequestNumber = [NSNumber numberWithInt: -1];
    [self.tableView reloadData];
    [self toggleJoiningView:NO];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self toggleJoiningView: NO];
    
    // initialize login view
    joiningView.layer.cornerRadius = 8;
    joiningView.layer.borderColor = [[UIColor whiteColor] CGColor];
    joiningView.layer.borderWidth = 3;
    
    self.globalData = [UDJData sharedUDJData];

    // initialize eventData
    self.eventData = [UDJEventData sharedEventData];
    self.eventData.enterEventDelegate = self;
    
    self.tableList = eventData.currentList;
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [UDJEventData sharedEventData].leaveEventDelegate = self;
    
    [self toggleJoiningView: NO];
    [self.tableView reloadData];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self toggleJoiningView: NO];
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




#pragma mark Button click methods

-(IBAction)newEventSearchButtonClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)TableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    EventCell *cell = [TableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[EventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSInteger row = indexPath.row;
    UDJEvent* event = [tableList objectAtIndex: row];
    
    cell.eventNameLabel.text = event.name;
    cell.backgroundColor = [UIColor clearColor];
    cell.cellImageView.backgroundColor = [UIColor colorWithRed:149 green:207 blue:233 alpha: 0.3];
    return cell;
}


#pragma mark - Table view delegate

// user selects a cell: attempt to enter that party
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EventCell* cell = (EventCell*) [self.tableView cellForRowAtIndexPath: indexPath];
    cell.cellImageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:255 alpha: 0.3];
    
    // get the party and remember the event we are trying to join
    NSInteger index = [indexPath indexAtPosition:1];

    // get the event corresponding to that index
    [UDJEventData sharedEventData].currentEvent = [[UDJEventData sharedEventData].currentList objectAtIndex:index];
    
    // there's a password: go the password screen
	if([UDJEventData sharedEventData].currentEvent.hasPassword){
        UIAlertView* passwordAlertView = [[UIAlertView alloc] initWithTitle:@"Password Required" message:@"This party requires a password." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Enter", nil];
        passwordAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [passwordAlertView textFieldAtIndex:0].placeholder = @"Password";
        [passwordAlertView show];
    }
    
    // no password: attempt login
    else{
        // send event request
        [self toggleJoiningView: YES];
        self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
        [eventData enterEvent:nil];
    }
    
}



#pragma mark Navigation methods

-(void) showPasswordScreen{
    PartyLoginViewController* partyLoginViewController = [[PartyLoginViewController alloc] initWithNibName:@"PartyLoginViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:partyLoginViewController animated:YES];   
}

// joinEvent: login was successful, show playlist view
-(void) joinEvent{
    PlaylistViewController* playlistViewController = [[PlaylistViewController alloc] initWithNibName:@"NewPlaylistViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:playlistViewController animated:YES];    
}




#pragma mark Error methods
-(void) showEventNotFoundError{
    UIAlertView* nonExistantEvent = [[UIAlertView alloc] initWithTitle:@"Join Failed" message:@"UDJ couldn't connect to the event" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [nonExistantEvent show];
    [self toggleJoiningView: NO];
    [self.tableView reloadData];
}

-(void) showAlreadyInEventError:(RKResponse*)response{
    
    [self.tableView reloadData];
    
    RKJSONParserJSONKit* parser = [RKJSONParserJSONKit new];
    NSDictionary* eventDict = [parser objectFromString:[response bodyAsString] error:nil];
    [UDJEventData sharedEventData].currentEvent = [UDJEvent eventFromDictionary:eventDict];
    
    NSString* msg = [NSString stringWithFormat:@"%@%@%@", @"You are already logged into another event, \"", [UDJEventData sharedEventData].currentEvent.name, @"\". Would you like to log out of that event or rejoin it?", nil];
    UIAlertView* alreadyInEvent = [[UIAlertView alloc] initWithTitle:@"Event Conflict" message: msg delegate: self cancelButtonTitle:@"Log Out" otherButtonTitles:@"Rejoin",nil];
    [alreadyInEvent show];
    
}

-(void)showLoggedOutMessage{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Logout Success" message:@"You are no longer logged in to any events." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}



#pragma mark Response handling

// Handle responses from the server
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSNumber* requestNumber = request.userData;
    
    NSLog(@"EventResultsViewController: status code %d", [response statusCode]);
    
    if(![requestNumber isEqualToNumber: currentRequestNumber]) return;
    
    // check if the event has ended
    if(response.statusCode == 410){
        //[self resetToEventView];
    } 
    else if([request isPUT]){
        
        if(response.statusCode == 201)
            [self joinEvent];
        
        else if(response.statusCode == 404)
            [self showEventNotFoundError];
        
        else if(response.statusCode == 409)
            [self showAlreadyInEventError:response];
        
    } 
    
    // let the user know they were logged out
    else if([request isDELETE] && [response isOK]){
        [self showLoggedOutMessage];
    }
    
    self.currentRequestNumber = [NSNumber numberWithInt: -1];
}

@end
