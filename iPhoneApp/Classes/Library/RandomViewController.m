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

#import "RandomViewController.h"
#import "RestKit/RestKit.h"
#import "RestKit/RKJSONParserJSONKit.h"
#import "UDJEventData.h"
#import "LibraryEntryCell.h"
#import "UDJPlaylist.h"

@implementation RandomViewController

@synthesize resultList, globalData, currentRequestNumber;
@synthesize addNotificationView, addNotificationLabel;

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


#pragma mark - Song adding


-(void)hideAddNotification:(id)arg{
    [NSThread sleepForTimeInterval:2];
    [UIView animateWithDuration:1.0 animations:^{
        addNotificationView.alpha = 0;
    }];
}

// briefly show the vote notification view
-(void)showAddNotification:(NSString*)title{
    addNotificationLabel.text = title;
    
    [self.view addSubview: addNotificationView];
    addNotificationView.alpha = 0;
    addNotificationView.frame = CGRectMake(20, 370, 280, 32);
    [UIView animateWithDuration:0.5 animations:^{
        addNotificationView.alpha = 1;
    } completion:^(BOOL finished){
        if(finished){
            [NSThread detachNewThreadSelector:@selector(hideAddNotification:) toTarget:self withObject:nil];
        }
    }];
}

-(void)sendAddSongRequest:(NSInteger)librarySongId playerID:(NSInteger)playerID{
    RKClient* client = [RKClient sharedClient];
    
    //create url [PUT] /udj/events/event_id/active_playlist/songs
    NSString* urlString = [NSString stringWithFormat:@"%@%@%d%@%d",client.baseURL,@"/players/",playerID,@"/active_playlist/songs/",librarySongId, nil];
    
    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
    request.queue = client.requestQueue;
    request.method = RKRequestMethodPUT;
    request.additionalHTTPHeaders = globalData.headers;
    
    // remember song number
    request.userData = [NSNumber numberWithInt: librarySongId];
    
    //TODO: find a way to keep track of the requests
    //[currentRequests setObject:@"songAdd" forKey:request];
    [request send]; 
    
}

-(IBAction)addButtonClick:(id)sender{
    UIButton* button = (UIButton*)sender;
    [self sendAddSongRequest: button.tag playerID: [UDJEventData sharedEventData].currentEvent.eventId];
    [self showAddNotification: button.titleLabel.text];
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

-(void)refresh{
    [self sendRandomSongRequest];
}

-(void)sendRandomSongRequest{
    
    RKClient* client = [RKClient sharedClient];
    
    //create url [GET] /udj/events/event_id/available_music/random_songs{?max_randoms=number_desired}
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingFormat:@"%@%d%@%d",@"/players/", [UDJEventData sharedEventData].currentEvent.eventId ,@"/available_music/random_songs?max_randoms=", MAX_RESULTS, nil];
    
    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
    request.queue = client.requestQueue;
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = globalData.headers;
    
    //send request
    [request send]; 
}

-(IBAction)refreshButtonClick:(id)sender{
    [self sendRandomSongRequest];
}



#pragma mark - Response handling

-(void)resetToPlayerResultView{
    
    [self.navigationController.navigationController popViewControllerAnimated:YES];
    
    // alert user that player is inactive
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Player Inactive" message: @"The player you are trying to access is now inactive." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

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
    [self.tableView reloadData];
}

// Handle responses from the server
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response { 
    
    NSLog(@"status code %d", [response statusCode]);
    
    NSDictionary* headerDict = [response allHeaderFields];
    
    // check if player has ended
    if(response.statusCode == 404){
        if([[headerDict objectForKey: @"X-Udj-Missing-Resource"] isEqualToString:@"player"])
            [self resetToPlayerResultView];
    }
    else if ([request isGET] && [response isOK]) {
        [self handleSearchResults: response];
    }
    
    // Song conflicts i.e. song we tried to add is already on the playlist
    else if(response.statusCode == 409){
        // get the song number, vote up
        NSNumber* songNumber = request.userData;
        [[UDJPlaylist sharedUDJPlaylist] sendVoteRequest:YES songId: [songNumber intValue]];
    }
    
    // check if our ticket was invalid
    if(response.statusCode == 401 && [[headerDict objectForKey: @"WWW-Authenticate"] isEqualToString: @"ticket-hash"])
        [globalData renewTicket];
    
    // hide the pulldown refresh
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:0];

}

@end
