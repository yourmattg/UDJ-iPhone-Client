//
//  UDJViewController.h
//  UDJ
//
//  Created by Matthew Graf on 9/24/11.
//  Copyright 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UDJViewController : UIViewController {

	
	UIButton *loginButton;
	UITextField *usernameField;
	UITextField *passwordField;
	
}

@property (retain,nonatomic) IBOutlet UIButton *loginButton;
@property (retain,nonatomic) IBOutlet UITextField *usernameField;
@property (retain,nonatomic) IBOutlet UITextField *passwordField;

- (IBAction) OnButtonClick:(id) sender;

@end

