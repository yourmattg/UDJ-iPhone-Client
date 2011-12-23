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

@end
