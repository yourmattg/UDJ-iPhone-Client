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
