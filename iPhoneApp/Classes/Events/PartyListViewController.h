//
//  PartyListViewController.h
//  UDJ
//
//  Created by Matthew Graf on 9/24/11.
//  Copyright 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDJEventList.h"


@interface PartyListViewController : UIViewController <UIAlertViewDelegate> {

    UDJEventList* eventList; // the event list class to handle all the loading and stuff
	NSMutableArray *tableList; // the current list actually being shown
    UITableView* tableView;
    UILabel* searchResultLabel;
	
}

-(void)refreshTableList; // rebuild the tableList and show it
-(void)pushSearchScreen;

@property(nonatomic,strong) UDJEventList* eventList;
@property (nonatomic, strong) NSMutableArray *tableList;
@property(nonatomic,strong) IBOutlet UITableView* tableView;
@property(nonatomic,strong) IBOutlet UILabel* searchResultLabel;

@end
