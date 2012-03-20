//
//  PartyListViewController.h
//  UDJ
//
//  Created by Matthew Graf on 9/24/11.
//  Copyright 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDJData.h"
#import "UDJEventData.h"


@interface PartyListViewController : UIViewController <UIAlertViewDelegate, RKRequestDelegate> {
    UDJData* globalData;
    
    UDJEventData* eventData; // the event list class to handle all the loading and stuff
	NSMutableArray *tableList; // the current list actually being shown
    UITableView* tableView;
    UILabel* searchResultLabel;
    
    NSNumber* currentRequestNumber;
	
}

-(void)refreshTableList; // rebuild the tableList and show it
-(void)pushSearchScreen;

@property(nonatomic,strong) UDJEventData* eventData;
@property (nonatomic, strong) NSMutableArray *tableList;
@property(nonatomic,strong) IBOutlet UITableView* tableView;
@property(nonatomic,strong) IBOutlet UILabel* searchResultLabel;
@property(nonatomic,strong) UDJData* globalData;
@property(nonatomic,strong) NSNumber* currentRequestNumber;

@end
