//
//  EventList.m
//  UDJ
//
//  Created by Matthew Graf on 12/21/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "EventList.h"
#import "UDJConnection.h"

@implementation EventList

@synthesize currentList, tempList;

- (void) getNearbyEvents{
    // get coordinates
}

- (void)getEventsByName:(NSString *)name{
    [[UDJConnection sharedConnection] sendEventSearch:name];
}

#pragma mark Singleton methods
static EventList* _sharedEventList = nil;

+(EventList*)sharedEventList{
	@synchronized([EventList class]){
		if (!_sharedEventList)
			[[self alloc] init];        
		return _sharedEventList;
	}    
	return nil;
}

+(id)alloc{
	@synchronized([EventList class]){
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

@end
