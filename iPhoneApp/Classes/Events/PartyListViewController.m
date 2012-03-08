//
//  PartyListViewController.m
//  UDJ
//
//  Created by Matthew Graf on 9/24/11.
//  Copyright 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "PartyListViewController.h"
#import "PartyLoginViewController.h"
#import "UDJConnection.h"
#import "UDJEventList.h"
#import "UDJEvent.h"
#import "PartySearchViewController.h"
#import "PlaylistViewController.h"


@implementation PartyListViewController

@synthesize tableList, eventList, tableView, searchResultLabel;


#pragma mark -
#pragma mark View lifecycle

// logOutOfEvent: log the client out of the current event
- (void)logOutOfEvent{
    NSInteger statusCode = [[UDJConnection sharedConnection] leaveEventRequest];
    if(statusCode==200){
        [UDJEventList sharedEventList].currentEvent=nil;
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
}

- (void)pushSearchScreen{
    PartySearchViewController* partySearchViewController = [[PartySearchViewController alloc] initWithNibName:@"PartySearchViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:partySearchViewController animated:YES];
}

- (void)refreshTableList{
    [tableList removeAllObjects];
    int size = [eventList.currentList count];
    for(int i=0; i<size; i++){
        UDJEvent* event = [eventList.currentList objectAtIndex:i];
        NSString* partyName = event.name;
        [tableList addObject:partyName];
    }
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //[[UDJConnection sharedConnection] setCurrentController: self];
    
	self.tableList = [[NSMutableArray alloc] init];
	self.navigationItem.title = @"Events";
	[self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:[UIView new]]];
    // set up search button
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(pushSearchScreen)]];
    // make a new event list
    eventList = [UDJEventList sharedEventList];
    [eventList getNearbyEvents];
    [self refreshTableList];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

// overridden so that party table refreshes
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refreshTableList];
    if([[UDJEventList sharedEventList].currentList count] == 0){
        NSLog(@"empty");
        if([UDJEventList sharedEventList].lastSearchType == @"Nearby"){
            self.searchResultLabel.text = @"No nearby events were found.";
        }
        else if([UDJEventList sharedEventList].lastSearchType == @"Name"){
            self.searchResultLabel.text = @"No events were found that matched your query";
        }
        else{
            self.searchResultLabel.text = @"Press the search button to find events";
        }
        [UDJEventList sharedEventList].lastSearchType = nil;
    }
    else self.searchResultLabel.text = @"";
    
}

/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


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


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

// user selects a cell: attempt to enter that party
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // get the party and remember the event we are trying to join
    NSInteger index = [indexPath indexAtPosition:1];
    [UDJEventList sharedEventList].currentEvent = [[UDJEventList sharedEventList].currentList objectAtIndex:index];
    // there's a password: go the password screen
	if([UDJEventList sharedEventList].currentEvent.hasPassword){
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
            NSString* msg = [NSString stringWithFormat:@"%@%@%@", @"You are already logged into another event, \"", [UDJEventList sharedEventList].currentEvent.name, @"\". Would you like to log out of that event or rejoin it?", nil];
            UIAlertView* alreadyInEvent = [[UIAlertView alloc] initWithTitle:@"Event Conflict" message: msg delegate: self cancelButtonTitle:@"Log Out" otherButtonTitles:@"Rejoin",nil];
            [alreadyInEvent show];
        }
        // TODO: add other event possibilities (see API)
    }
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

