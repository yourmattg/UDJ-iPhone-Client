//
//  PlayerInfoViewController.m
//  UDJ
//
//  Created by Matthew Graf on 6/25/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "PlayerInfoViewController.h"
#import "JSONKit.h"
#import "UDJAppDelegate.h"
#import "UDJStoredPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UDJStoredLibraryEntry.h"
#import "PlayerListViewController.h"
#import <objc/runtime.h>

@interface PlayerInfoViewController ()

@end

@implementation PlayerInfoViewController

@synthesize mainScrollView;
@synthesize textFieldArray;
@synthesize playerNameLabel;
@synthesize playerNameField, playerPasswordField;
@synthesize cancelButton, closeButton;
@synthesize useLocationSwitch, addressField, cityField, stateField, zipCodeField, locationFields;
@synthesize createPlayerButton;
@synthesize globalData, managedObjectContext, playerID, songSyncDictionary;
@synthesize activityView, activityLabel;
@synthesize playerManager;
@synthesize parentViewController;

#pragma mark - Text fields

-(IBAction)cancelButtonClick:(id)sender{
    for(int i=0; i < [textFieldArray count]; i++){
        UITextField* textField= [textFieldArray objectAtIndex: i];
        [textField resignFirstResponder];
    }
    [self.mainScrollView scrollRectToVisible: CGRectMake(0, 0, 320, 367) animated:YES];
    self.mainScrollView.scrollEnabled = NO;
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
    [self.mainScrollView scrollRectToVisible: CGRectMake(0, yCoord+10, 320, 367) animated:YES];
    self.cancelButton.hidden = NO;
    self.mainScrollView.scrollEnabled = YES;
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
        [self.mainScrollView scrollRectToVisible: CGRectMake(0, 0, 320, 367) animated:YES];
        self.mainScrollView.scrollEnabled = NO;
    }
    
    // set focus to the next field
    else{
        [nextField becomeFirstResponder];        
    }
    
    return NO;
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
    
    [self.mainScrollView setContentSize: CGSizeMake(320, 630)]; // 320, 367
    [self.mainScrollView scrollRectToVisible: CGRectMake(0, 8, 320, 367) animated:YES];
    self.mainScrollView.scrollEnabled = NO;
    
    [self.view addSubview: self.activityView];
    self.activityView.frame = CGRectMake(20, 470, 280, 32);
    
    [self initTextFields];
    
    self.globalData = [UDJData sharedUDJData];
    self.globalData.playerCreateDelegate = self;
    self.playerManager = [UDJPlayerManager sharedPlayerManager];
    
    UDJAppDelegate* appDelegate = (UDJAppDelegate*)[[UIApplication sharedApplication] delegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    [self updatePlayerInfo];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.globalData.playerCreateDelegate = nil;
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

#pragma mark - Saving player to persistent store

-(void)savePlayerInfo{
    // update the player manager
    [playerManager setPlayerName: self.playerNameField.text];
    [playerManager setAddress: self.addressField.text];
    [playerManager setCity: self.cityField.text];
    [playerManager setStateLocation: self.stateField.text];
    [playerManager setPlayerPassword: self.playerPasswordField.text];
    [playerManager setZipCode: self.zipCodeField.text];
    [playerManager setPlayerID: self.playerID];
    
    [playerManager savePlayerInfo];
}

-(void)updatePlayerInfo{
    [playerManager loadPlayerInfo];
    
    // if there was a stored player, fill in the fields
    if (playerManager.playerID != -1) {
        [self.playerNameField setText: playerManager.playerName];
        [self.playerPasswordField setText: playerManager.playerPassword];
        [self.addressField setText: playerManager.address];
        [self.cityField setText: playerManager.city];
        [self.stateField setText: playerManager.stateLocation];
        [self.zipCodeField setText: playerManager.zipCode];
        self.playerID = playerManager.playerID;
        
        [playerNameLabel setText: playerManager.playerName];
        self.createPlayerButton.hidden = YES;
    }
}

#pragma mark - Navigation

-(IBAction)closeButtonClick:(id)sender{
    [self dismissModalViewControllerAnimated: YES];
}



#pragma mark - Player methods helpers

-(BOOL)completedLocationFields{
    BOOL complete = YES;
    for(int i=0; i < [locationFields count]; i++){
        UITextField* textField = [locationFields objectAtIndex: i];
        NSString* textWithoutSpaces = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if([textWithoutSpaces isEqualToString:@""]) complete = NO;
    }
    
    return complete;
}

-(NSString*)JSONStringWithPlayerInfo{    
    // create dictionary with name/pass
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithCapacity: 3];
    [dict setValue: self.playerNameField.text forKey:@"name"];
    if(![self.playerPasswordField.text isEqualToString:@""])
        [dict setValue:self.playerPasswordField.text forKey:@"password"];
    
    // create location dictionary
    NSMutableDictionary* locationDict = [[NSMutableDictionary alloc] initWithCapacity: 4];
    [locationDict setValue:self.addressField.text forKey:@"address"];
    [locationDict setValue:self.cityField.text forKey:@"city"];
    [locationDict setValue:self.stateField.text forKey:@"state"];
    [locationDict setValue:self.zipCodeField.text forKey:@"zipcode"];
    [dict setObject: locationDict forKey: @"location"];
    
    return [dict JSONString];
}

