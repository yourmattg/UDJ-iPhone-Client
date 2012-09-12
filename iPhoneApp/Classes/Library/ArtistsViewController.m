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

#import "ArtistsViewController.h"
#import "UDJPlayerData.h"
#import "SongListViewController.h"
#import "RestKit/RKJSONParserJSONKit.h"
#import "UDJPlaylist.h"

@implementation ArtistsViewController

@synthesize searchBar, cancelSearchButton, artistsArray, globalData;
@synthesize statusLabel, searchIndicatorView, currentRequestNumber;

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
    
    // get global data
    globalData = [UDJData sharedUDJData];
    
    // intialize artists array
    artistsArray = [[NSMutableArray alloc] initWithCapacity:50];
    
    // get artists
    [self sendArtistsRequest];
    
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark Search bar methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar{
    [theSearchBar resignFirstResponder];
    SongListViewController* songListViewController = [[SongListViewController alloc] initWithNibName:@"SongListViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController: songListViewController animated:YES];
    [songListViewController getSongsByQuery: theSearchBar.text];
    
    [UIView animateWithDuration:0.5 animations:^{
        cancelSearchButton.alpha = 0;
        cancelSearchButton.frame = CGRectMake(320, 8, 60, 29); // x usually is 250
        searchBar.frame = CGRectMake(0, 0, 320, 44);
    }];
    
    searchBar.showsScopeBar = NO;  
    [searchBar sizeToFit];    
    [searchBar setShowsCancelButton:NO animated:YES]; 
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar{
    searchBar.showsScopeBar = NO;  
    [searchBar sizeToFit];    
    [searchBar setShowsCancelButton:NO animated:YES];    
    [searchBar resignFirstResponder];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar*)theSearchBar{
    searchBar.showsScopeBar = YES;  
    [searchBar sizeToFit];    
    [searchBar setShowsCancelButton:YES animated:YES]; 
}



#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [artistsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // show artists name
    cell.textLabel.text = [artistsArray objectAtIndex: indexPath.row];
    
    // cosmetics
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* artistName = [artistsArray objectAtIndex: indexPath.row];
    
    // transition to SongListViewController
    SongListViewController* songListViewController = [[SongListViewController alloc] initWithNibName:@"SongListViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:songListViewController animated:YES];
    songListViewController.artistViewController = self;
    [songListViewController getSongsByArtist: artistName];
    
    
}


#pragma mark - Request methods

-(void)refresh{
    [self sendArtistsRequest];
}

-(void)sendArtistsRequest{
    
    // update status label
    //[statusLabel setText: @"Getting artists from library"];
    
    
    // gets JSON array of artists
    RKClient* client = [RKClient sharedClient];
    
    // create url /players/player_id/available_music/artists
    NSString* urlString = [client.baseURL absoluteString];
    urlString = [urlString stringByAppendingFormat:@"/players/%@/available_music/artists",[UDJPlayerData sharedPlayerData].currentPlayer.playerID,nil];
    
    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.delegate = self;
    request.queue = client.requestQueue;
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = globalData.headers;
    
    // track current request number
    currentRequestNumber = [NSNumber numberWithInt: [UDJData sharedUDJData].requestCount];
    request.userData = [NSNumber numberWithInt: globalData.requestCount++];
    
    //send request
    [request send]; 
}


#pragma mark - Response handling

-(void)resetToPlayerResultView{
    
    [self.navigationController.navigationController popViewControllerAnimated:YES];
    
    // alert user that player is inactive
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Player Inactive" message: @"The player you are trying to access is now inactive." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

-(void)handleArtistResponse:(RKResponse*)response{
    
    // clear the current artists array
    [artistsArray removeAllObjects];
    
    // create a JSON parser and parse the artist names
    RKJSONParserJSONKit* parser = [RKJSONParserJSONKit new];
    NSArray* responseArray = [parser objectFromString:[response bodyAsString] error:nil];
    for(int i=0; i<[responseArray count]; i++)
        [artistsArray addObject: [responseArray objectAtIndex: i]];
    
    // sort array and reload table data
    [artistsArray sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self.tableView reloadData];
    
    // update status label
    [statusLabel setText: @"Artists"];
    searchIndicatorView.hidden = YES;

}

// Handle responses from the server
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response { 
    
    //NSNumber* requestNumber = request.userData;
    NSDictionary* headerDict = [response allHeaderFields];
    
    NSLog(@"status code %d", [response statusCode]);
    
    //if(![requestNumber isEqualToNumber: currentRequestNumber]) return;
    
    // check if player has ended
    
    if(response.statusCode == 404){
        if([[headerDict objectForKey: @"X-Udj-Missing-Resource"] isEqualToString:@"player"])
            [self resetToPlayerResultView];
    }
    else if ([request isGET] && [response isOK]) {
        [self handleArtistResponse: response];        
    }
    
    // upvote if the song is already on the playlist
    else if(response.statusCode == 409){
        NSString* songID = (NSString*)[request userData];
        [[UDJPlaylist sharedUDJPlaylist] sendVoteRequest:YES songId: songID];
    }
    
    // check if our ticket was invalid
    if(response.statusCode == 401 && [[headerDict objectForKey: @"WWW-Authenticate"] isEqualToString: @"ticket-hash"])
        [globalData renewTicket];
    
    // hide the pulldown refresh
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:0];
    
    //self.currentRequestNumber = [NSNumber numberWithInt: -1];
}

@end
