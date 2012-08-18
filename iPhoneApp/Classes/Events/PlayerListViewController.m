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

#import "PlayerListViewController.h"
#import "RestKit/RKJSONParserJSONKit.h"
#import "PlayerCell.h"
#import "MainTabBarController.h"
#import "PlayerInfoViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "PlayerInfoViewController.h"
#import "UDJPlayerManager.h"

@interface PlayerListViewController ()

@end

@implementation PlayerListViewController

@synthesize eventData, tableList, tableView;
@synthesize statusLabel, globalData, currentRequestNumber;
@synthesize playerSearchBar, findNearbyButton, cancelSearchButton, searchIndicatorView;
@synthesize lastSearchType, lastSearchQuery;
@synthesize joiningBackgroundView, joiningView;
@synthesize shouldShowMyPlayer;

#pragma mark - Alert view delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if([alertView.title isEqualToString:@"Password Required"]){
        if(buttonIndex == 1){
            // send an event join request with the password specified
            [self toggleJoiningView: YES];
            self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
            [[UDJPlayerData sharedEventData] enterEvent: [alertView textFieldAtIndex:0].text];
        }
        else{
            [self.tableView reloadData];
        }
    }
}


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
    
    [self toggleJoiningView: NO];
    
    self.tableList = [[NSMutableArray alloc] init];
    
    self.globalData = [UDJData sharedUDJData];
    
    // initialize login view
    joiningView.layer.cornerRadius = 8;
    joiningView.layer.borderColor = [[UIColor whiteColor] CGColor];
    joiningView.layer.borderWidth = 3;
    
    // set up eventData and get nearby events
    self.eventData = [UDJPlayerData sharedEventData];
    self.eventData.playerListDelegate = self;
    self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
    
    // initialize search bar
    playerSearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
         
    self.navigationController.toolbar.tintColor = [UIColor colorWithRed:(35.0/255.0) green:(59.0/255.0) blue:(79.0/255.0) alpha:1];
    self.navigationController.toolbarHidden = NO;
    
    UIBarButtonItem* createPlayerButton = [[UIBarButtonItem alloc] initWithTitle:@"My Player" style:UIBarButtonItemStyleBordered target:self action:@selector(createPlayerClick)];
    UIBarButtonItem* flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = [NSArray arrayWithObjects: flexible, createPlayerButton, nil];
    
    self.shouldShowMyPlayer = NO;
    
    [self findNearbyPlayers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    [self toggleJoiningView: NO];
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden: NO animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden: YES animated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear: animated];

    [UDJPlayerManager sharedPlayerManager].isInPlayerMode = NO;
    
    if(shouldShowMyPlayer){
        shouldShowMyPlayer = NO;
        MainTabBarController* tabBarController = [[MainTabBarController alloc] initWithNibName:@"MainTabBarController" bundle: [NSBundle mainBundle]];
        [tabBarController initForPlayerMode: YES];
        [self.navigationController pushViewController: tabBarController animated:YES];          
    }
}



#pragma mark - Player creation methods

-(void)createPlayerClick{
    UDJPlayerManager* playerManager = [UDJPlayerManager sharedPlayerManager];
    if(playerManager.playerID == -1){
        PlayerInfoViewController* viewController = [[PlayerInfoViewController alloc] initWithNibName:@"PlayerInfoViewController" bundle:[NSBundle mainBundle]];
        [self presentModalViewController:viewController animated:YES];
        viewController.parentViewController = self;
    }
    else{
        MainTabBarController* tabBarController = [[MainTabBarController alloc] initWithNibName:@"MainTabBarController" bundle: [NSBundle mainBundle]];
        [tabBarController initForPlayerMode: YES];
        [self.navigationController pushViewController: tabBarController animated:YES];        
    }
}



#pragma mark - UI Events

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

