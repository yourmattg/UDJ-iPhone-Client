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

@property (strong,nonatomic) IBOutlet UIButton *loginButton;
@property (strong,nonatomic) IBOutlet UITextField *usernameField;
@property (strong,nonatomic) IBOutlet UITextField *passwordField;

- (IBAction) OnButtonClick:(id) sender;

@end

