//
//  EventList.h
//  UDJ
//
//  Created by Matthew Graf on 12/21/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UDJConnection.h"
#import "UDJEvent.h"

@interface UDJEventList : NSObject{
    
    NSMutableArray* currentList; // holds the last event list we loaded
    NSString* lastSearchParam; // the last string we tried searching
    UDJEvent* currentEvent; // the event id the client is logged in/trying to connect to
    NSString* lastSearchType;
}

+ (UDJEventList*)sharedEventList;
- (void)getNearbyEvents; // put the nearby events into templist, then set it to currentList
- (void)getEventsByName:(NSString*)name; // search for events by name and put them in table

@property(nonatomic,strong) NSMutableArray* currentList;
@property(nonatomic,strong) NSString* lastSearchParam;
@property(nonatomic,strong) UDJEvent* currentEvent;
@property(nonatomic,strong) NSString* lastSearchType;

@end
