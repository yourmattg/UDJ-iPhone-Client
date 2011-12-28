//
//  UDJPlaylist.m
//  UDJ
//
//  Created by Matthew Graf on 12/27/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJPlaylist.h"
#import "UDJSong.h"

@implementation UDJPlaylist

@synthesize playlist, eventId;

- (UDJSong*)songAtIndex:(NSInteger)i{
    return [playlist objectAtIndex:i];
}

- (void)loadPlaylist{
    
}

- (NSInteger)count{
    return [playlist count];
}

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

@end
