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

#import <Foundation/Foundation.h>
#import "LocationManager.h"
#import "UDJConnection.h"
#import "UDJEvent.h"
#import "UDJData.h"

@interface UDJEventData : NSObject{
    
    NSMutableArray* currentList; // holds the last event list we loaded
    NSString* lastSearchParam; // the last string we tried searching
    UDJEvent* currentEvent; // the event id the client is logged in/trying to connect to
    
    UDJData* globalData;
    
    UIViewController* getEventsDelegate; // this will be the EventSearchViewController
    UIViewController* enterEventDelegate; // this will be the EventResultsViewController
    UIViewController* leaveEventDelegate; // PLaylistViewController
}

+ (UDJEventData*)sharedEventData;
- (void)getNearbyEvents; // put the nearby events into templist, then set it to currentList
- (void)getEventsByName:(NSString*)name; // search for events by name and put them in table
- (void)enterEvent:(NSString*)password;
//- (void)leaveEvent;

@property(nonatomic,strong) NSMutableArray* currentList;
@property(nonatomic,strong) NSString* lastSearchParam;
@property(nonatomic,strong) UDJEvent* currentEvent;
@property(nonatomic,strong) LocationManager* locationManager;
@property(nonatomic,strong) UDJData* globalData;
@property(nonatomic,strong) UIViewController* getEventsDelegate;
@property(nonatomic,strong) UIViewController* enterEventDelegate;
@property(nonatomic,strong) UIViewController* leaveEventDelegate;

@end
