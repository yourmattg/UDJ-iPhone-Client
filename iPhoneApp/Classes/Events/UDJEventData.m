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

@synthesize currentList, lastSearchParam, currentEvent, locationManager, globalData, getEventsDelegate, enterEventDelegate, leaveEventDelegate;

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
    RKRequest* request = [[RKRequest alloc] initWithURL:url delegate: getEventsDelegate];
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
    RKRequest* request = [[RKRequest alloc] initWithURL:url delegate: getEventsDelegate];
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = globalData.headers;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++]; 
    request.queue = client.requestQueue;
    
    // send request and handle response
    [request send];
}

// enterEventRequest: attempts to log in user to party, returns status code of response
- (void) enterEvent:(NSString*)password{

    RKClient* client = [RKClient sharedClient];
    
    //create url
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingString:@"/events/"];
    urlString = [urlString stringByAppendingFormat:@"%d",[UDJEventData sharedEventData].currentEvent.eventId];
    urlString = [urlString stringByAppendingString:@"/users/"];
    urlString = [urlString stringByAppendingFormat:@"%i", [globalData.userID intValue]];
    
    //set up request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate: enterEventDelegate];
    request.method = RKRequestMethodPUT;
    request.additionalHTTPHeaders = globalData.headers;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++];
    request.queue = client.requestQueue;
    
    // add the password to the header if neccessary
    if(password != nil){
        [request.additionalHTTPHeaders setValue:password forKey:@"X-Udj-Event-Password"];
    }
    
    //send request
    [request send];
    
    /*
    // if user is already in another event, set currentEvent to that event
    if(response.statusCode==409){
        RKJSONParserJSONKit* parser = [RKJSONParserJSONKit new];
        NSDictionary* eventDict = [parser objectFromString:[response bodyAsString] error:nil];
        [UDJEventData sharedEventData].currentEvent = [UDJEvent eventFromDictionary:eventDict];
    }*/
}


- (void) leaveEvent{
    RKClient* client = [RKClient sharedClient];
    //create url
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingString:@"/events/"];
    urlString = [urlString stringByAppendingFormat:@"%d",[UDJEventData sharedEventData].currentEvent.eventId];
    urlString = [urlString stringByAppendingString:@"/users/"];
    urlString = [urlString stringByAppendingFormat:@"%d", [[UDJData sharedUDJData].userID intValue]];
    
    //set up request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate: leaveEventDelegate];
    request.method = RKRequestMethodDELETE;
    request.additionalHTTPHeaders = globalData.headers;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++];
    request.queue = client.requestQueue;
    
    //send request, handle results
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
