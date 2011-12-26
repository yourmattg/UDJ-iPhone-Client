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
#import "EventList.h"
#import "UDJEvent.h"
#import "PartySearchViewController.h"


@implementation PartyListViewController

@synthesize tableList, eventList;


#pragma mark -
#pragma mark View lifecycle

- (IBAction)pushSearchScreen:(id)sender{
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
    [[EventList sharedEventList] setRefresh:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UDJConnection sharedConnection] setCurrentController: self];
	tableList = [[NSMutableArray alloc] init];
	[tableList addObject: @"Toga Party"];
	[tableList addObject: @"Classy Party"];
	[tableList addObject: @"21st Bday"];
	self.navigationItem.title = @"Nearby Parties";
	[self.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithCustomView:[[UIView new] autorelease]] autorelease]];

    // set up search button
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIButtonTypeRoundedRect target:self action:NULL]];
    
    // make a new event list
    eventList = [EventList new];
    [eventList getEventsByName:@"Party"];
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	NSString* cellValue = [tableList objectAtIndex:indexPath.row];
	cell.textLabel.text = cellValue;
	cell.textLabel.textColor=[UIColor whiteColor];
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	
	PartyLoginViewController* partyLoginViewController = [[PartyLoginViewController alloc] initWithNibName:@"PartyLoginViewController" bundle:[NSBundle mainBundle]];
	[self.navigationController pushViewController:partyLoginViewController animated:YES];
	
    // ...
    // Pass the selected object to the new view controller.
    //[self.navigationController pushViewController:partyLogin animated:YES];
    //[partyLogin release];
    
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


- (void)dealloc {
    [super dealloc];
}


@end

