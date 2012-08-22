//
//  UDJPlayerManager.m
//  UDJ
//
//  Created by Matthew Graf on 7/28/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJPlayerManager.h"
#import "UDJStoredPlayer.h"
#import "UDJAppDelegate.h"
#import "UDJStoredLibraryEntry.h"
#import "JSONKit.h"
#import "UDJPlayer.h"
#import "UDJPlayerData.h"
#import "UDJPlaylist.h"
#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMTime.h>

typedef unsigned long long UDJLibraryID;

@implementation UDJPlayerManager

@synthesize playerName, playerPassword;
@synthesize address, stateLocation, city, zipCode;
@synthesize playerID;
@synthesize managedObjectContext, globalData, songSyncDictionary;
@synthesize isInPlayerMode, playerState;
@synthesize currentMediaItem, audioPlayer;
@synthesize songLength, songPosition;
@synthesize UIDelegate;
@synthesize playlistTimer, nextSongAdded;
@synthesize playlist;


#pragma mark - Singleton methods
static UDJPlayerManager* _sharedPlayerManager = nil;

+(UDJPlayerManager*)sharedPlayerManager{
    @synchronized([UDJPlayerManager class]){
        if (!_sharedPlayerManager)
            _sharedPlayerManager = [[self alloc] init];        
        return _sharedPlayerManager;
    }    
    return nil;
}

+(id)alloc{
    @synchronized([UDJPlayerManager class]){
        NSAssert(_sharedPlayerManager == nil, @"Attempted to allocate a second instance of a singleton.");
        _sharedPlayerManager = [super alloc];
        return _sharedPlayerManager;
    }
    return nil;
}

-(id)init{
    if(self = [super init]){
        self.playerID = -1;
        self.isInPlayerMode = NO;
        
        UDJAppDelegate* appDelegate = (UDJAppDelegate*)[[UIApplication sharedApplication] delegate];
        managedObjectContext = appDelegate.managedObjectContext;
        
        self.globalData = [UDJData sharedUDJData];
        
        [self loadPlayerInfo];
        
        self.audioPlayer = [[AVQueuePlayer alloc] init];
        [audioPlayer setActionAtItemEnd: AVPlayerActionAtItemEndAdvance];
        
        self.playlist = [UDJPlaylist sharedUDJPlaylist];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd) name:AVPlayerItemDidPlayToEndTimeNotification object: nil];
        
        
    }
    return self;
}

#pragma mark - Saving player to persistent store

-(void)savePlayerInfo{
    
    UDJStoredPlayer* storedPlayer;
    NSError* error;
    
    //Set up a request to get the last stored playlist
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UDJStoredPlayer" inManagedObjectContext:managedObjectContext]];
    storedPlayer = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    
    if (error) {
        // error in getting info
    }
    
    // if there was no stored player before, create it
    if (!storedPlayer) {
        storedPlayer = (UDJStoredPlayer*)[NSEntityDescription insertNewObjectForEntityForName:@"UDJStoredPlayer" inManagedObjectContext: managedObjectContext]; ;
    }
    
    // update the username, save the date the ticket was assigned
    [storedPlayer setName: self.playerName];
    [storedPlayer setAddress: self.address];
    [storedPlayer setCity: self.city];
    [storedPlayer setState: self.stateLocation];
    [storedPlayer setPassword: self.playerPassword];
    [storedPlayer setZipcode: self.zipCode];
    [storedPlayer setPlayerID: [NSNumber numberWithInt: self.playerID]];
    
    //Save the data
    error = nil;
    if (![managedObjectContext save:&error]) {
        //Handle any error with the saving of the context
    }
    
}

-(void)loadPlayerInfo{
    
    UDJStoredPlayer* storedPlayer;
    NSError* error;
    
    //Set up a request to get the last stored player
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UDJStoredPlayer" inManagedObjectContext:managedObjectContext]];
    storedPlayer = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    
    if (error) {
        // error in getting info
    }
    
    // if there was a stored player, fill in the fields
    if (storedPlayer) {
        self.playerName = storedPlayer.name;
        self.playerPassword = storedPlayer.password;
        self.address = storedPlayer.address;
        self.city = storedPlayer.city;
        self.stateLocation = storedPlayer.state;
        self.zipCode = storedPlayer.zipcode;
        self.playerID = [storedPlayer.playerID intValue];
    }
}


