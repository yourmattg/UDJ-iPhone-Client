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

#import "LibraryResultsController.h"
#import "UDJConnection.h"
#import "UDJEventData.h"
#import "LibraryEntryCell.h"
#import "SearchingViewController.h"

@implementation LibraryResultsController

@synthesize resultList, selectedSong, tableView, statusLabel, randomButton, backButton, globalData, currentRequestNumber, searchingLabel, searchingIndicator;


-(void)resetToPlayerResultView{
    // return to player search results screen
    NSInteger numViewControllers = [self.navigationController.viewControllers count];
    UIViewController* targetViewController = [self.navigationController.viewControllers objectAtIndex: numViewControllers - 4];
    [self.navigationController popToViewController: targetViewController animated: YES];
    
    // alert user that player is inactive
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Player Inactive" message: @"The player you are trying to access is now inactive." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

-(void)toggleSearchingStatus:(BOOL)active{
    self.randomButton.hidden = active;
    self.searchingIndicator.hidden = !active;
    self.searchingLabel.hidden = !active;
}


-(void)sendRandomSongRequest:(NSInteger)eventId maxResults:(NSInteger)maxResults{
    RKClient* client = [RKClient sharedClient];
    
    //create url [GET] /udj/events/event_id/available_music/random_songs{?max_randoms=number_desired}
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingFormat:@"%@%d%@%d",@"/players/",eventId,@"/available_music/random_songs?max_randoms=",maxResults];
    
    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
    request.queue = client.requestQueue;
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = globalData.headers;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++];
    
    //send request
    [request send]; 
}

-(void)sendAddSongRequest:(NSInteger)librarySongId eventId:(NSInteger)eventId{
    RKClient* client = [RKClient sharedClient];
    
    //create url [PUT] /udj/events/event_id/active_playlist/songs
    NSString* urlString = [NSString stringWithFormat:@"%@%@%d%@%d",client.baseURL,@"/players/",eventId,@"/active_playlist/songs/",librarySongId, nil];
    
    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
    request.queue = client.requestQueue;
    request.method = RKRequestMethodPUT;
    request.additionalHTTPHeaders = globalData.headers;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++];
    
    //TODO: find a way to keep track of the requests
    //[currentRequests setObject:@"songAdd" forKey:request];
    [request send]; 
    
}

// backToLibSearch: go back to the library search screen
- (IBAction)backButtonClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)randomButtonClick:(id)sender{
    // make sure the table view is showing
    self.statusLabel.text = @"";
    self.tableView.hidden = NO;
    
    NSInteger eventIdParam = [UDJEventData sharedEventData].currentEvent.eventId;
    NSInteger maxResultsParam = 50;
    
    // show "searching" status
    [self toggleSearchingStatus: YES];
    
    // have UDJConnection send a request
    self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
    [self sendRandomSongRequest:eventIdParam maxResults:maxResultsParam];
 
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
    
    self.statusLabel.numberOfLines = 0;
    
    [self toggleSearchingStatus: NO];
    
    self.globalData = [UDJData sharedUDJData];
    
    /*
    self.navigationItem.title = @"Search Results";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backToLibSearch)];
    self.navigationItem.leftBarButtonItem = backButton;
    */
    
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
    [super viewDidAppear:animated];
    if([resultList count] == 0){
        self.statusLabel.text = @"There were no songs that matched your search query.\n\n If you're having trouble finding songs, try using the find random feature to get a sample of the host's music library.";
        self.tableView.hidden = YES;
    }
    else{
        self.statusLabel.text = @"";
        self.tableView.hidden = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [resultList count];
}

- (UITableViewCell *)tableView:(UITableView *)TableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    LibraryEntryCell* cell = [TableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[LibraryEntryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UDJSong* song = [resultList songAtIndex:indexPath.row];
    cell.songLabel.text = song.title;
    cell.artistLabel.text = song.artist;
    cell.addButton.tag = song.librarySongId;
    
    cell.parentViewController = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowNumber = indexPath.row;
    self.selectedSong = [resultList songAtIndex:rowNumber];
}


-(void)handleLibSearchResults:(RKResponse *)response{
    UDJSongList* tempList = [UDJSongList new];
    RKJSONParserJSONKit* parser = [RKJSONParserJSONKit new];
    NSArray* songArray = [parser objectFromString:[response bodyAsString] error:nil];
    for(int i=0; i<[songArray count]; i++){
        NSDictionary* songDict = [songArray objectAtIndex:i];
        UDJSong* song = [UDJSong songFromDictionary:songDict isLibraryEntry:YES];
        [tempList addSong:song];
    }

    [self toggleSearchingStatus: NO];
    
    self.resultList = tempList;
    [self.tableView reloadData];
}

// Handle responses from the server
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response { 
    
    NSLog(@"status code %d", [response statusCode]);
    
    NSNumber* requestNumber = request.userData;
    NSDictionary* headerDict = [response allHeaderFields];
    
    //NSLog([NSString stringWithFormat: @"response number %d, waiting on %d", [requestNumber intValue], [currentRequestNumber intValue]]);
    
    if(![requestNumber isEqualToNumber: currentRequestNumber]) return;
    
    // check if player is inactive
    if(response.statusCode == 404){
        if([[headerDict objectForKey: @"X-Udj-Missing-Resource"] isEqualToString:@"player"])
            [self resetToPlayerResultView];
    }
    else if ([request isGET]) {
        [self handleLibSearchResults: response];        
    }
    
    self.currentRequestNumber = [NSNumber numberWithInt: -1];
}


@end
