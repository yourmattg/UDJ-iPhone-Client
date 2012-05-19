//
//  RandomViewController.m
//  UDJ
//
//  Created by Matthew Graf on 5/17/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "RandomViewController.h"
#import "RestKit/RestKit.h"
#import "RestKit/RKJSONParserJSONKit.h"
#import "UDJEventData.h"
#import "LibraryEntryCell.h"

@implementation RandomViewController

@synthesize searchIndicatorView, refreshButton, songTableView, resultList, globalData, currentRequestNumber;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    // Do any additional setup after loading the view from its nib.
    
    globalData = [UDJData sharedUDJData];
    MAX_RESULTS = 50;
    
    songTableView.hidden = YES;
    
    [self sendRandomSongRequest];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Tableview data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
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
    cell.addButton.titleLabel.text = song.title;
    
    [cell.addButton addTarget:self action:@selector(addButtonClick:)   
             forControlEvents:UIControlEventTouchUpInside];
    
    // TODO: check if song is already on playlist, yes = hide/fade add button
    
    return cell;
}


#pragma mark - Random song request methods

-(void)sendRandomSongRequest{
    
    // show refreshing indicator
    searchIndicatorView.hidden = NO;
    refreshButton.hidden = YES;
    
    
    RKClient* client = [RKClient sharedClient];
    
    //create url [GET] /udj/events/event_id/available_music/random_songs{?max_randoms=number_desired}
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingFormat:@"%@%d%@%d",@"/players/", [UDJEventData sharedEventData].currentEvent.eventId ,@"/available_music/random_songs?max_randoms=", MAX_RESULTS, nil];
    
    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
    request.queue = client.requestQueue;
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = globalData.headers;
    
    // track request number
    currentRequestNumber = [NSNumber numberWithInt: [UDJData sharedUDJData].requestCount];
    request.userData = [NSNumber numberWithInt: globalData.requestCount++];
    
    //send request
    [request send]; 
}

-(IBAction)refreshButtonClick:(id)sender{
    [self sendRandomSongRequest];
}



#pragma mark - Response handling

-(void)handleSearchResults:(RKResponse *)response{
    UDJSongList* tempList = [UDJSongList new];
    RKJSONParserJSONKit* parser = [RKJSONParserJSONKit new];
    NSArray* songArray = [parser objectFromString:[response bodyAsString] error:nil];
    for(int i=0; i<[songArray count]; i++){
        NSDictionary* songDict = [songArray objectAtIndex:i];
        UDJSong* song = [UDJSong songFromDictionary:songDict isLibraryEntry:YES];
        [tempList addSong:song];
    }
    
    self.resultList = tempList;
    
    // refresh table view, hide activity indicator
    [songTableView reloadData];
    searchIndicatorView.hidden = YES;
    refreshButton.hidden = NO;
    songTableView.hidden = NO;
}

// Handle responses from the server
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response { 
    
    NSLog(@"status code %d", [response statusCode]);
    
    NSNumber* requestNumber = request.userData;
    NSDictionary* headerDict = [response allHeaderFields];
    
    if(![requestNumber isEqualToNumber: currentRequestNumber]) return;
    
    // check if player has ended
    if(response.statusCode == 404){
        if([[headerDict objectForKey: @"X-Udj-Missing-Resource"] isEqualToString:@"player"]){}
        //[self resetToPlayerResultView];
    }
    else if ([request isGET] && [response isOK]) {
        [self handleSearchResults: response];
    }
    
    self.currentRequestNumber = [NSNumber numberWithInt: -1];
}

@end