-(void)toggleActivityView:(BOOL)visible{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.5];
    NSInteger yPos = visible ? 420 : 470;
    self.activityView.frame = CGRectMake(20, yPos, 280, 32);
    [UIView commitAnimations];
}


#pragma mark - Creating player


-(IBAction)createButtonClick:(id)sender{
    if([self completedLocationFields]){
        [self sendCreatePlayerRequest];
        self.createPlayerButton.hidden = YES;
        
        for(int i=0; i < [textFieldArray count]; i++){
            UITextField* textField= [textFieldArray objectAtIndex: i];
            [textField resignFirstResponder];
        }
        
        [self.mainScrollView scrollRectToVisible: CGRectMake(0, 0, 320, 367) animated:YES];
        self.mainScrollView.scrollEnabled = NO;
        
        [self.activityLabel setText: @"Creating player"];
        [self toggleActivityView: YES];
    }
    else{
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Incomplete Location" message:@"You must complete all the address fields." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

-(void)sendCreatePlayerRequest{
    RKClient* client = [RKClient sharedClient];
    
    //create url [POST] {prefix}/udj/users/user_id/players/player_id/name
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingFormat:@"%@%d%@", @"/users/", [globalData.userID intValue], @"/players/player", nil];

    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate: self.globalData];
    request.queue = client.requestQueue;
    request.method = RKRequestMethodPUT;
    request.HTTPBodyString = [self JSONStringWithPlayerInfo];
    request.userData = [NSString stringWithString: @"createPlayer"];
    
    // set up the headers, including which type of request this is
    NSMutableDictionary* requestHeaders = [NSMutableDictionary dictionaryWithDictionary: [UDJData sharedUDJData].headers];
    [requestHeaders setValue:@"playerCreateDelegate" forKey:@"delegate"];
    [requestHeaders setValue:@"text/json" forKey:@"content-type"];
    request.additionalHTTPHeaders = requestHeaders;
    
    //send request
    [request send];
}

#pragma mark - Response handling

-(void)additionalPlayerSetup{
    
    [self savePlayerInfo];
    
    // start using the new player
    PlayerListViewController* playerListViewController = (PlayerListViewController*)self.parentViewController;
    playerListViewController.shouldShowMyPlayer = YES;
    [self dismissModalViewControllerAnimated: YES];
}

-(void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSString* requestType = request.userData;
    
    if([requestType isEqualToString: @"createPlayer"]){
        if([response statusCode] == 201){
            // Save player ID
            NSDictionary* responseDict = [response.bodyAsString objectFromJSONString];
            NSNumber* playerIDAsNumber = [responseDict objectForKey: @"player_id"];
            self.playerID = [playerIDAsNumber intValue];
            
            [self additionalPlayerSetup];            
        }
        else if([response statusCode] == 409){
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Player Name Taken" message:@"Sorry, but there is already a player with this name!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            [self toggleActivityView: NO];
            self.createPlayerButton.hidden = NO;
        }
    }
}

@end
