//
//  PlaylistViewController.m
//  UDJ
//
//  Created by Matthew Graf on 12/6/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "PlaylistViewController.h"
#import "EventList.h"
#import "UDJEvent.h"
#import "UDJPlaylist.h"
#import "UDJSong.h"
#import "LibrarySearchViewController.h"

@implementation PlaylistViewController

@synthesize theEvent, playlist;

// leaveEvent: log the client out of the event, return to event list
- (void)leaveEvent{
    NSInteger statusCode = [[UDJConnection sharedConnection] leaveEventRequest];
    if(statusCode==200){
        //[self.toolbarItems release];
        self.navigationController.toolbarHidden=YES;
        [EventList sharedEventList].currentEvent=nil;
        [[UDJPlaylist sharedUDJPlaylist] clearPlaylist];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// loadLibrary: push the library search view
- (void)showLibrary{
    LibrarySearchViewController* librarySearchViewController = [[LibrarySearchViewController alloc] initWithNibName:@"LibrarySearchViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:librarySearchViewController animated:YES];
    [librarySearchViewController release];
}

// sendRefreshRequest: ask the playlist for a refresh
-(void)sendRefreshRequest{
    [self.playlist loadPlaylist];
}
// refreshes our list
// NOTE: this is automatically called by UDJConnection when it gets a response
- (void)refreshTableList{
    [self.tableView reloadData];
}

// vote: voting helper function
-(void)vote:(BOOL)up{
    
    UIAlertView* notification = [UIAlertView alloc];
    if(selectedSong==nil){
        [notification initWithTitle:@"Vote Error" message:@"You haven't selected a song to vote for!" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [notification show];
        [notification release];
    }
    else{
        NSNumber* songIdAsNumber = [NSNumber numberWithInteger:selectedSong.songId];
        // haven't voted for this song yet
        if(![[playlist.voteRecordKeeper objectForKey:songIdAsNumber] boolValue]){
            [playlist.voteRecordKeeper setObject:[NSNumber numberWithBool:YES] forKey:songIdAsNumber];
            
            [[UDJConnection sharedConnection] sendVoteRequest:up songId:selectedSong.songId eventId:theEvent.eventId];
            // let the client know it sent a vote
            NSString* msg = @"Your vote for ";
            msg = [msg stringByAppendingString:selectedSong.title];
            msg = [msg stringByAppendingString:@" has been sent!"];
            [notification initWithTitle:@"Vote Sent" message:msg delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        }
        // have already voted for the song
        else{
            NSString* msg = @"You have already voted for ";
            msg = [msg stringByAppendingString:selectedSong.title];
            msg = [msg stringByAppendingString:@"!"];
            [notification initWithTitle:@"Vote Denied" message:msg delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        }
        [notification show];
        [notification release];
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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set event, navigation bar title
    self.theEvent = [EventList sharedEventList].currentEvent;
	self.navigationItem.title = theEvent.name;
    
    // init playlist
    [[UDJConnection sharedConnection] setPlaylistView:self];
    self.playlist = [UDJPlaylist sharedUDJPlaylist];
    self.playlist.eventId = theEvent.eventId;
    [playlist loadPlaylist];
    [self refreshTableList];
    
    // set up leave and library buttons
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Leave" style:UIBarButtonItemStylePlain target:self action:@selector(leaveEvent)]];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Library" style:UIBarButtonItemStylePlain target:self action:@selector(showLibrary)]];
    
    // set up toolbar
    self.navigationController.toolbar.tintColor = [UIColor blackColor];
    UIBarButtonItem* downVoteButton = [[UIBarButtonItem alloc] initWithTitle:@"Up" style:UIBarButtonItemStylePlain 
                                                                                    target:self action:@selector(upVote)];
    UIBarButtonItem* upVoteButton = [[UIBarButtonItem alloc] initWithTitle:@"Down" style:UIBarButtonItemStylePlain 
                                                                                  target:self action:@selector(downVote)];
    UIBarButtonItem* refreshButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain 
                                                                    target:self action:@selector(sendRefreshRequest)];
    UIBarButtonItem* space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray* toolbarItems = [NSArray arrayWithObjects: upVoteButton, space, refreshButton, space, downVoteButton, nil];
    self.toolbarItems = toolbarItems;
    self.navigationController.toolbarHidden=NO;
    
    [downVoteButton release];
    [upVoteButton release];
    [refreshButton release];
    [space release];
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
    // combine song number and name into one string
    NSInteger rowNumber = indexPath.row;
    NSString* songName;
	if(rowNumber==0) {
        if([UDJPlaylist sharedUDJPlaylist].currentSong==nil) {
            songName=@"";
        }
        else songName = [UDJPlaylist sharedUDJPlaylist].currentSong.title;
    }
    else songName = [[[NSString alloc] initWithString:[playlist songAtIndex:rowNumber-1].title] autorelease];
    NSString* cellValue = [NSString new];
    if(rowNumber==0){
        cellValue = @"Playing: ";
    }
    else{
        cellValue = [NSString stringWithFormat:@"%d", rowNumber];
        cellValue = [cellValue stringByAppendingString:@". "];
    }
    cellValue = [cellValue stringByAppendingString:songName];
	cell.textLabel.text = cellValue;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
	cell.textLabel.textColor=[UIColor whiteColor];
    
    // Configure the cell...
    
    return cell;
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
    if(rowNumber==0) selectedSong = [playlist currentSong];
    else selectedSong = [playlist songAtIndex:rowNumber-1];
}

- (void)dealloc{
    [theEvent release];
    [playlist release];
    [super dealloc];
}

@end
