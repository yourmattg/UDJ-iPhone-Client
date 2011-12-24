//
//  PartyListViewController.h
//  UDJ
//
//  Created by Matthew Graf on 9/24/11.
//  Copyright 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventList.h"


@interface PartyListViewController : UITableViewController {

    EventList* eventList; // the event list class to handle all the loading and stuff
	NSMutableArray *partyList; // the current list actually being shown
	
}

@property(nonatomic,retain) EventList* eventList;
@property (nonatomic, retain) NSMutableArray *partyList;

@end
