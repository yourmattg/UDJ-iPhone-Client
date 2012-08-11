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

@interface PlayerInfoViewController ()

@end

@implementation PlayerInfoViewController

@synthesize mainScrollView;
@synthesize textFieldArray;
@synthesize playerNameLabel;
@synthesize playerNameField, playerPasswordField;
@synthesize cancelButton;
@synthesize useLocationSwitch, addressField, cityField, stateField, zipCodeField, locationFields;
@synthesize createPlayerButton, playerStateLabel, playerStateSwitch;
@synthesize globalData, managedObjectContext, playerID, songSyncDictionary;
@synthesize activityView, activityLabel;

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
    [self.mainScrollView scrollRectToVisible: CGRectMake(0, yCoord-6, 320, 367) animated:YES];
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
    
    [self.mainScrollView setContentSize: CGSizeMake(320, 590)]; // 320, 367
    [self.mainScrollView scrollRectToVisible: CGRectMake(0, 8, 320, 367) animated:YES];
    self.mainScrollView.scrollEnabled = NO;
    
    [self.view addSubview: self.activityView];
    self.activityView.frame = CGRectMake(20, 420, 280, 32);
    
    [self initTextFields];
    
    self.globalData = [UDJData sharedUDJData];
    self.globalData.playerMethodsDelegate = self;
    
    UDJAppDelegate* appDelegate = (UDJAppDelegate*)[[UIApplication sharedApplication] delegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    [self loadPlayerInfo];
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

#pragma mark - Updating library

-(NSArray*)arrayWithAllLibraryEntries{
    NSError* error;
    //Set up a request to get the all library entries
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UDJStoredLibraryEntry" inManagedObjectContext:managedObjectContext]];
    NSArray* libraryEntryArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    if(error) {}
    return libraryEntryArray;
}

-(void)buildSyncDictionary{
    // build sync status dictionary
    NSArray* libraryEntryArray = [self arrayWithAllLibraryEntries];
    self.songSyncDictionary = [NSMutableDictionary dictionaryWithCapacity: [libraryEntryArray count]];
    for(int i=0; i<[libraryEntryArray count]; i++){
        UDJStoredLibraryEntry* libEntry = [libraryEntryArray objectAtIndex: i];
        [self.songSyncDictionary setObject: libEntry.synced forKey: libEntry.libraryID];
    }
}

-(NSMutableDictionary*)dictionaryForMediaItem:(MPMediaItem*)item{
    NSMutableDictionary* songDict = [NSMutableDictionary dictionaryWithCapacity: 7];
    
    NSString *title, *artist, *album, *genre;
    
    [songDict setObject: [item valueForKey: MPMediaItemPropertyPersistentID] forKey:@"id"];
    
    if([item valueForKey: MPMediaItemPropertyTitle] == nil) title = @"Untitled";
    else title = [item valueForKey: MPMediaItemPropertyTitle];
    [songDict setObject: title forKey:@"title"];
    
    if([item valueForKey: MPMediaItemPropertyArtist] == nil) artist = @"Unknown Artist";
    else artist = [item valueForKey: MPMediaItemPropertyArtist];
    [songDict setObject: artist forKey:@"artist"];
    
    if([item valueForKey: MPMediaItemPropertyAlbumTitle] == nil) album = @"Unknown Album";
    else album = [item valueForKey: MPMediaItemPropertyAlbumTitle];
    [songDict setObject: album forKey:@"album"];
    
    if([item valueForKey: MPMediaItemPropertyGenre] == nil) genre = @"";
    else genre = [item valueForKey: MPMediaItemPropertyGenre];
    [songDict setObject: genre forKey:@"genre"];
    
    [songDict setObject: [NSNumber numberWithInt: 0] forKey:@"track"];
        
    [songDict setObject: [item valueForKey: MPMediaItemPropertyPlaybackDuration] forKey:@"duration"];

    return songDict;
}

-(void)updatePlayerMusic{
    [self buildSyncDictionary];
    
    // get all songs from library
    MPMediaQuery* songQuery = [MPMediaQuery songsQuery];
    NSArray* songArray = [songQuery items];
    
    // song accumulator, used to send sets of 200 songs to server
    NSMutableArray* songAddArray = [NSMutableArray arrayWithCapacity: 201];

    // check each song in the library
    for(int i=0; i<[songArray count]; i++){
        MPMediaItem* mediaItem = [songArray objectAtIndex: i];
        
        // get this song's sync status
        NSString* libraryID = [mediaItem valueForKey: MPMediaItemPropertyPersistentID];
        NSNumber* syncStatus = [songSyncDictionary objectForKey: libraryID];
        
        // if this song hasn't been synced, add it to a set of songs to be added
        if(syncStatus == nil || [syncStatus boolValue] == NO){
            NSDictionary* songAddDict = [self dictionaryForMediaItem: mediaItem];
            [songAddArray addObject: songAddDict];
            
            // if we have 200 songs, send them off to the server
            if([songAddArray count] == 200 || i == [songArray count]-1){
                [self addSongsToServer: [songAddArray JSONString]];

                // verify that they were added before clearing 
                //[songAddArray removeAllObjects];
            }
        }
    }
}

-(void)addSongsToServer:(NSString*)songCollectionString{
    
    RKClient* client = [RKClient sharedClient];
    
    //create url users/user_id/players/player_id/library/songs
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingFormat: @"/users/%d/players/%d/library/songs", [globalData.userID intValue], self.playerID, nil];
    
    //set up request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate: self];
    request.method = RKRequestMethodPUT;
    request.queue = client.requestQueue;
    request.userData = @"songSetAdd";
    
    // set up the headers, including which type of request this is
    NSMutableDictionary* requestHeaders = [NSMutableDictionary dictionaryWithDictionary: [UDJData sharedUDJData].headers];
    [requestHeaders setValue:@"playerMethodsDelegate" forKey:@"delegate"];
    [requestHeaders setValue:@"text/json" forKey:@"content-type"];
    request.additionalHTTPHeaders = requestHeaders;
    
    // set body to the JSON song array
    [request setHTTPBody: [songCollectionString dataUsingEncoding: NSUTF8StringEncoding]];
    
    [request send];
}

