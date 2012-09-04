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

#import "UDJPlaylist.h"
#import "UDJSong.h"
#import "RestKit/RKJSONParserJSONKit.h"
#import "UDJPlayerManager.h"

@implementation UDJPlaylist

@synthesize playlist, playerID, currentSong, delegate, globalData;
@synthesize playlistDelegate;

- (UDJSong*)songAtIndex:(NSInteger)i{
    if(i<0 || i >= [playlist count]) return nil;
    return [playlist objectAtIndex:i];
}

// sendPlaylistRequest: requests playlist from server, seperate from handling because
// we want client to be able to do other things while we wait for it to refresh
- (void)sendPlaylistRequest{
    RKClient* client = [RKClient sharedClient];
    
    //create url [GET] {prefix}/events/event_id/active_playlist
    NSString* urlString = [client.baseURL absoluteString];
    urlString = [urlString stringByAppendingFormat:@"/players/%@/active_playlist", playerID, nil];

    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.delegate = self;
    request.queue = client.requestQueue;
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = globalData.headers;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++];
    
    request.backgroundPolicy = RKRequestBackgroundPolicyContinue;
    
    // foreground mode
    if(![[UDJPlayerManager sharedPlayerManager] isInBackground]) [request send];
    
    // background mode
    else{
        RKResponse* response = [request sendSynchronously];
        //NSLog(@"got playlist response while in background");
        [self request:request didLoadResponse:response];        
    }
}


-(void)sendVoteRequest:(BOOL)up songId:(NSString*)songId{
    RKClient* client = [RKClient sharedClient];
    
    //create url [POST] players/player_id/active_playlist/lib_id/upvote
    NSString* urlString = [client.baseURL absoluteString];
    urlString = [urlString stringByAppendingFormat:@"/players/%@/active_playlist/songs/%@/", playerID, songId, nil];
    if(up) urlString = [urlString stringByAppendingString:@"upvote"];
    else urlString = [urlString stringByAppendingString:@"downvote"];
    NSLog(urlString);
    
    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.delegate = self.delegate;
    request.queue = client.requestQueue;
    request.method = RKRequestMethodPUT;
    request.additionalHTTPHeaders = globalData.headers;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++];
    
    //send request
    //[currentRequests setObject:@"voteRequest" forKey:request]; was causing error
    [request send];    
}

- (UDJSong*)songPlaying{
    return currentSong;
}

// count: returns the number of songs in the playlist (including the current song playing)
- (NSInteger)count{
    // +1 because we include current song
    if(currentSong==nil && [playlist count]==0) return 0;
    return [playlist count];
}

// clearPlaylist: makes the playlist empty
-(void)clearPlaylist{
    currentSong=nil;
    [playlist removeAllObjects];
}



#pragma mark - Response handling

// handlePlaylistResponse: this is done asynchronously from the send method so the client can do other things meanwhile
// NOTE: this calls [playlistView refreshTableList] for you!
- (void)handlePlaylistResponse:(RKResponse*)response{
    
    NSMutableArray* tempList = [NSMutableArray new];
    
    RKJSONParserJSONKit* parser = [RKJSONParserJSONKit new];
    // response dict: holds current song and array of songs
    NSDictionary* responseDict = [parser objectFromString:[response bodyAsString] error:nil];
    UDJSong* newCurrentSong = [UDJSong songFromDictionary:[responseDict objectForKey:@"current_song"] isLibraryEntry:NO];
    
    // the array holding the songs on the playlist
    NSArray* songArray = [responseDict objectForKey:@"active_playlist"];
    for(int i=0; i<[songArray count]; i++){
        NSDictionary* songDict = [songArray objectAtIndex:i];
        UDJSong* song = [UDJSong songFromDictionary:songDict isLibraryEntry:NO];
        [tempList addObject:song];
    }
    
    [self setPlaylist: tempList];
    [self setCurrentSong: newCurrentSong];
    //NSLog(@"updated playlist. current song = %@, playlist count = %d", newCurrentSong.title, [self count]);
    
    // send message to delegate (Playlist view controller)
    [playlistDelegate playlistDidUpdate: responseDict];
}

-(void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response{
    //NSLog(@"Response Code: %d", [response statusCode]);
    if ([request isGET]) {
        [self handlePlaylistResponse:response];        
    }
}





// access the playlist anywhere in the app using [UDJPlaylist sharedPlaylist]
#pragma mark Singleton methods
static UDJPlaylist* _sharedUDJPlaylist = nil;

+(UDJPlaylist*)sharedUDJPlaylist{
	@synchronized([UDJPlaylist class]){
		if (!_sharedUDJPlaylist)
			_sharedUDJPlaylist = [[self alloc] init];        
		return _sharedUDJPlaylist;
	}    
	return nil;
}

+(id)alloc{
	@synchronized([UDJPlaylist class]){
		NSAssert(_sharedUDJPlaylist == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedUDJPlaylist = [super alloc];
		return _sharedUDJPlaylist;
	}
	return nil;
}

// memory managed

@end
