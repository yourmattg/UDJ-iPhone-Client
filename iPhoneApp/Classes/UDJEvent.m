//
//  UDJEvent.m
//  UDJ
//
//  Created by Matthew Graf on 12/23/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJEvent.h"

@implementation UDJEvent

@synthesize eventId, name, hostId, latitude, longitude;

- (UDJEvent*) eventWithId:(NSString *)eventid name:(NSString *)eventname hostId:(NSString *)hostid latitude:(NSString *)lat longitude:(NSString *)lon{
    UDJEvent* udjevent;
    udjevent.eventId = eventid;
    udjevent.name = eventname;
    udjevent.hostId = hostid;
    udjevent.latitude = lat;
    udjevent.longitude = lon;
    return udjevent;
}

@end