#pragma mark - Updating library

-(NSArray*)arrayWithAllLibraryEntries{
    NSError* error;
    //Set up a request to get the all library entries
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UDJStoredLibraryEntry" inManagedObjectContext:managedObjectContext]];
    NSArray* libraryEntryArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSLog(@"Loaded %d library entries from store", [libraryEntryArray count]);
    
    if(error) {}
    return libraryEntryArray;
}

-(void)buildSyncDictionary{
    // build sync status dictionary
    NSArray* libraryEntryArray = [self arrayWithAllLibraryEntries];
    NSInteger dictionarySize = [libraryEntryArray count] == 0 ? 200 : [libraryEntryArray count];
    self.songSyncDictionary = [NSMutableDictionary dictionaryWithCapacity: dictionarySize];
    for(int i=0; i<[libraryEntryArray count]; i++){
        UDJStoredLibraryEntry* libEntry = [libraryEntryArray objectAtIndex: i];
        //NSLog(@"%llu", [libEntry.libraryID unsignedLongLongValue]);
        [self.songSyncDictionary setObject: libEntry.synced forKey: [NSNumber numberWithUnsignedLongLong: [libEntry.libraryID unsignedLongLongValue]]];
    }
}

-(NSMutableDictionary*)dictionaryForMediaItem:(MPMediaItem*)item{
    NSMutableDictionary* songDict = [NSMutableDictionary dictionaryWithCapacity: 7];
    NSString *title, *artist, *album, *genre;
    NSNumber *track, *duration;
    [songDict setObject: [item valueForProperty: MPMediaItemPropertyPersistentID] forKey:@"id"];
    
    if([item valueForProperty: MPMediaItemPropertyTitle]) title = [item valueForProperty: MPMediaItemPropertyTitle];
    else title = @"Untitled";
    [songDict setObject: title forKey:@"title"];
    
    if([item valueForProperty: MPMediaItemPropertyArtist]) artist = [item valueForProperty: MPMediaItemPropertyArtist];
    else artist = @"Unknown Artist";
    [songDict setObject: artist forKey:@"artist"];
    
    if([item valueForProperty: MPMediaItemPropertyAlbumTitle]) album = [item valueForProperty: MPMediaItemPropertyAlbumTitle];
    else album = @"Unknown Album";
    [songDict setObject: album forKey:@"album"];
    
    if([item valueForProperty: MPMediaItemPropertyGenre]) genre = [item valueForProperty: MPMediaItemPropertyGenre];
    else genre = @"Unknown Genre";
    [songDict setObject: genre forKey:@"genre"];
    
    if([item valueForProperty: MPMediaItemPropertyAlbumTrackNumber]) track = [item valueForProperty: MPMediaItemPropertyAlbumTrackNumber];
    else track = [NSNumber numberWithInt: 0];
    [songDict setObject: track forKey:@"track"];
    
    if([item valueForProperty: MPMediaItemPropertyPlaybackDuration]) duration = [item valueForProperty: MPMediaItemPropertyPlaybackDuration];
    else duration = [NSNumber numberWithInt: 0];
    [songDict setObject: duration forKey:@"duration"];
    
    return songDict;
}

-(void)deletePreviousLibraryEntries{
    // Fetch and delete all previous entries
    NSError* error;
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UDJStoredLibraryEntry" inManagedObjectContext:managedObjectContext]];
    NSArray* storedEntryArray = [managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"Deleting %d stored library entires", [storedEntryArray count]);
    for(int i=0; i <[storedEntryArray count]; i++){
        UDJStoredLibraryEntry* entry = [storedEntryArray objectAtIndex: i];
        [managedObjectContext deleteObject: entry];
    }
    [managedObjectContext save: &error];
    if(error) NSLog(@"error");
}

