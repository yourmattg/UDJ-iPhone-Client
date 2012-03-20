//
//  EventList.m
//  UDJ
//
//  Created by Matthew Graf on 12/21/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJEventData.h"
#import "UDJConnection.h"
#import "RestKit/RestKit.h"

@implementation UDJEventData

@synthesize currentList, lastSearchParam, currentEvent, locationManager, globalData, delegate;

// getNearbyEvents: has the UDJConnection send a event search request
- (void) getNearbyEvents{
    RKClient* client = [RKClient sharedClient];
    
    // use location manager to get long/latitude
    float latitude = [locationManager getLatitude];
    float longitude = [locationManager getLongitude];
    
    // create URL
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingFormat:@"%@%f%@%f", @"/events/", latitude, @"/", longitude];
    NSURL* url = [NSURL URLWithString:urlString];
    
    // create GET request
    RKRequest* request = [[RKRequest alloc] initWithURL:url delegate: delegate];
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = globalData.headers;    
    request.userData = [NSNumber numberWithInt: globalData.requestCount++]; 
    request.queue = client.requestQueue;
    
    // send request 
    [request send];
    //[self handleEventResults:response isNearbySearch:NO];
}

// getEventsByName: has the UDJConnection send a event search request
- (void)getEventsByName:(NSString *)name{
    RKClient* client = [RKClient sharedClient];
    
    // create the URL
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingString:@"/events?name="];
    urlString = [urlString stringByAppendingString:name];
    NSURL* url = [NSURL URLWithString:urlString];
    
    //create GET request with correct parameters and headers
    RKRequest* request = [[RKRequest alloc] initWithURL:url delegate: delegate];
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = globalData.headers;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++]; 
    request.queue = client.requestQueue;
    
    // send request and handle response
    [request send];
}

// access the EventList anywhere using [EventList sharedEventList]
#pragma mark Singleton methods
static UDJEventData* _sharedEventList = nil;

+(UDJEventData*)sharedEventData{
	@synchronized([UDJEventData class]){
		if (!_sharedEventList)
			self = [[self alloc] init];        
		return _sharedEventList;
	}    
	return nil;
}

+(id)alloc{
	@synchronized([UDJEventData class]){
		NSAssert(_sharedEventList == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedEventList = [super alloc];
		return _sharedEventList;
	}
	return nil;
}

-(id)init {
	self = [super init];
    
    locationManager = [[LocationManager alloc] init];
    globalData = [UDJData sharedUDJData];
    
	return self;
}

// memory managed

@end
