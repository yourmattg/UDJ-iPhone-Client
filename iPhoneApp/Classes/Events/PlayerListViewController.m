//
//  PlayerListViewController.m
//  UDJ
//
//  Created by Matthew Graf on 5/24/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "PlayerListViewController.h"
#import "RestKit/RKJSONParserJSONKit.h"

@interface PlayerListViewController ()

@end

@implementation PlayerListViewController

@synthesize eventData, tableList, tableView;
@synthesize statusLabel, globalData, currentRequestNumber;
@synthesize playerSearchBar, findNearbyButton, searchIndicatorView;
@synthesize lastSearchType;


#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"hurp");
    
    self.tableList = [[NSMutableArray alloc] init];
    
    self.globalData = [UDJData sharedUDJData];
    
    // set up eventData and get nearby events
    self.eventData = [UDJEventData sharedEventData];
    self.eventData.getEventsDelegate = self;
    self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
    
    // initialize search bar
    playerSearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - UI Events
// Hide the keyboard when user hits return
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}


#pragma mark Event search methods

-(void)showResultsMessage{
    
    if(lastSearchType == SearchTypeName){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No Players Found" message:@"Sorry, there were no players that matched the name you specified." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        [statusLabel setText: @"No players found"];
    }
    else if(lastSearchType == SearchTypeNearby){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No Players Found" message:@"Sorry, there are no active players near you." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];  
        [statusLabel setText: @"No players found"];
    }
    
    lastSearchType = SearchTypeNull;

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
    
    // refresh table
}

// Handle responses from the server
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSLog(@"status code %d", [response statusCode]);
    
    NSNumber* requestNumber = request.userData;
    
    if(![requestNumber isEqualToNumber: currentRequestNumber]) return;
    
    if ([request isGET]) {
        // TODO: change isNearbySearch accordingly
        [self handleEventResults:response];        
    }
    
    self.currentRequestNumber = [NSNumber numberWithInt: -1];
}

@end
