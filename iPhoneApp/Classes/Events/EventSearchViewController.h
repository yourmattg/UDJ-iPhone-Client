//
//  EventSearchViewController.h
//  UDJ
//
//  Created by Matthew Graf on 9/24/11.
//  Copyright 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDJData.h"
#import "UDJEventData.h"


@interface EventSearchViewController : UIViewController <UIAlertViewDelegate, RKRequestDelegate> {
    UDJData* globalData;
    
    UDJEventData* eventData; // the event list class to handle all the loading and stuff
	NSMutableArray *tableList; // the current list actually being shown
    UITableView* tableView;
    UILabel* searchResultLabel;
    
    NSNumber* currentRequestNumber;
    
    UILabel* greetingLabel;
    
    UITextField* eventNameField;
    UIButton* findNearbyButton;
    UIButton* eventSearchButton;
    
    NSString* lastSearchType;
    
    UIView* searchingBackgroundView;
    UIView* searchingView;
	
}

-(void)refreshTableList; // rebuild the tableList and show it
-(void) toggleSearchingView:(BOOL) active;

@property(nonatomic,strong) UDJEventData* eventData;
@property (nonatomic, strong) NSMutableArray *tableList;
@property(nonatomic,strong) IBOutlet UITableView* tableView;
@property(nonatomic,strong) IBOutlet UILabel* searchResultLabel;
@property(nonatomic,strong) UDJData* globalData;
@property(nonatomic,strong) NSNumber* currentRequestNumber;
@property(nonatomic,strong) IBOutlet UITextField* eventNameField;
@property(nonatomic,strong) IBOutlet UIButton* findNearbyButton;
@property(nonatomic,strong) IBOutlet UIButton* eventSearchButton;
@property(nonatomic,strong) NSString* lastSearchType;
@property(nonatomic,strong) IBOutlet UIView* searchingBackgroundView;
@property(nonatomic,strong) IBOutlet UIView* searchingView;

@end
