//
//  EventList.h
//  UDJ
//
//  Created by Matthew Graf on 12/21/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UDJConnection.h"

@interface EventList : NSObject{
    
    NSArray* currentList; // holds the last event list we loaded
    NSArray* tempList; // list to use while we are loading events
}

- (void)loadNearbyEvents; // put the nearby events into templist, then set it to currentList

@property(nonatomic,retain) NSArray* currentList;
@property(nonatomic,retain) NSArray* tempList;

@end
