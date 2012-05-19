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

#import "PlaylistViewController.h"
#import "UDJEventData.h"
#import "UDJEvent.h"
#import "UDJPlaylist.h"
#import "UDJSong.h"
#import "LibrarySearchViewController.h"
#import "PlaylistEntryCell.h"
#import "LibraryEntryCell.h"
#import "EventGoerViewController.h"
#import "PlaylistEntryCell.h"
#import <QuartzCore/QuartzCore.h>
#import "FacebookHandler.h"


@implementation PlaylistViewController

@synthesize currentEvent, playlist, tableView, currentSongTitleLabel, currentSongArtistLabel, selectedSong, statusLabel, currentRequestNumber, globalData, leavingBackgroundView, leavingView, leaveButton, libraryButton, eventNameLabel, refreshButton, refreshIndicator, refreshLabel, voteNotificationView, voteNotificationLabel, voteNotificationArrowView;
@synthesize playerNameLabel;

static PlaylistViewController* _sharedPlaylistViewController;



#pragma mark - udj button methods

// handleLeaveEvent: go back to the event results page
-(void)handleLeaveEvent{
    // user is no longer in an event, reset currentEvent
    [UDJEventData sharedEventData].currentEvent=nil;
    
    // we have no need for this party's playlist
    [[UDJPlaylist sharedUDJPlaylist] clearPlaylist];
    
    // show the event results page
    [self.navigationController popViewControllerAnimated:YES]; 
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if([alertView.title isEqualToString: currentEvent.name]){
        
        // option: leave the player
        if(buttonIndex == 1){
            [self handleLeaveEvent];
        }
    }
}

-(IBAction)backButtonClick:(id)sender{
    [self handleLeaveEvent];
}

