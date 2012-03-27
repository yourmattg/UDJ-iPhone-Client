//
//  LibraryResultsController.m
//  UDJ
//
//  Created by Matthew Graf on 1/7/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "LibraryResultsController.h"
#import "UDJConnection.h"
#import "UDJEventData.h"
#import "LibraryEntryCell.h"
#import "SearchingViewController.h"

@implementation LibraryResultsController

@synthesize resultList, selectedSong, tableView, statusLabel, randomButton, backButton, globalData, currentRequestNumber, searchingLabel, searchingIndicator;

-(void)toggleSearchingStatus:(BOOL)active{
    self.randomButton.hidden = active;
    self.searchingIndicator.hidden = !active;
    self.searchingLabel.hidden = !active;
}


-(void)sendRandomSongRequest:(NSInteger)eventId maxResults:(NSInteger)maxResults{
    RKClient* client = [RKClient sharedClient];
    
    //create url [GET] /udj/events/event_id/available_music/random_songs{?max_randoms=number_desired}
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingFormat:@"%@%d%@%d",@"/events/",eventId,@"/available_music/random_songs?max_randoms=",maxResults];
    
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
    
    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
    request.queue = client.requestQueue;
    request.method = RKRequestMethodPUT;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++];
    NSMutableDictionary* headersWithContentType = [NSMutableDictionary dictionaryWithDictionary: globalData.headers];
    [headersWithContentType setObject:@"text/json" forKey:@"Content-Type"];
    request.additionalHTTPHeaders = headersWithContentType;
    request.HTTPBodyString = songAsJSONArray;
    
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
    
    NSNumber* requestNumber = request.userData;
    
    //NSLog([NSString stringWithFormat: @"response number %d, waiting on %d", [requestNumber intValue], [currentRequestNumber intValue]]);
    
    if(![requestNumber isEqualToNumber: currentRequestNumber]) return;
    
    // check if the event has ended
    if(response.statusCode == 410){
        //[self resetToEventView];
    }
    else if ([request isGET]) {
        [self handleLibSearchResults: response];        
    }
    
    self.currentRequestNumber = [NSNumber numberWithInt: -1];
}


@end
