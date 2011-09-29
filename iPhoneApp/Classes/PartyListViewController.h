//
//  PartyListViewController.h
//  UDJ
//
//  Created by Matthew Graf on 9/24/11.
//  Copyright 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PartyListViewController : UITableViewController {

	NSMutableArray *partyList;
	
}

@property (nonatomic, retain) NSMutableArray *partyList;

@end
