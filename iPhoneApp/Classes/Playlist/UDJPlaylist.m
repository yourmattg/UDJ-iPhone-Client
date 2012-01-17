//
//  UDJPlaylist.m
//  UDJ
//
//  Created by Matthew Graf on 12/27/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJPlaylist.h"
#import "UDJSong.h"
#import "UDJConnection.h"

@implementation UDJPlaylist

@synthesize playlist, eventId, currentSong, voteRecordKeeper;

-(void)initVoteRecordKeeper{
    voteRecordKeeper = [[NSMutableDictionary alloc] init];
}
- (UDJSong*)songAtIndex:(NSInteger)i{
    if(i<0 || i >= [playlist count]) return nil;
    return [playlist objectAtIndex:i];
}

// loadPlaylist: has UDJConnection send a playlist request
- (void)loadPlaylist{
    [[UDJConnection sharedConnection] sendPlaylistRequest:eventId];
}

- (UDJSong*)songPlaying{
    return currentSong;
}

// count: returns the number of songs in the playlist (including the current song playing)
- (NSInteger)count{
    // +1 because we include current song
    if(currentSong==nil) return 0;
    return [playlist count]+1;
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
			[[self alloc] init];        
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
-(void)dealloc{
    [playlist release]; 
    [currentSong release];
    [voteRecordKeeper release];
    [super dealloc];
}

@end
