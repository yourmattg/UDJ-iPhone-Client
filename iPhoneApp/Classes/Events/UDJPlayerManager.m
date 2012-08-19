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

@implementation UDJPlayerManager

@synthesize playerName, playerPassword;
@synthesize address, stateLocation, city, zipCode;
@synthesize playerID;
@synthesize managedObjectContext, globalData, songSyncDictionary;
@synthesize isInPlayerMode, playerState;
@synthesize playerController, currentMediaItem;
@synthesize songLength, songPosition;
@synthesize UIDelegate;


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
        
        self.playerController = [MPMusicPlayerController iPodMusicPlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playingItemChanged) 
            name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil];
        [playerController beginGeneratingPlaybackNotifications];  
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
    
    [songDict setObject: [item valueForKey: MPMediaItemPropertyPersistentID] forKey:@"id"];
    
    if([item valueForKey: MPMediaItemPropertyTitle] == nil) title = @"Untitled";
    else title = [item valueForKey: MPMediaItemPropertyTitle];
    [songDict setObject: title forKey:@"title"];
    
    if([item valueForKey: MPMediaItemPropertyArtist] == nil) artist = @"Unknown Artist";
    else artist = [item valueForKey: MPMediaItemPropertyArtist];
    [songDict setObject: artist forKey:@"artist"];
    
    if([item valueForKey: MPMediaItemPropertyAlbumTitle] == nil) album = @"Unknown Album";
    else album = [item valueForKey: MPMediaItemPropertyAlbumTitle];
    [songDict setObject: album forKey:@"album"];
    
    if([item valueForKey: MPMediaItemPropertyGenre] == nil) genre = @"";
    else genre = [item valueForKey: MPMediaItemPropertyGenre];
    [songDict setObject: genre forKey:@"genre"];
    
    [songDict setObject: [NSNumber numberWithInt: 0] forKey:@"track"];
    
    [songDict setObject: [item valueForKey: MPMediaItemPropertyPlaybackDuration] forKey:@"duration"];
    
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
        NSNumber* libraryID = [mediaItem valueForKey: MPMediaItemPropertyPersistentID];
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

-(void)saveState{
    NSTimeInterval playbackTime = [playerController currentPlaybackTime];
    self.songPosition = playbackTime;
}

#pragma mark - Playback item changed

-(void)playingItemChanged{
    NSLog(@"playing item changed");
}

#pragma mark - Playing music

-(void)updateSongPosition:(NSInteger)seconds{
    [playerController setCurrentPlaybackTime: seconds];
}

-(void)updateCurrentMediaItem:(MPMediaItem*)item{
    self.currentMediaItem = item;
    self.songLength = [[currentMediaItem valueForKey: MPMediaItemPropertyPlaybackDuration] floatValue];
    self.songPosition = 0;
    
    PlayerViewController* playerViewController = (PlayerViewController*)self.UIDelegate;
    [playerViewController updateDisplayWithItem: item];
}

-(BOOL)play{
    unsigned long long mediaItemID;
    
    // if there is already a media item playing, resume it
    if(currentMediaItem){
        [playerController play];
        return YES;
    }
    
    // if there are songs on the queue but no current song, update the current song to item at the top
    if(![UDJPlaylist sharedUDJPlaylist].currentSong && [[UDJPlaylist sharedUDJPlaylist] count] > 0) 
        [UDJPlaylist sharedUDJPlaylist].currentSong = [[UDJPlaylist sharedUDJPlaylist] songAtIndex:0];
        
    // if there is now a current song, update the current media item and begin playing
    // return YES to let caller know there was a song to play
    if([UDJPlaylist sharedUDJPlaylist].currentSong){
        [self setPlayerState: PlayerStatePlaying];
        
        mediaItemID = [UDJPlaylist sharedUDJPlaylist].currentSong.librarySongId;
            
        MPMediaPropertyPredicate* predicate = [MPMediaPropertyPredicate predicateWithValue: [NSNumber numberWithUnsignedLongLong:mediaItemID]forProperty:MPMediaItemPropertyPersistentID];
        MPMediaQuery* query = [[MPMediaQuery alloc] initWithFilterPredicates: [NSSet setWithObject: predicate]];
        [self updateCurrentMediaItem: [[query items] objectAtIndex: 0]];
        [self.playerController setQueueWithQuery: query]; 
        [playerController play];
        
        return YES;
    }
    
    // if there are no songs to play, return NO
    return NO;
}

-(void)pause{
    [playerController pause];
    [self setPlayerState: PlayerStatePaused];
    [self sendPlayerStateRequest: PlayerStatePaused];
}


#pragma mark - Response handling

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response{
    NSLog(@"Player Manager response code: %d", [response statusCode]);
    
}


@end