-(void)saveLibraryEntries{  
    [self deletePreviousLibraryEntries];
    
    NSLog(@"about to save %d library entries (from songSyncDictionary)", [songSyncDictionary count]);
    NSArray* keyArray = [self.songSyncDictionary allKeys];
    for(int i=0; i<[keyArray count]; i++){
        NSNumber* entryID = [keyArray objectAtIndex: i];
        UDJStoredLibraryEntry* entry = (UDJStoredLibraryEntry*)[NSEntityDescription insertNewObjectForEntityForName:@"UDJStoredLibraryEntry" inManagedObjectContext:managedObjectContext];  
        // TODO: need to fix persistent store type
        NSNumber* number = [[NSNumber alloc] initWithUnsignedLongLong: [entryID unsignedLongLongValue]];
        [entry setSynced: [self.songSyncDictionary objectForKey: number]];
        //[entry setSynced: [self.songSyncDictionary objectForKey: entryID]];
        [entry setLibraryID: number];
    }
    
    NSError* error;
    [managedObjectContext save: &error];
}

-(void)updatePlayerMusicHelper{
    [self buildSyncDictionary];
    
    // get all songs from library
    MPMediaQuery* songQuery = [MPMediaQuery songsQuery];
    NSArray* songArray = [songQuery items];
    
    // song accumulator, used to send sets of 200 songs to server
    NSMutableArray* songAddArray = [NSMutableArray arrayWithCapacity: 201];
    
    // check each song in the library
    for(int i=0; i<[songArray count]; i++){
        MPMediaItem* mediaItem = [songArray objectAtIndex: i];
        
        // get this song's sync status
        NSNumber* libraryID = [mediaItem valueForProperty: MPMediaItemPropertyPersistentID];
        NSNumber* number = [NSNumber numberWithUnsignedLongLong: [libraryID unsignedLongLongValue]];
        NSNumber* syncStatus = [songSyncDictionary objectForKey: number]; //objectForKey: libraryID
        
        // if this song hasn't been synced, add it to a set of songs to be added
        if(syncStatus == nil || [syncStatus boolValue] == NO){
            NSDictionary* songAddDict = [self dictionaryForMediaItem: mediaItem];
            [songAddArray addObject: songAddDict];
            
            //if(syncStatus == nil) NSLog(@"new ID: %llu", [libraryID unsignedLongLongValue]);
            
            // mark the song as synced initially (we'll mark it as unsynced in the case of a 409)
            [songSyncDictionary setObject: [NSNumber numberWithBool: YES] forKey:number];
            
            // if we have 200 songs, send them off to the server
            // TODO: change 50 to 200
            if([songAddArray count] == 200 || i == [songArray count]-1){
                NSLog(@"Sending %d songs to server", [songAddArray count]);
                RKResponse* response = [self addSongsToServer: [songAddArray JSONString]];
                
                // if there were conflicts, mark those songs as unsynced
                if([response statusCode] == 409){
                    NSArray* songConflictArray = [[response bodyAsString] objectFromJSONString];
                    NSLog(@"%d conflicts", [songConflictArray count]);
                    for(int i=0; i<[songConflictArray count]; i++){
                        // set synced to YES since that means we already have it
                        NSNumber* conflictNumber = [songConflictArray objectAtIndex: i];
                        [songSyncDictionary setObject: [NSNumber numberWithBool: YES] forKey: [NSNumber numberWithUnsignedLongLong: [conflictNumber unsignedLongLongValue]]];
                    }
                }
                else if([response statusCode] == 201) NSLog(@"%d songs added", [songAddArray count]);
                [songAddArray removeAllObjects];
            }
        }
    }
    
    // TODO: figure out which songs have been deleted
    
    [self saveLibraryEntries]; 
    NSLog(@"done updating library");
}

-(void)updatePlayerMusic{
    [NSThread detachNewThreadSelector:@selector(updatePlayerMusicHelper) toTarget:self withObject:nil];
}