-(IBAction)playerButton:(id)sender{
    [self updatePlayerMusic];
}


#pragma mark - Saving player to persistent store

-(void)savePlayerInfo{
    
    UDJStoredPlayer* storedPlayer;
    NSError* error;
    
    //Set up a request to get the last stored playlist
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UDJStoredPlayer" inManagedObjectContext:managedObjectContext]];
    storedPlayer = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    
    if (error) {
        // error in getting info
    }
    
    // if there was no stored player before, create it
    if (!storedPlayer) {
        storedPlayer = (UDJStoredPlayer*)[NSEntityDescription insertNewObjectForEntityForName:@"UDJStoredPlayer" inManagedObjectContext: managedObjectContext]; ;
    }
    
    // update the username, save the date the ticket was assigned
    [storedPlayer setName: self.playerNameField.text];
    [storedPlayer setAddress: self.addressField.text];
    [storedPlayer setCity: self.cityField.text];
    [storedPlayer setState: self.stateField.text];
    [storedPlayer setPassword: self.playerPasswordField.text];
    [storedPlayer setZipcode: self.zipCodeField.text];
    [storedPlayer setPlayerID: [NSNumber numberWithInt: self.playerID]];
    // 
    
    //Save the data
    error = nil;
    if (![managedObjectContext save:&error]) {
        //Handle any error with the saving of the context
    }
    
}

-(void)loadPlayerInfo{
    
    UDJStoredPlayer* storedPlayer;
    NSError* error;
    
    //Set up a request to get the last stored player
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UDJStoredPlayer" inManagedObjectContext:managedObjectContext]];
    storedPlayer = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    
    if (error) {
        // error in getting info
    }
    
    // if there was a stored player, fill in the fields
    if (storedPlayer) {
        [self.playerNameField setText: storedPlayer.name];
        [self.playerPasswordField setText: storedPlayer.password];
        [self.addressField setText: storedPlayer.address];
        [self.cityField setText: storedPlayer.city];
        [self.stateField setText: storedPlayer.state];
        [self.zipCodeField setText: storedPlayer.zipcode];
        self.playerID = [storedPlayer.playerID intValue];
        
        self.createPlayerButton.hidden = YES;
        self.playerStateLabel.hidden = NO;
        self.playerStateSwitch.hidden = NO;
    }
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
    NSInteger yPos = visible ? 370 : 420;
    self.activityView.frame = CGRectMake(20, yPos, 280, 32);
    [UIView commitAnimations];
}


#pragma mark - Player methods

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
    [requestHeaders setValue:@"playerMethodsDelegate" forKey:@"delegate"];
    [requestHeaders setValue:@"text/json" forKey:@"content-type"];
    request.additionalHTTPHeaders = requestHeaders;
    
    //send request
    [request send];
}

#pragma mark - Response handling

-(void)additionalPlayerSetup{
    self.playerStateLabel.hidden = NO;
    self.playerStateSwitch.hidden = NO;
    
    [self savePlayerInfo];
    
    [self.activityLabel setText: @"Updating music library"];
    [self updatePlayerMusic];
}

-(void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSLog(@"status code: %d", [response statusCode]);
    NSString* requestType = request.userData;
    
    if([requestType isEqualToString: @"createPlayer"] && [response statusCode] == 201){
        // Save player ID
        NSDictionary* responseDict = [response.bodyAsString objectFromJSONString];
        NSNumber* playerIDAsNumber = [responseDict objectForKey: @"player_id"];
        self.playerID = [playerIDAsNumber intValue];
        
        [self additionalPlayerSetup];
    }
    else if([requestType isEqualToString: @"songSetAdd"] && [response statusCode] == 201){
        NSLog(@"status code: %d", [response statusCode]);
        [self toggleActivityView: NO];
    }
}

@end
