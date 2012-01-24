//
//  UDJConnection.h
//  UDJ
//
//  Created by Matthew Graf on 12/13/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import <RestKit/RKJSONParserJSONKit.h>
#import <RestKit/JSONKit.h>
#import "PlaylistViewController.h"
#import "LocationManager.h"

@interface UDJConnection : NSObject<RKRequestDelegate>{
    @public
    BOOL acceptAuth; // true if connection is accepting authorization responses
    BOOL acceptEvents; // awaiting an event list
    BOOL acceptPlaylist;
    BOOL acceptLibSearch;
    BOOL acceptEventGoers;
    PlaylistViewController* playlistView;
    NSInteger clientRequestCount; // used to keep a unique client request id
    NSNumber* userID;
    
    @private
    NSString* serverPrefix; // without spaces: http://0.0.0.0:4897/udj
    NSString* ticket;
    RKClient* client; // configures, dispatches request
    UIViewController* currentController; // keeps track of the current view controller so we can pass info to it
    NSDictionary* headers;
    NSMutableDictionary* currentRequests;
    UINavigationController* navigationController;
    LocationManager* locationManager;
    
}

+ (id) sharedConnection;
- (void) setCurrentController:(id) controller; // setting the current view controller

- (void) initWithServerPrefix:(NSString*)prefix;

- (void) authenticate:(NSString*)username password:(NSString*)pass;
- (void) authCancel;
- (void) denyAuth:(RKResponse*)response;

- (void) sendEventSearch:(NSString*)name; // request events by name
- (void) sendNearbyEventSearch;
- (void) handleEventResults:(RKResponse*)response;
- (void) acceptEvents:(BOOL)value;
- (NSInteger) enterEventRequest;
- (NSInteger) leaveEventRequest;
- (void) sendEventGoerRequest:(NSInteger)eventId delegate:(NSObject*)delegate;
- (void) handleEventGoerResults:(RKResponse*)response;

- (void) sendPlaylistRequest:(NSInteger)eventId;
- (void)handlePlaylistResponse:(RKResponse*)response;

- (void)sendVoteRequest:(BOOL)up songId:(NSInteger)songId eventId:(NSInteger)eventId;
-(void)handleVoteResponse:(RKResponse*)response;
-(void)sendSongRemoveRequest:(NSInteger)songId eventId:(NSInteger)eventId;

-(void)sendLibSearchRequest:(NSString*)param eventId:(NSInteger)eventId maxResults:(NSInteger)maxResults;
-(void)handleLibSearchResults:(RKResponse*)response;
-(void)sendAddSongRequest:(NSInteger)librarySongId eventId:(NSInteger)eventId;
-(void)handleFailedSongAdd:(RKRequest*)request;

-(void)resetAcceptResponses;
-(void)resetToEventView;

@property(nonatomic,retain) NSString* serverPrefix;
@property(nonatomic,retain) NSString* ticket;
@property(nonatomic,retain) RKClient* client;
@property(nonatomic,retain) NSNumber* userID;
@property(nonatomic,retain) NSDictionary* headers;
@property(nonatomic,retain) NSMutableDictionary* currentRequests;
// using assign here because we only need a weak reference
@property(nonatomic, assign) PlaylistViewController* playlistView;
@property(nonatomic) BOOL acceptLibSearch;
@property(nonatomic,assign) UINavigationController* navigationController;
@property(nonatomic,retain) LocationManager* locationManager;

@end
