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

@interface UDJConnection : NSObject<RKRequestDelegate>{
    @public
    BOOL acceptAuth; // true if connection is accepting authorization responses
    BOOL acceptEvents; // awaiting an event list
    BOOL acceptPlaylist;
    BOOL acceptLibSearch;
    PlaylistViewController* playlistView;
    NSInteger clientRequestCount; // used to keep a unique client request id
    
    @private
    NSString* serverPrefix; // without spaces: http://0.0.0.0:4897/udj
    NSString* ticket;
    NSNumber* userID;
    RKClient* client; // configures, dispatches request
    UIViewController* currentController; // keeps track of the current view controller so we can pass info to it
    NSDictionary* headers;
    NSMutableDictionary* currentRequests;
    UINavigationController* navigationController;
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

- (float)getLongitude;
- (float)getLatitude;

- (void) sendPlaylistRequest:(NSInteger)eventId;
- (void)handlePlaylistResponse:(RKResponse*)response;

- (void)sendVoteRequest:(BOOL)up songId:(NSInteger)songId eventId:(NSInteger)eventId;
-(void)handleVoteResponse:(RKResponse*)response;

-(void)sendLibSearchRequest:(NSString*)param eventId:(NSInteger)eventId maxResults:(NSInteger)maxResults;
-(void)handleLibSearchResults:(RKResponse*)response;
-(void)sendAddSongRequest:(UDJSong*)song eventId:(NSInteger)eventId;
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

@end