-(void)resetToPlayerResultView{
    // return to player search results screen
    [self.navigationController popViewControllerAnimated: YES];
    
    // alert user that player is inactive
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Player Inactive" message: @"The player you are trying to access is now inactive." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

+(PlaylistViewController*) sharedPlaylistViewController{
    return _sharedPlaylistViewController;
}



-(void)removeSong{
    NSInteger eventIdParam = [UDJEventData sharedEventData].currentEvent.eventId;
    [[UDJConnection sharedConnection] sendSongRemoveRequest:selectedSong.librarySongId eventId:eventIdParam];
    UIAlertView* notification = [[UIAlertView alloc] initWithTitle:@"Song Removed" message:@"Your song will be removed from the playlist." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [notification show];
}

// loadLibrary: push the library search view
- (IBAction)showLibrary:(id)sender{
    LibrarySearchViewController* librarySearchViewController = [[LibrarySearchViewController alloc] initWithNibName:@"LibrarySearchViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:librarySearchViewController animated:YES];
}



#pragma mark - Refresh methods

-(void)toggleRefreshingStatus:(BOOL)active{
    self.refreshButton.hidden = active;
    self.refreshIndicator.hidden = !active;
    self.refreshLabel.hidden = !active;
}

// sendRefreshRequest: ask the playlist for a refresh
-(void)sendRefreshRequest{
    [self toggleRefreshingStatus: YES];
    self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
    [self.playlist sendPlaylistRequest];
}

-(IBAction)refreshButtonClick:(id)sender{
    [self sendRefreshRequest];
}


// refreshes our list
// NOTE: this is automatically called by UDJConnection when it gets a response
- (void)refreshTableList{
    self.currentSongTitleLabel.text = [UDJPlaylist sharedUDJPlaylist].currentSong.title;
    NSString* artistText = [NSString stringWithFormat:@"by %@",[UDJPlaylist sharedUDJPlaylist].currentSong.artist];
    if([UDJPlaylist sharedUDJPlaylist].currentSong == nil) artistText = @"";
    self.currentSongArtistLabel.text = artistText;
    
    // if the playlist is empty, let them know, and hide the tableview
    if([[UDJPlaylist sharedUDJPlaylist].playlist count] == 0){
        self.tableView.hidden = YES;
        self.statusLabel.text = @"There are no songs queued up to play next.\nGo find some songs to add to the playlist!";
    }
    else{
        self.tableView.hidden = NO;
        self.statusLabel.text = @"";
    }
    
    [self.tableView reloadData];
}


#pragma mark Voting methods

-(void)hideVoteNotification:(id)arg{
    [NSThread sleepForTimeInterval:2];
    [UIView animateWithDuration:1.0 animations:^{
        voteNotificationView.alpha = 0;
    }];
}

// briefly show the vote notification view
-(void)showVoteNotification:(BOOL)up{
    voteNotificationLabel.text = selectedSong.title;
    if(up) voteNotificationArrowView.image = [UIImage imageNamed:@"smalluparrow"];
    else voteNotificationArrowView.image = [UIImage imageNamed:@"smalldownarrow"];
    
    [self.view addSubview: voteNotificationView];
    voteNotificationView.alpha = 0;
    voteNotificationView.frame = CGRectMake(20, 370, 280, 32);
    [UIView animateWithDuration:0.5 animations:^{
        voteNotificationView.alpha = 1;
    } completion:^(BOOL finished){
        if(finished){
            [NSThread detachNewThreadSelector:@selector(hideVoteNotification:) toTarget:self withObject:nil];
        }
    }];
}

// vote: voting helper function
-(void)vote:(BOOL)up{
    
    UIAlertView* notification;
    
    // If user hasn't selected a song, let them know
    if(selectedSong==nil){
        notification = [[UIAlertView alloc] initWithTitle: @"Vote Error" message:@"You haven't selected a song to vote for!" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [notification show];
    }
    
    // User can't vote for a song that's already playing
    else if(selectedSong == playlist.currentSong){
        notification = [[UIAlertView alloc] initWithTitle:@"Vote Error" message:@"You can't vote for a song that's already playing!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [notification show];
    }
    
    // If everything is OK, send the vote
    else{
        NSNumber* songIdAsNumber = [NSNumber numberWithInteger:selectedSong.librarySongId];
        
        [playlist.voteRecordKeeper setObject:[NSNumber numberWithBool:YES] forKey:songIdAsNumber];
        
        // send the vote request
        self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
        [playlist sendVoteRequest:up songId:selectedSong.librarySongId];
        
        // let the client know it sent a vote
        /*NSString* msg = @"Your vote for ";
        msg = [msg stringByAppendingString:selectedSong.title];
        msg = [msg stringByAppendingString:@" has been sent!"];
        notification = [[UIAlertView alloc] initWithTitle:@"Vote Sent" message:msg delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];*/
        [self showVoteNotification:up];
    }
}

// upVote: have UDJConnection send an upvote request
- (void)upVote{
    [self vote:YES];
}

// downVote: have UDJConnection send a downvote request
- (void)downVote{
    [self vote:NO];
}



#pragma mark Facebook sharing

// Login to Facebook
- (void)login {
    [[FacebookHandler sharedHandler] login];
    NSLog(@"login called");
}

// Post to Facebook
- (void)post {
    SBJSON *jsonWriter = [SBJSON new];
    
    
    // The action links to be shown with the post in the feed
    NSArray* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                      @"Test...",@"name",@"http://github.com/simon911011/UDJ/",@"link", nil], nil];
    NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
    // Dialog parameters
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"UDJ", @"name",
                                   selectedSong.title, @"caption",
                                   @"We're listening to this song with UDJ. Come join the party!", @"description",
                                   @"http://github.com/simon911011/UDJ/", @"link",
                                   @"http://1.bp.blogspot.com/-RRRpZE314eQ/TkycUFS24II/AAAAAAAAPrM/z1b0peDvG6Q/s320/troll+face.jpg", @"picture",
                                   actionLinksStr, @"actions",
                                   nil];
    [[FacebookHandler sharedHandler] postWithParam:params];
    NSLog(@"post called");
}


// Show or hide the "Leaving event" view; active = YES will show the view
-(void) toggleLeavingView:(BOOL) active{
    leavingBackgroundView.hidden = !active;
    leavingView.hidden = !active;
    
    // TODO: disable toolbar?
}

#pragma mark - View lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.globalData = [UDJData sharedUDJData];
    
    _sharedPlaylistViewController = self;
    
    // set event, event label text
    self.currentEvent = [UDJEventData sharedEventData].currentEvent;
	self.eventNameLabel.text = currentEvent.name;
    
    // set delegate
    [UDJEventData sharedEventData].leaveEventDelegate = self;
    
    
    // initialize leaving view
    leavingView.layer.cornerRadius = 8;
    leavingView.layer.borderColor = [[UIColor whiteColor] CGColor];
    leavingView.layer.borderWidth = 3;
    
    [self toggleLeavingView: NO];
    [self toggleRefreshingStatus: NO];
    
    // init playlist
    self.playlist = [UDJPlaylist sharedUDJPlaylist];
    self.playlist.eventId = currentEvent.eventId;
    self.playlist.delegate = self;
    
    self.refreshIndicator.hidden = NO;
    self.refreshButton.hidden = YES;
    
    // set up tab bar stuff
    self.title = NSLocalizedString(@"Playlist", @"Playlist");
    
    [playerNameLabel setText: currentEvent.name];
    
    
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
    [self sendRefreshRequest];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [playlist count];
}

// this is used for setting up each cell in the table
- (UITableViewCell *)tableView:(UITableView *)TableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    PlaylistEntryCell* cell = [TableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PlaylistEntryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	
    // combine song number and name into one string
    UDJSong* song;
    NSInteger rowNumber = indexPath.row;
	song = [playlist songAtIndex:rowNumber];
    
    // if there's no current song, show "nothing" and "nobody" as title/artist
    if(song==nil){
        song = [[UDJSong alloc] init];
        song.title = @"";
        song.artist = @"";
        song.adder = nil;
    }
    
    NSString* songText = @"";
    if(song!=nil) songText = [songText stringByAppendingString: song.title];
	cell.songLabel.text = songText;
    cell.artistLabel.text = song.artist;
    
    // figure out who added the song: either "You" or another user
    NSString* adderName;
    NSInteger userId = [globalData.userID intValue];
    
    if(song.adder == nil) adderName = @"";
    else if(song.adder.userID == userId) adderName = @"You";
    else adderName = song.adder.username;
    cell.addedByLabel.text = [NSString stringWithFormat:@"%@%@", @"Added by ", adderName];
    
    cell.upVoteLabel.text = [NSString stringWithFormat:@"%d", [song.upVoters count]];
    cell.downVoteLabel.text = [NSString stringWithFormat:@"%d", [song.downVoters count]];
    
    cell.downVoteButton.tag = rowNumber;
    cell.upVoteButton.tag = rowNumber;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowNumber = indexPath.row;
    selectedSong = [playlist songAtIndex:rowNumber];
    /*
    UIAlertView* songOptionBox = [[UIAlertView alloc] initWithTitle: selectedSong.title message: selectedSong.artist delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    // include vote buttons if its not the song playing
    //[songOptionBox addButtonWithTitle:@"Share"];
    [songOptionBox addButtonWithTitle:@"Vote Up"];
    [songOptionBox addButtonWithTitle:@"Vote Down"];
    // include remove button if this user added the song
    //UDJConnection* connection = [UDJConnection sharedConnection];
    //if([connection.userID intValue]== selectedSong.adderId) [songOptionBox addButtonWithTitle:@"Remove Song"];
    [songOptionBox show];
    [songOptionBox release];*/
    
    [self.tableView reloadData];
    [self.tableView cellForRowAtIndexPath:indexPath].selected = YES;
    PlaylistEntryCell* cell = (PlaylistEntryCell*) [self.tableView cellForRowAtIndexPath:indexPath];
    cell.downVoteButton.highlighted = NO;
    cell.upVoteButton.highlighted = NO;
}


#pragma mark - Response handling

// handlePlaylistResponse: this is done asynchronously from the send method so the client can do other things meanwhile
// NOTE: this calls [playlistView refreshTableList] for you!
- (void)handlePlaylistResponse:(RKResponse*)response{
    
    NSMutableArray* tempList = [NSMutableArray new];
    
    RKJSONParserJSONKit* parser = [RKJSONParserJSONKit new];
    // response dict: holds current song and array of songs
    NSDictionary* responseDict = [parser objectFromString:[response bodyAsString] error:nil];
    UDJSong* currentSong = [UDJSong songFromDictionary:[responseDict objectForKey:@"current_song"] isLibraryEntry:NO];
    
    // the array holding the songs on the playlist
    NSArray* songArray = [responseDict objectForKey:@"active_playlist"];
    NSLog(@"count %d", [songArray count]);
    for(int i=0; i<[songArray count]; i++){
        NSDictionary* songDict = [songArray objectAtIndex:i];
        UDJSong* song = [UDJSong songFromDictionary:songDict isLibraryEntry:NO];
        [tempList addObject:song];
        //NSLog(song.title);
        
        NSNumber* songIdAsNumber = [NSNumber numberWithInteger:song.librarySongId];
        // if this song hasnt been added to the playlist before i.e. isnt in the voteRecordKeeper
        if([[UDJPlaylist sharedUDJPlaylist].voteRecordKeeper objectForKey:songIdAsNumber]==nil){
            // set its songId to NO, meaning the user hasn't voted for it yet
            NSNumber* no =[NSNumber numberWithBool:NO];
            [[UDJPlaylist sharedUDJPlaylist].voteRecordKeeper setObject:no forKey:songIdAsNumber];
        }
    }
    
    [[UDJPlaylist sharedUDJPlaylist] setPlaylist: tempList];
    [[UDJPlaylist sharedUDJPlaylist] setCurrentSong: currentSong];
    
    [self refreshTableList];
    
    // bring back the refresh button
    [self toggleRefreshingStatus: NO];
    
}


// Handle responses from the server
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response { 
    
    NSLog(@"Playlist: status code %d", [response statusCode]);
    
    NSNumber* requestNumber = request.userData;
    NSDictionary* headerDict = [response allHeaderFields];
    
    NSLog(@"response %d, waiting on %d", [requestNumber intValue], [currentRequestNumber intValue]);

    if(![requestNumber isEqualToNumber: currentRequestNumber]) return;
    
    //NSLog([NSString stringWithFormat:@"code %d", response.statusCode]);
    
    // check if player is inactive
    if(response.statusCode == 404){
        if([[headerDict objectForKey: @"X-Udj-Missing-Resource"] isEqualToString:@"player"])
            [self resetToPlayerResultView];
    }
    else if ([request isGET]) {
        [self handlePlaylistResponse:response];        
    }
    else if([request isDELETE]){
        if([response isOK]) [self handleLeaveEvent];
    }
    else if([request isPUT]){
        if([response isOK]) [self sendRefreshRequest];
    }
    else if([request isPOST]){
        if([response isOK]) [self sendRefreshRequest];
    }
    
    //self.currentRequestNumber = [NSNumber numberWithInt: -1];
}


@end
