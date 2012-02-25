//
//  EventList.m
//  UDJ
//
//  Created by Matthew Graf on 12/21/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJEventList.h"
#import "UDJConnection.h"

@implementation UDJEventList

@synthesize currentList, lastSearchParam, currentEvent;

// getNearbyEvents: has the UDJConnection send a event search request
- (void) getNearbyEvents{
    [[UDJConnection sharedConnection] sendNearbyEventSearch];
}

// getEventsByName: has the UDJConnection send a event search request
- (void)getEventsByName:(NSString *)name{
    [[UDJConnection sharedConnection] sendEventSearch:name];
}

// access the EventList anywhere using [EventList sharedEventList]
#pragma mark Singleton methods
static UDJEventList* _sharedEventList = nil;

+(UDJEventList*)sharedEventList{
	@synchronized([UDJEventList class]){
		if (!_sharedEventList)
			self = [[self alloc] init];        
		return _sharedEventList;
	}    
	return nil;
}

+(id)alloc{
	@synchronized([UDJEventList class]){
		NSAssert(_sharedEventList == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedEventList = [super alloc];
		return _sharedEventList;
	}
	return nil;
}

-(id)init {
	self = [super init];
	return self;
}

// memory managed

@end
