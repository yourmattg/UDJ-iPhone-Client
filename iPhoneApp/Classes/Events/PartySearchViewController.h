//
//  PartySearchViewController.h
//  UDJ
//
//  Created by Matthew Graf on 12/25/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PartySearchViewController : UIViewController{
    UIButton* searchButton;
    UITextField* searchField;
    UIButton* findNearbyButton;
}

- (IBAction) OnButtonClick:(id) sender;

@property(nonatomic,retain) IBOutlet UIButton* searchButton;
@property(nonatomic,retain) IBOutlet UITextField* searchField;
@property(nonatomic,retain) IBOutlet UIButton* findNearbyButton;

@end
