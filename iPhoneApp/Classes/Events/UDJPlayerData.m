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

#import "UDJPlayerData.h"
#import "RestKit/RestKit.h"

@implementation UDJPlayerData

@synthesize currentList, lastSearchParam, currentPlayer, locationManager, globalData, leaveEventDelegate, playerListDelegate;

// getNearbyEvents: has the UDJConnection send a event search request
- (void) getNearbyPlayers{
    RKClient* client = [RKClient sharedClient];
    
    // use location manager to get long/latitude
    float latitude = [locationManager getLatitude];
    float longitude = [locationManager getLongitude];
    
    // create URL
    NSString* urlString = [client.baseURL absoluteString];
    urlString = [urlString stringByAppendingFormat:@"%@%f%@%f", @"/players/", latitude, @"/", longitude];
    NSURL* url = [NSURL URLWithString:urlString];
    
    // create GET request
    RKRequest* request = [[RKRequest alloc] initWithURL:url];
    request.delegate = playerListDelegate;
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = globalData.headers;    
    
    request.userData = [NSNumber numberWithInt: globalData.requestCount++]; 
    request.queue = client.requestQueue;
    
    // send request 
    [request send];
    //[self handleEventResults:response isNearbySearch:NO];
}

// getEventsByName
- (void)getEventsByName:(NSString *)name{
    RKClient* client = [RKClient sharedClient];
    
    name = [name stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    // create the URL
    NSString* urlString = [client.baseURL absoluteString];
    urlString = [urlString stringByAppendingString:@"/players?name="];
    urlString = [urlString stringByAppendingString:name];
    NSURL* url = [NSURL URLWithString:urlString];
    
    //create GET request with correct parameters and headers
    RKRequest* request = [[RKRequest alloc] initWithURL:url];
    request.delegate = playerListDelegate;
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = globalData.headers;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++]; 
    request.queue = client.requestQueue;
    
    // send request and handle response
    [request send];
}

// joinPlayer: attempts to log in user to party, returns status code of response
- (void)joinPlayer:(NSString*)password{

    RKClient* client = [RKClient sharedClient];
    
    //create url
    NSString* urlString = [client.baseURL absoluteString];
    urlString = [urlString stringByAppendingString:@"/players/"];
    urlString = [urlString stringByAppendingFormat:@"%@",[UDJPlayerData sharedPlayerData].currentPlayer.playerID];
    urlString = [urlString stringByAppendingString:@"/users/user"];
    
    //set up request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.delegate = playerListDelegate;
    request.method = RKRequestMethodPUT;
    request.additionalHTTPHeaders = globalData.headers;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++];
    request.queue = client.requestQueue;
    
    // add the password to the header if neccessary
    if(password != nil){ 
        NSMutableDictionary* dictionaryWithPass = [NSMutableDictionary dictionaryWithDictionary: globalData.headers];
        [dictionaryWithPass setValue:password forKey:@"X-Udj-Player-Password"];
        request.additionalHTTPHeaders = dictionaryWithPass;
    }
    
    //send request
    [request send];
}



-(void)setState:(NSString*)state{
    RKClient* client = [RKClient sharedClient];
    //create url [POST] /udj/users/user_id/players/player_id/state
    NSString* urlString = [client.baseURL absoluteString];
    urlString = [urlString stringByAppendingFormat: @"/players/%@/state", currentPlayer.playerID, nil];
    
    //set up request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSDictionary* stateParam = [NSDictionary dictionaryWithObjectsAndKeys: state, @"state", nil]; 
    request.params = stateParam;
    request.method = RKRequestMethodPOST;
    request.additionalHTTPHeaders = globalData.headers;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++];
    request.queue = client.requestQueue;
    
    //send request, handle results
    [request send];    
}

//[POST] /udj/users/user_id/players/player_id/volume
-(void)setVolume:(NSInteger)volume{
    RKClient* client = [RKClient sharedClient];
    //create url [POST] /udj/users/user_id/players/player_id/state
    NSString* urlString = [client.baseURL absoluteString];
    urlString = [urlString stringByAppendingFormat: @"/players/%@/volume", currentPlayer.playerID, nil];
    
    //set up request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSDictionary* volumeParam = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt: volume], @"volume", nil]; 
    request.params = volumeParam;
    request.method = RKRequestMethodPOST;
    request.additionalHTTPHeaders = globalData.headers;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++];
    request.queue = client.requestQueue;
    
    //send request, handle results
    [request send];    
}


// access the EventList anywhere using [EventList sharedEventList]
#pragma mark Singleton methods
static UDJPlayerData* _sharedEventList = nil;

+(UDJPlayerData*)sharedPlayerData{
    @synchronized([UDJPlayerData class]){
        if (!_sharedEventList)
                _sharedEventList = [[self alloc] init];        
        return _sharedEventList;
    }    
    return nil;
}

+(id)alloc{
    @synchronized([UDJPlayerData class]){
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
