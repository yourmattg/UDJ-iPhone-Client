//
//  PlaylistViewController.m
//  UDJ
//
//  Created by Matthew Graf on 12/6/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "PlaylistViewController.h"
#import "UDJEventList.h"
#import "UDJEvent.h"
#import "UDJPlaylist.h"
#import "UDJSong.h"
#import "LibrarySearchViewController.h"
#import "PlaylistEntryCell.h"
#import "LibraryEntryCell.h"
#import "EventGoerViewController.h"
#import "FacebookHandler.h"

@implementation PlaylistViewController

@synthesize theEvent, playlist, tableView, currentSongTitleLabel, currentSongArtistLabel, selectedSong;

static PlaylistViewController* _sharedPlaylistViewController;

+(PlaylistViewController*) sharedPlaylistViewController{
    return _sharedPlaylistViewController;
}

-(void)showEventGoers{
    EventGoerViewController* eventGoerViewController = [[EventGoerViewController alloc] initWithNibName:@"EventGoerViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:eventGoerViewController animated:YES];
}

// handle button clicks from alertview (pop up message boxes)
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.title == selectedSong.title){
        /*if(buttonIndex==1) {
            // share
        }*/
        // log out of the current event
        if(buttonIndex==1) [self upVote];
        // go back to the current event
        if(buttonIndex==2) [self downVote];
        // remove song
        //if(buttonIndex==3) [self removeSong];
    }
}

