//
//  PlayerInfoViewController.m
//  UDJ
//
//  Created by Matthew Graf on 6/25/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "PlayerInfoViewController.h"

@interface PlayerInfoViewController ()

@end

@implementation PlayerInfoViewController

@synthesize mainScrollView;
@synthesize textFieldArray;
@synthesize playerNameLabel;
@synthesize playerNameField, playerPasswordField;
@synthesize cancelButton;
@synthesize useLocationSwitch, addressField, cityField, stateField, zipCodeField;
@synthesize playerStateSwitch;
@synthesize createPlayerButton;
@synthesize globalData;

#pragma mark - Text fields

-(IBAction)cancelButtonClick:(id)sender{
    for(int i=0; i < [textFieldArray count]; i++){
        UITextField* textField= [textFieldArray objectAtIndex: i];
        [textField resignFirstResponder];
    }
}

-(void)initTextFields{
    for(int i=0; i < [textFieldArray count]; i++){
        UITextField* textField= [textFieldArray objectAtIndex: i];
        textField.delegate = self;
        textField.tag = i;
    }
}

-(void)textFieldDidBeginEditing:(UITextField*)textField{
    NSInteger yCoord = textField.frame.origin.y;
    [self.mainScrollView scrollRectToVisible: CGRectMake(0, yCoord-6, 320, 367) animated:YES];
    self.cancelButton.hidden = NO;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField == self.playerNameField){
        [playerNameLabel setText: self.playerNameField.text];
    }
    self.cancelButton.hidden = YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    // find the next text field
    NSInteger index = textField.tag + 1;
    UITextField* nextField;
    if(index < [textFieldArray count]) nextField = [textFieldArray objectAtIndex: index]; 
    else nextField = nil;
    
    // if this is the last enabled field, hide the keyboard
    if(!nextField || !nextField.enabled){
        [textField resignFirstResponder];
    }
    
    // set focus to the next field
    else{
        [nextField becomeFirstResponder];        
    }
    
    return NO;
}

#pragma mark - Address fields
/*
-(void)toggleAddressFields:(BOOL)showing{
    
    BOOL enabled = showing;
    addressField.enabled = enabled;
    cityField.enabled = enabled;
    zipCodeField.enabled = enabled;
    stateField.enabled = enabled;
    
    float alpha = enabled ? 1 : 0.5;
    addressField.alpha = alpha;
    cityField.alpha = alpha;
    zipCodeField.alpha = alpha;
    stateField.alpha = alpha; 
    
}*/

-(IBAction)locationSwitchValueChanged:(id)sender{
    //BOOL enabled = ![(UISwitch*)sender isOn];
    
    //[self toggleAddressFields: enabled];
}


#pragma mark - Player creation

-(IBAction)createButtonClick:(id)sender{
    
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //[self toggleAddressFields: NO];
    
    [self.mainScrollView setContentSize: CGSizeMake(320, 650)];
    
    [self initTextFields];
    
    globalData = [UDJData sharedUDJData];
    globalData.playerMethodsDelegate = self;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Player modification requests

-(void)sendCreatePlayerRequest{
    RKClient* client = [RKClient sharedClient];
    
    //create url [POST] {prefix}/udj/users/user_id/players/player_id/name
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingFormat:@"%@%d%@%@", @"/users/", [globalData.userID intValue], @"/players/", self.playerNameField.text, nil];
    
    //NSLog(urlString);
    
    /*
    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate: globalData];
    request.queue = client.requestQueue;
    request.method = RKRequestMethodPOST;
    request.additionalHTTPHeaders = globalData.headers;
    
    //send request
    [request send];
     */
}

#pragma mark - Response handling

-(void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response{
    
}

@end