-(RKResponse*)addSongsToServer:(NSString*)songCollectionString{
    
    RKClient* client = [RKClient sharedClient];
    
    //create url users/user_id/players/player_id/library/songs
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingFormat: @"/0_6/players/%d/library/songs", self.playerID, nil];
    
    //set up request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate: self.globalData];
    request.method = RKRequestMethodPUT;
    request.queue = client.requestQueue;
    request.userData = @"songSetAdd";
    
    // set up the headers, including which type of request this is
    NSMutableDictionary* requestHeaders = [NSMutableDictionary dictionaryWithDictionary: [UDJData sharedUDJData].headers];
    [requestHeaders setValue:@"playerMethodsDelegate" forKey:@"delegate"];
    [requestHeaders setValue:@"text/json" forKey:@"content-type"];
    request.additionalHTTPHeaders = requestHeaders;
    
    // set body to the JSON song array
    [request setHTTPBody: [songCollectionString dataUsingEncoding: NSUTF8StringEncoding]];
    
    return [request sendSynchronously];
}

#pragma mark - Player state methods

-(void)updateCurrentPlayer{
    UDJPlayer* player = [[UDJPlayer alloc] init];
    player.playerID = self.playerID;
    player.name = self.playerName;
    player.hostId = [globalData.userID intValue];
    player.hostUsername = globalData.username;
    [UDJPlayerData sharedPlayerData].currentPlayer = player;
}

-(void)changePlayerState:(PlayerState)newState{
    [self setPlayerState: newState];
    [self sendPlayerStateRequest: newState];
}

-(void)sendPlayerStateRequest:(PlayerState)newState{
    RKClient* client = [RKClient sharedClient];
    
    //create url [POST] {prefix}/udj/0_6/players/player_id/state
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingFormat:@"%@%d%@", @"/0_6/players/", self.playerID, @"/state", nil];
    
    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate: self.globalData];
    request.queue = client.requestQueue;
    request.method = RKRequestMethodPOST;
    request.userData = [NSString stringWithString: @"changeState"];
    
    // set up the headers, including which type of request this is
    NSMutableDictionary* requestHeaders = [NSMutableDictionary dictionaryWithDictionary: globalData.headers];
    [requestHeaders setValue:@"playerMethodsDelegate" forKey:@"delegate"];
    request.additionalHTTPHeaders = requestHeaders;
    
    // include state parameter
    NSArray* stateArray = [NSArray arrayWithObjects:@"inactive", @"playing", @"paused", nil];
    request.params = [NSDictionary dictionaryWithObjectsAndKeys: [stateArray objectAtIndex: newState], @"state", nil];
    
    //send request
    [request send];
}

#pragma mark - Preparing for background

-(void)enterBackgroundMode{
    [self setIsInBackground: YES];
}

-(void)exitBackgroundMode{
    [self setIsInBackground: NO];
}

#pragma mark - Transition to next song

-(void)playerItemDidReachEnd{
    NSLog(@"song ended");
    [self playNextSong];
}

-(void)playNextSong{
    
    // THIS ASSUMES THE PLAYER IS RELATIVELY UP TO DATE
    // (and it will be since the timer updates the playlist every 7 seconds)
    UDJSong* nextSong = [[UDJPlaylist sharedUDJPlaylist] songAtIndex: 0];
    
    if(nextSong){
        NSLog(@"sending request to change song");
        // go ahead and change the UDJPlaylist next song so we can start playing it
        [UDJPlaylist sharedUDJPlaylist].currentSong = nextSong;
        [self playPlaylistCurrentSong];
        [self sendCurrentSongRequest: nextSong.librarySongId];
    }
    else{
        NSLog(@"setting state to paused");
        [self setPlayerState:PlayerStatePaused];
        [self sendPlayerStateRequest: PlayerStatePaused];
    }
}

#pragma mark - Keeping playlist up to date

-(void)playlistTimerFired{
    [[UDJPlaylist sharedUDJPlaylist] sendPlaylistRequest];
}

-(void)beginPlaylistUpdates{
    self.playlistTimer = [NSTimer scheduledTimerWithTimeInterval:7 target:self selector:@selector(playlistTimerFired) userInfo:nil repeats:YES];
}

-(void)endPlaylistUpdates{
    if(self.playlistTimer){
        [self.playlistTimer invalidate];
        self.playlistTimer = nil;
    }
}

#pragma mark - Playing music


-(float)currentPlaybackTime{
    if(![audioPlayer currentItem]) return 0;
    float time = (float)CMTimeGetSeconds([audioPlayer currentTime]);
    return time;
}

