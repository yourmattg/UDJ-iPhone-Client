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
#import "UDJConnection.h"

@implementation UDJPlaylist

@synthesize playlist, eventId, currentSong, voteRecordKeeper, delegate, globalData;

-(void)initVoteRecordKeeper{
    voteRecordKeeper = [[NSMutableDictionary alloc] init];
}
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











// access the playlist anywhere in the app using [UDJPlaylist sharedPlaylist]
#pragma mark Singleton methods
static UDJPlaylist* _sharedUDJPlaylist = nil;

+(UDJPlaylist*)sharedUDJPlaylist{
	@synchronized([UDJPlaylist class]){
		if (!_sharedUDJPlaylist)
			self = [[self alloc] init];        
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
