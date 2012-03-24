//
//  EventResultsViewController.h
//  UDJ
//
//  Created by Matthew Graf on 3/20/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDJEventData.h"
#import "UDJData.h"
#import "EventCell.h"

@interface EventResultsViewController : UIViewController <RKRequestDelegate>

@property(nonatomic,strong) UDJEventData* eventData;
@property(nonatomic,strong) NSMutableArray* tableList;
@property(nonatomic,strong) IBOutlet UITableView* tableView;
@property(nonatomic,strong) NSNumber* currentRequestNumber;
@property(nonatomic,strong) UDJData* globalData;

-(void) showPasswordScreen;

@end
