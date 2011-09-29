//
//  PartyLoginViewController.h
//  UDJ
//
//  Created by Matthew Graf on 9/24/11.
//  Copyright 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PartyLoginViewController : UIViewController {

	UITextField *passwordField;
	UIButton *nearbyPartiesButton;
}

@property (retain,nonatomic) IBOutlet UITextField *passwordField;
@property (retain,nonatomic) IBOutlet UIButton *nearbyPartiesButton;

- (IBAction) OnButtonClick:(id) sender;

@end
