//
//  UDJEvent.m
//  UDJ
//
//  Created by Matthew Graf on 12/23/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJEvent.h"

@implementation UDJEvent

@synthesize eventId, name, hostId, latitude, longitude, hostUsername, hasPassword;

+ (UDJEvent*) eventFromDictionary:(NSDictionary *)eventDict{
    UDJEvent* event = [UDJEvent new];
    event.name = [eventDict objectForKey:@"name"];
    event.eventId = [[eventDict objectForKey:@"id"] integerValue];
    event.hostId = [[eventDict objectForKey:@"host_id"] integerValue];
    event.latitude = [[eventDict objectForKey:@"latitude"] doubleValue];
    event.longitude = [[eventDict objectForKey:@"longitude"] doubleValue];
    event.hostUsername = [eventDict objectForKey:@"host_username"];
    event.hasPassword = [[eventDict objectForKey:@"has_password"] boolValue];
    return event;
}

// memory managed
- (void) dealloc{
    [name release];
    [hostUsername release];
    [super dealloc];
}
@end
