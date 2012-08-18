//
//  PlayerInfoViewController.h
//  UDJ
//
//  Created by Matthew Graf on 6/25/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestKit/RestKit.h"
#import "UDJData.h"
#import "UDJPlayerManager.h"

@interface PlayerInfoViewController : UIViewController <UITextFieldDelegate, RKRequestDelegate>

@property(nonatomic,strong) IBOutlet UIScrollView* mainScrollView;

@property(nonatomic,strong) IBOutletCollection(UITextField) NSArray* textFieldArray;

@property(nonatomic,strong) IBOutlet UILabel* playerNameLabel;

@property(nonatomic,strong) IBOutlet UITextField* playerNameField;
@property(nonatomic,strong) IBOutlet UITextField* playerPasswordField;

@property(nonatomic,strong) IBOutlet UIButton* closeButton;
@property(nonatomic,strong) IBOutlet UIButton* cancelButton;

@property(nonatomic,strong) IBOutlet UISwitch* useLocationSwitch;
@property(nonatomic,strong) IBOutletCollection(UITextField) NSArray* locationFields;
@property(nonatomic,strong) IBOutlet UITextField* addressField;
@property(nonatomic,strong) IBOutlet UITextField* cityField;
@property(nonatomic,strong) IBOutlet UITextField* stateField;
@property(nonatomic,strong) IBOutlet UITextField* zipCodeField;


@property(nonatomic,strong) IBOutlet UIButton* createPlayerButton;

@property(nonatomic,strong) IBOutlet UIView* activityView;
@property(nonatomic,strong) IBOutlet UILabel* activityLabel;

@property(nonatomic,strong) UDJPlayerManager* playerManager;
@property(nonatomic,strong) UDJData* globalData;
@property(nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property NSInteger playerID;
@property(nonatomic,strong) NSMutableDictionary* songSyncDictionary;

@property(nonatomic,weak) UIViewController* parentViewController;

-(void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response;

@end
