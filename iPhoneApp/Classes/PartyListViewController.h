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
	NSMutableArray *tableList; // the current list actually being shown
	
}

-(void)refreshTableList; // rebuild the tableList and show it
-(void)pushSearchScreen;

@property(nonatomic,retain) EventList* eventList;
@property (nonatomic, retain) NSMutableArray *tableList;

@end