-(IBAction)findNearbyButtonClick:(id)sender{
    [playerSearchBar resignFirstResponder];
    [self findNearbyPlayers];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar*)theSearchBar{
    
    [UIView animateWithDuration:0.5 animations:^{
        cancelSearchButton.alpha = 1;
        cancelSearchButton.frame = CGRectMake(250, 8, 60, 29);
        findNearbyButton.alpha = 0;
        findNearbyButton.frame = CGRectMake(249, -18, 61, 29);
    }];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar{
    [theSearchBar resignFirstResponder];
    
    NSString* searchParam = theSearchBar.text;
    
    // if the search query is invalid, alert the user
    if(![self isValidSearchQuery:searchParam]){
        UIAlertView* invalidSearchParam = [[UIAlertView alloc] initWithTitle:@"Invalid Query" message:@"Your search query can only contain alphanumeric characters. This includes A-Z, 0-9." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [invalidSearchParam show];
    }
    
    else if(![searchParam isEqualToString:@""]) [self findPlayersByName: searchParam];
    
    [UIView animateWithDuration:0.5 animations:^{
        cancelSearchButton.alpha = 0;
        cancelSearchButton.frame = CGRectMake(250, -18, 60, 29);
        findNearbyButton.alpha = 1;
        findNearbyButton.frame = CGRectMake(249, 8, 61, 29);
    }];
    
}

-(IBAction)cancelSearchButtonClick:(id)sender{
    [UIView animateWithDuration:0.5 animations:^{
        cancelSearchButton.alpha = 0;
        cancelSearchButton.frame = CGRectMake(250, -18, 60, 29);
        findNearbyButton.alpha = 1;
        findNearbyButton.frame = CGRectMake(249, 8, 61, 29);
    }];
    [playerSearchBar resignFirstResponder];
}


// Hide the keyboard when user hits return
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}


#pragma mark - Animation methods

-(void)hideCancelButton{
    
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
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)TableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    PlayerCell *cell = [TableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PlayerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSInteger row = indexPath.row;
    UDJPlayer* event = [tableList objectAtIndex: row];
    
    cell.eventNameLabel.text = event.name;
    cell.backgroundColor = [UIColor clearColor];
    cell.cellImageView.backgroundColor = [UIColor colorWithRed:149 green:207 blue:233 alpha: 0.3];
    return cell;
}


#pragma mark - Table view delegate

// user selects a cell: attempt to enter that party
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PlayerCell* cell = (PlayerCell*) [self.tableView cellForRowAtIndexPath: indexPath];
    cell.cellImageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:255 alpha: 0.3];
    
    // get the party and remember the event we are trying to join
    NSInteger index = [indexPath indexAtPosition:1];
    
    // get the event corresponding to that index
    [UDJPlayerData sharedEventData].currentPlayer = [[UDJPlayerData sharedEventData].currentList objectAtIndex:index];
    
    // there's a password: go the password screen
    if([UDJPlayerData sharedEventData].currentPlayer.hasPassword){
        UIAlertView* passwordAlertView = [[UIAlertView alloc] initWithTitle:@"Password Required" message:@"This player requires a password." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Enter", nil];
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



#pragma mark - Event search methods

// check if this is a valid query
-(BOOL) isValidSearchQuery:(NSString*)string{
    NSCharacterSet *alphaSet = [NSCharacterSet alphanumericCharacterSet];
    NSString* testString = [NSString stringWithString: string];
    testString = [testString stringByReplacingOccurrencesOfString:@" " withString:@""];
    BOOL valid = [[testString stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""];
    return valid;
}

-(void)findNearbyPlayers{
    // update status label
    [statusLabel setText: @"Searching for nearby players"];
    searchIndicatorView.hidden = NO;
    
    self.lastSearchType = SearchTypeNearby;
    self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
    [eventData getNearbyEvents];
}

-(void)findPlayersByName:(NSString*)name{
    
    // update status label
    [statusLabel setText: [NSString stringWithFormat: @"Searching for '%@'", name]];
    searchIndicatorView.hidden = NO;
    
    // remember last search type/query
    self.lastSearchType = SearchTypeName;
    self.lastSearchQuery = name;
    
    self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
    [eventData getEventsByName: name];
}


#pragma mark - Error messages
-(void) showEventNotFoundError{
    UIAlertView* nonExistantEvent = [[UIAlertView alloc] initWithTitle:@"Player Inactive" message:@"The player you are trying to access is inactive." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [nonExistantEvent show];
    
    [self toggleJoiningView: NO];
    [self.tableView reloadData];
}

-(void) showWrongPasswordError{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Access Denied" message:@"You have entered an incorrect password for the player." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    [self toggleJoiningView: NO];
    [self.tableView reloadData];
}

-(void)showPlayerInactiveError{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Player Inactive" message:@"The player you are trying to access is now inactive" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    
    [self toggleJoiningView: NO];
    [tableView reloadData];
}



#pragma mark - Response handling

-(void)showResultsMessage:(BOOL)found{
    
    searchIndicatorView.hidden = YES;
    
    // if we didn't find any players, let user know
    if(!found){
        if(lastSearchType == SearchTypeName){
            [statusLabel setText: [NSString stringWithFormat: @"No players found matching '%@'", lastSearchQuery]];
        }
        else if(lastSearchType == SearchTypeNearby){
            [statusLabel setText: @"No nearby players found"];
        }        
    }
    
    // otherwise show appropriate description
    else{
        if(lastSearchType == SearchTypeName)
            [statusLabel setText: [NSString stringWithFormat: @"Players matching '%@'", lastSearchQuery, nil]];
        else if(lastSearchType == SearchTypeNearby)
            [statusLabel setText: @"Nearby players"];        
    }
    
    lastSearchType = SearchTypeNull;
}


// joinEvent: login was successful, show playlist view
-(void) joinEvent{
    MainTabBarController* viewController = [[MainTabBarController alloc] initWithNibName:@"MainTabBarController" bundle:[NSBundle mainBundle]];
    [viewController initForPlayerMode: NO];
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void)refreshTableList{
    [tableList removeAllObjects];
    /*
    int size = [eventData.currentList count];
    for(int i=0; i<size; i++){
        UDJEvent* event = [eventData.currentList objectAtIndex:i];
        NSString* partyName = event.name;
        [tableList addObject:partyName];
        NSLog(partyName);
    }*/
    self.tableList = eventData.currentList;
    [self.tableView reloadData];
}

// handleEventResults: get the list of returned events from either the name or location search
- (void) handleEventResults:(RKResponse*)response{
    
    // hide the activity indicator
    searchIndicatorView.hidden = YES;
    
    // Parse the response into an array of UDJEvents
    NSMutableArray* cList = [NSMutableArray new];
    RKJSONParserJSONKit* parser = [RKJSONParserJSONKit new];
    NSArray* eventArray = [parser objectFromString:[response bodyAsString] error:nil];
    for(int i=0; i<[eventArray count]; i++){
        NSDictionary* eventDict = [eventArray objectAtIndex:i];
        UDJPlayer* event = [UDJPlayer eventFromDictionary:eventDict];
        [cList addObject:event];
    }
    
    // Update the global event list
    [UDJPlayerData sharedEventData].currentList = cList;
    
    // update status label accordingly
    if([cList count] == 0) [self showResultsMessage:NO];
    else [self showResultsMessage: YES];
    
    // refresh table
    [self refreshTableList];
}

// Handle responses from the server
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSLog(@"status code %d", [response statusCode]);
    
    NSNumber* requestNumber = request.userData;
    NSDictionary* headerDict = [response allHeaderFields];
    
    if(![requestNumber isEqualToNumber: currentRequestNumber]) return;
    
    if ([request isGET]) {
        // TODO: change isNearbySearch accordingly
        [self handleEventResults:response];        
    }
    
    else if([request isPUT]){
        
        if(response.statusCode == 201)
            [self joinEvent];
        
        else if(response.statusCode == 404){
            [self showPlayerInactiveError];
        }
        
        // let user know they entered the wrong password
        else if(response.statusCode == 401 && [[headerDict objectForKey: @"WWW-Authenticate"] isEqualToString: @"player-password"])
            [self showWrongPasswordError];
        
    } 
    
    // check if our ticket was invalid
    if(response.statusCode == 401 && [[headerDict objectForKey: @"WWW-Authenticate"] isEqualToString: @"ticket-hash"])
        [globalData renewTicket];
    
    self.currentRequestNumber = [NSNumber numberWithInt: -1];
}

@end
