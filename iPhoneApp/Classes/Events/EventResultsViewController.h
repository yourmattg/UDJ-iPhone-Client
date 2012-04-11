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

@interface EventResultsViewController : UIViewController <RKRequestDelegate, UIAlertViewDelegate>

@property(nonatomic,strong) UDJEventData* eventData;
@property(nonatomic,strong) NSMutableArray* tableList;
@property(nonatomic,strong) IBOutlet UITableView* tableView;
@property(nonatomic,strong) NSNumber* currentRequestNumber;
@property(nonatomic,strong) UDJData* globalData;

@property(nonatomic,strong) IBOutlet UIView* joiningView;
@property(nonatomic,strong) IBOutlet UIView* joiningBackgroundView;
@property(nonatomic,strong) IBOutlet UIButton* cancelButton;

-(void) showPasswordScreen;
-(void) toggleJoiningView:(BOOL) active;
-(void)joinEvent;

@end
