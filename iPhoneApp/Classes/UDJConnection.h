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

@interface UDJConnection : NSObject<RKRequestDelegate>{
    @public
    BOOL acceptAuth; // true if connection is accepting authorization responses
    BOOL acceptEvents; // awaiting an event list
    
    @private
    NSString* serverPrefix; // without spaces: http://0.0.0.0:4897/udj
    NSString* ticket;
    NSString* userID;
    RKClient* client; // configures, dispatches request
    UIViewController* currentController; // keeps track of the current view controller so we can pass info to it
    NSDictionary* headers;
}

+ (id) sharedConnection;
- (void) setCurrentController:(id) controller; // setting the current view controller

- (void) initWithServerPrefix:(NSString*)prefix;

- (void) authenticate:(NSString*)username password:(NSString*)pass;
- (void) authCancel;
- (void) denyAuth;

- (void) sendEventSearch:(NSString*)name; // request events by name
- (void) handleEventResults:(RKResponse*)response;
- (void) acceptEvents:(BOOL)value;

@property(nonatomic,retain) NSString* serverPrefix;
@property(nonatomic,retain) NSString* ticket;
@property(nonatomic,retain) RKClient* client;
@property(nonatomic,retain) NSString* userID;
@property(nonatomic,retain) NSDictionary* headers;

@end