-(void)sendCurrentSongRequest:(UDJLibraryID)libraryID{
    RKClient* client = [RKClient sharedClient];
    
    //create url [POST] [POST] /udj/0_6/players/player_id/current_song
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingFormat:@"%@%d%@", @"/0_6/players/", self.playerID, @"/current_song", nil];
    
    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate: self.globalData];
    request.queue = client.requestQueue;
    request.method = RKRequestMethodPOST;
    request.userData = [NSString stringWithString: @"changeCurrentSong"];
    
    // set up the headers, including which type of request this is
    NSMutableDictionary* requestHeaders = [NSMutableDictionary dictionaryWithDictionary: globalData.headers];
    [requestHeaders setValue:@"playerMethodsDelegate" forKey:@"delegate"];
    request.additionalHTTPHeaders = requestHeaders;
    
    request.params = [NSDictionary dictionaryWithObject: [NSNumber numberWithUnsignedLongLong: libraryID] forKey: @"lib_id"];
    
    //send request
    [request send];
}

-(void)updateSongPosition:(NSInteger)seconds{
    [audioPlayer seekToTime: CMTimeMakeWithSeconds(seconds, 1)];
}

-(void)playPlaylistCurrentSong{
    
    // find the mediaItem for the current song
    UDJLibraryID mediaItemID = [UDJPlaylist sharedUDJPlaylist].currentSong.librarySongId;
    MPMediaPropertyPredicate* predicate = [MPMediaPropertyPredicate predicateWithValue: [NSNumber numberWithUnsignedLongLong:mediaItemID]forProperty:MPMediaItemPropertyPersistentID];
    MPMediaQuery* query = [[MPMediaQuery alloc] initWithFilterPredicates: [NSSet setWithObject: predicate]];
    [self updateCurrentMediaItem: [[query items] objectAtIndex: 0]];
    
    // update the current item on the audioplayer
    NSURL* url = [currentMediaItem valueForProperty: MPMediaItemPropertyAssetURL];
    AVPlayerItem* playerItem = [[AVPlayerItem alloc] initWithURL:url];
    [audioPlayer insertItem:playerItem afterItem: nil];
    
    // start up the audioplayer
    if([audioPlayer rate] == 0){
        [audioPlayer play];
    }
    else{
        [audioPlayer advanceToNextItem];
        [audioPlayer seekToTime: CMTimeMake(0, 1)];
        [audioPlayer play];
    }
    [self setPlayerState: PlayerStatePlaying];
    
    NSLog(@"%d songs on queue", [[audioPlayer items] count]);
}

-(void)updateCurrentMediaItem:(MPMediaItem*)item{
    self.currentMediaItem = item;
    self.songLength = [[currentMediaItem valueForProperty: MPMediaItemPropertyPlaybackDuration] floatValue];
    self.songPosition = 0;
    
    PlayerViewController* playerViewController = (PlayerViewController*)self.UIDelegate;
    [playerViewController updateDisplayWithItem: item];
}

-(BOOL)play{
    
    // if there is already a media item playing, resume it
    if(currentMediaItem){
        [self setPlayerState:PlayerStatePlaying];
        [audioPlayer play];
        return YES;
    }
    
    // if there are songs on the queue but no current song, update the current song to item at the top
    if(![UDJPlaylist sharedUDJPlaylist].currentSong && [[UDJPlaylist sharedUDJPlaylist] count] > 0){
        [self sendCurrentSongRequest: [UDJPlaylist sharedUDJPlaylist].currentSong.librarySongId]; // update the current song on the server side
        [UDJPlaylist sharedUDJPlaylist].currentSong = [[UDJPlaylist sharedUDJPlaylist] songAtIndex:0];
    }
        
    // if there is now a current song, update the current media item and begin playing
    // return YES to let caller know there was a song to play
    if([UDJPlaylist sharedUDJPlaylist].currentSong){
        [self playPlaylistCurrentSong];
        return YES;
    }
    
    // if there are no songs to play, return NO
    return NO;
}

-(void)pause{
    [self setPlayerState: PlayerStatePaused];
    [audioPlayer pause];
    [self sendPlayerStateRequest: PlayerStatePaused];
}


#pragma mark - Response handling

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response{
    NSLog(@"Player Manager response code: %d", [response statusCode]);
    
}


@end
