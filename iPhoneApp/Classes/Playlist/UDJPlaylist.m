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

@implementation UDJPlaylist

@synthesize playlist, eventId, currentSong, delegate, globalData;

- (UDJSong*)songAtIndex:(NSInteger)i{
    if(i<0 || i >= [playlist count]) return nil;
    return [playlist objectAtIndex:i];
}

// sendPlaylistRequest: requests playlist from server, seperate from handling because
// we want client to be able to do other things while we wait for it to refresh
- (void)sendPlaylistRequest{
    RKClient* client = [RKClient sharedClient];
    
    //create url [GET] {prefix}/events/event_id/active_playlist
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingFormat:@"%@%d%@", @"/players/", eventId, @"/active_playlist"];

    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate: delegate];
    request.queue = client.requestQueue;
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = globalData.headers;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++];
    
    //send request
    [request send];
}


-(void)sendVoteRequest:(BOOL)up songId:(NSInteger)songId{
    RKClient* client = [RKClient sharedClient];
    
    //create url [POST] {prefix}/udj/events/event_id/active_playlist/playlist_id/users/user_id/upvote
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingFormat:@"%@%d%@%d%@%d%@", @"/players/", eventId, @"/active_playlist/songs/",songId,@"/users/",[globalData.userID intValue],@"/"];
    if(up) urlString = [urlString stringByAppendingString:@"upvote"];
    else urlString = [urlString stringByAppendingString:@"downvote"];
    
    NSLog(@"song id %d", songId);
    
    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate: delegate];
    request.queue = client.requestQueue;
    request.method = RKRequestMethodPOST;
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


/*
#pragma mark - Vote record keeping

-(void)addSong:(UDJSong *)song withVote:(BOOL)up{
    //UDJVoteRecord* voteRecord = [[UDJVoteRecord alloc] initWithSong:song];
    NSNumber* voteRecord = [NSNumber numberWithInteger: song.librarySongId];
    NSNumber* vote = [NSNumber numberWithBool: up];
    
    // find the dictionary for the event we're in
    NSNumber* playerID = [NSNumber numberWithInteger: eventId];
    NSMutableDictionary* playerDictionary = [allPlayersDictionary objectForKey: playerID];
    if(playerDictionary == nil){
        playerDictionary = [[NSMutableDictionary alloc] initWithCapacity: 10];
        [allPlayersDictionary setObject: playerDictionary forKey: playerID];
    }
    
    // add the song with the appropriate vote status
    [playerDictionary setObject: vote forKey: voteRecord];
}

-(enum VoteStatus)getVoteStatusForSong:(UDJSong *)song{
    //UDJVoteRecord* voteRecord = [[UDJVoteRecord alloc] initWithSong:song];
    NSNumber* voteRecord = [NSNumber numberWithInteger: song.librarySongId];
    
    // find the dictionary for the event we're in
    NSNumber* playerID = [NSNumber numberWithInteger: eventId];
    NSMutableDictionary* playerDictionary = [allPlayersDictionary objectForKey: playerID];
    
    // if there's no dictionary for this player, there's obviously no vote yet
    if(playerDictionary == nil) return VoteStatusNull;
    
    // return the appropriate vote status
    NSNumber* vote = [playerDictionary objectForKey: voteRecord];
    if(vote == nil) return VoteStatusNull;
    else if([vote boolValue] == NO) return VoteStatusDown;
    return VoteStatusUp;
}

*/







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
