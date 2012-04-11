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
	UIButton *enterPartyButton;
    UILabel* eventNameLabel;
}

@property (strong,nonatomic) IBOutlet UITextField *passwordField;
@property (strong,nonatomic) IBOutlet UIButton *backButton;
@property (strong,nonatomic) IBOutlet UIButton *enterPartyButton;
@property(nonatomic,strong) IBOutlet UILabel* eventNameLabel;

- (IBAction) OnButtonClick:(id) sender;

@end