-(void)removeSong{
    NSInteger eventIdParam = [UDJEventList sharedEventList].currentEvent.eventId;
    [[UDJConnection sharedConnection] sendSongRemoveRequest:selectedSong.songId eventId:eventIdParam];
    UIAlertView* notification = [[UIAlertView alloc] initWithTitle:@"Song Removed" message:@"Your song will be removed from the playlist." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [notification show];
}

// leaveEvent: log the client out of the event, return to event list
- (void)leaveEvent{
    NSInteger statusCode = [[UDJConnection sharedConnection] leaveEventRequest];
    if(statusCode==200){
        //[self.toolbarItems release];
        self.navigationController.toolbarHidden=YES;
        [UDJEventList sharedEventList].currentEvent=nil;
        [[UDJPlaylist sharedUDJPlaylist] clearPlaylist];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// loadLibrary: push the library search view
- (void)showLibrary{
    LibrarySearchViewController* librarySearchViewController = [[LibrarySearchViewController alloc] initWithNibName:@"LibrarySearchViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:librarySearchViewController animated:YES];
}

// sendRefreshRequest: ask the playlist for a refresh
-(void)sendRefreshRequest{
    [self.playlist loadPlaylist];
}
// refreshes our list
// NOTE: this is automatically called by UDJConnection when it gets a response
- (void)refreshTableList{
    self.currentSongTitleLabel.text = [UDJPlaylist sharedUDJPlaylist].currentSong.title;
    NSString* artistText = [NSString stringWithFormat:@"by %@",[UDJPlaylist sharedUDJPlaylist].currentSong.artist];
    if([UDJPlaylist sharedUDJPlaylist].currentSong == nil) artistText = @"";
    self.currentSongArtistLabel.text = artistText;
    [self.tableView reloadData];
}

// vote: voting helper function
-(void)vote:(BOOL)up{
    
    UIAlertView* notification;
    if(selectedSong==nil){
        notification = [[UIAlertView alloc] initWithTitle: @"Vote Error" message:@"You haven't selected a song to vote for!" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [notification show];
    }
    else if(selectedSong == playlist.currentSong){
        notification = [[UIAlertView alloc] initWithTitle:@"Vote Error" message:@"You can't vote for a song that's already playing!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [notification show];
    }
    else{
        NSNumber* songIdAsNumber = [NSNumber numberWithInteger:selectedSong.songId];
        // haven't voted for this song yet
        if(![[playlist.voteRecordKeeper objectForKey:songIdAsNumber] boolValue]){
            [playlist.voteRecordKeeper setObject:[NSNumber numberWithBool:YES] forKey:songIdAsNumber];
            
            [[UDJConnection sharedConnection] sendVoteRequest:up songId:selectedSong.songId eventId:theEvent.eventId];
            [self sendRefreshRequest];
            // let the client know it sent a vote
            NSString* msg = @"Your vote for ";
            msg = [msg stringByAppendingString:selectedSong.title];
            msg = [msg stringByAppendingString:@" has been sent!"];
            notification = [[UIAlertView alloc] initWithTitle:@"Vote Sent" message:msg delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        }
        // have already voted for the song
        else{
            NSString* msg = @"You have already voted for ";
            msg = [msg stringByAppendingString:selectedSong.title];
            msg = [msg stringByAppendingString:@"!"];
            notification = [[UIAlertView alloc] initWithTitle:@"Vote Denied" message:msg delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        }
        [notification show];
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
                                   @"I'm playing this song on UDJ. Come join the party!", @"description",
                                   @"http://github.com/simon911011/UDJ/", @"link",
                                   @"http://1.bp.blogspot.com/-RRRpZE314eQ/TkycUFS24II/AAAAAAAAPrM/z1b0peDvG6Q/s320/troll+face.jpg", @"picture",
                                   actionLinksStr, @"actions",
                                   nil];
    [[FacebookHandler sharedHandler] postWithParam:params];
    NSLog(@"post called");
}
/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        //custom initialization
    }
    return self;
}*/

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sharedPlaylistViewController = self;
    
    // set event, navigation bar title
    self.theEvent = [UDJEventList sharedEventList].currentEvent;
	self.navigationItem.title = theEvent.name;
    
    // init playlist
    [[UDJConnection sharedConnection] setPlaylistView:self];
    self.playlist = [UDJPlaylist sharedUDJPlaylist];
    self.playlist.eventId = theEvent.eventId;
    [playlist loadPlaylist];
    //[self refreshTableList]; moved to viewDidAppear
    
    // set up leave and library buttons
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Leave" style:UIBarButtonItemStylePlain target:self action:@selector(leaveEvent)]];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Library" style:UIBarButtonItemStylePlain target:self action:@selector(showLibrary)]];
    
    // set up toolbar
    UIBarButtonItem* refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(sendRefreshRequest)];
    UIBarButtonItem* space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    //UIBarButtonItem* eventGoerButton = [[UIBarButtonItem alloc] initWithTitle:@"People" style:UIBarButtonItemStylePlain target:self action:@selector(showEventGoers)];
    NSArray* toolbarItems = [NSArray arrayWithObjects: space, refreshButton, space, nil];
    self.toolbarItems = toolbarItems;
    self.navigationController.toolbarHidden=NO;
    
    //[eventGoerButton release];
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
        song.title = @"nothing";
        song.artist = @"nobody";
        song.adderName = @"nobody";
    }
    
    NSString* songText = @"";
    if(song!=nil) songText = [songText stringByAppendingString: song.title];
	cell.songLabel.text = songText;
    cell.artistLabel.text = [NSString stringWithFormat: @"%@%@", @"By ", song.artist, nil];
    
    NSString* adderName;
    UDJConnection* connection = [UDJConnection sharedConnection];
    NSInteger userId = [connection.userID intValue];
    if(song.adderId == userId) adderName = @"You";
    else adderName = song.adderName;
    cell.addedByLabel.text = [NSString stringWithFormat:@"%@%@", @"Added by ", adderName];
    
    cell.upVoteLabel.text = [NSString stringWithFormat:@"%d", song.upVotes];
    cell.downVoteLabel.text = [NSString stringWithFormat:@"%d", song.downVotes];
    
    cell.downVoteButton.tag = rowNumber;
    cell.upVoteButton.tag = rowNumber;
    
    BOOL extrasHidden = (song != selectedSong);
    cell.addedByLabel.hidden=extrasHidden;
    cell.upVoteLabel.hidden=extrasHidden;
    cell.downVoteLabel.hidden=extrasHidden;
    cell.upVoteButton.hidden = extrasHidden;
    cell.downVoteButton.hidden = extrasHidden;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if([playlist songAtIndex:row]==selectedSong) return 64;
    return 48.0;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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


@end
