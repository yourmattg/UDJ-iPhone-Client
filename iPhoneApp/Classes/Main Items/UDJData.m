//
//  GlobalData.m
//  UDJ
//
//  Created by Matthew Graf on 3/18/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJData.h"

@implementation UDJData

@synthesize requestCount, ticket, headers, userID;

#pragma mark Singleton methods
static UDJData* _sharedUDJData = nil;

+(UDJData*)sharedUDJData{
	@synchronized([UDJData class]){
		if (!_sharedUDJData)
			self = [[self alloc] init];      
		return _sharedUDJData;
	}    
	return nil;
}

+(id)alloc{
	@synchronized([UDJData class]){
		NSAssert(_sharedUDJData == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedUDJData = [super alloc];
		return _sharedUDJData;
	}
	return nil;
}

@end
