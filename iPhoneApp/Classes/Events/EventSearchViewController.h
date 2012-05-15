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
@property(nonatomic,strong) NSMutableArray *tableList;
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
