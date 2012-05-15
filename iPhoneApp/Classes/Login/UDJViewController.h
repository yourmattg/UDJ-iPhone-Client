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
#import <RestKit/RestKit.h>
#import "UDJData.h"
#import <QuartzCore/QuartzCore.h>

@interface UDJViewController : UIViewController <RKRequestDelegate, UIAlertViewDelegate> {

	
	UIButton *loginButton;
	UITextField *usernameField;
	UITextField *passwordField;
    UIButton* registerButton;
    
    NSNumber* currentRequestNumber;
    
    UDJData* globalData;
    
    UIView* loginBackgroundView;
    UIView* loginView;
    UIButton* cancelButton;
}

@property (strong,nonatomic) IBOutlet UIButton *loginButton;
@property (strong,nonatomic) IBOutlet UITextField *usernameField;
@property (strong,nonatomic) IBOutlet UITextField *passwordField;
@property (strong,nonatomic) IBOutlet UIButton *registerButton;
@property(nonatomic,strong) NSNumber* currentRequestNumber;
@property(nonatomic,strong) UDJData* globalData;

@property(nonatomic,strong) IBOutlet UIView* loginView;
@property(nonatomic,strong) IBOutlet UIView* loginBackgroundView;
@property(nonatomic,strong) IBOutlet UIButton* cancelButton;

- (IBAction) OnButtonClick:(id) sender;
- (IBAction) cancelButtonClick:(id)sender;

@end

