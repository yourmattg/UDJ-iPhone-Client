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
#import <objc/runtime.h>

typedef enum {
    PlayerStateInactive,
    PlayerStatePlaying,
    PlayerStatePaused
} PlayerState;

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
    
    NSLog(@"Loaded %d library entries from store", [libraryEntryArray count]);
    
    if(error) {}
    return libraryEntryArray;
}

-(void)buildSyncDictionary{
    // build sync status dictionary
    NSArray* libraryEntryArray = [self arrayWithAllLibraryEntries];
    NSInteger dictionarySize = [libraryEntryArray count] == 0 ? 200 : [libraryEntryArray count];
    self.songSyncDictionary = [NSMutableDictionary dictionaryWithCapacity: dictionarySize];
    for(int i=0; i<[libraryEntryArray count]; i++){
        UDJStoredLibraryEntry* libEntry = [libraryEntryArray objectAtIndex: i];
        [self.songSyncDictionary setObject: libEntry.synced forKey: [NSNumber numberWithUnsignedLongLong: [libEntry.libraryID unsignedLongLongValue]]];
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

-(void)deletePreviousLibraryEntries{
    // Fetch and delete all previous entries
    NSError* error;
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UDJStoredLibraryEntry" inManagedObjectContext:managedObjectContext]];
    NSArray* storedEntryArray = [managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"Deleting %d stored library entires", [storedEntryArray count]);
    for(int i=0; i <[storedEntryArray count]; i++){
        UDJStoredLibraryEntry* entry = [storedEntryArray objectAtIndex: i];
        [managedObjectContext deleteObject: entry];
    }
    [managedObjectContext save: &error];
    if(error) NSLog(@"error");
}

-(void)saveLibraryEntries{  
    [self deletePreviousLibraryEntries];
    
    NSLog(@"about to save %d library entries (from songSyncDictionary)", [songSyncDictionary count]);
    NSArray* keyArray = [self.songSyncDictionary allKeys];
    for(int i=0; i<[keyArray count]; i++){
        NSNumber* entryID = [keyArray objectAtIndex: i];
        UDJStoredLibraryEntry* entry = (UDJStoredLibraryEntry*)[NSEntityDescription insertNewObjectForEntityForName:@"UDJStoredLibraryEntry" inManagedObjectContext:managedObjectContext];  
        // TODO: need to fix persistent store type
        NSNumber* number = [[NSNumber alloc] initWithUnsignedLongLong: [entryID unsignedLongLongValue]];
        [entry setSynced: [self.songSyncDictionary objectForKey: number]];
        //[entry setSynced: [self.songSyncDictionary objectForKey: entryID]];
        [entry setLibraryID: number];
    }
    
    NSError* error;
    [managedObjectContext save: &error];
}

-(void)updatePlayerMusic{
    
    if(self.activityView.frame.origin.y == 420) 
        [self toggleActivityView: YES];
    
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
        NSNumber* libraryID = [mediaItem valueForKey: MPMediaItemPropertyPersistentID];
        NSNumber* number = [NSNumber numberWithUnsignedLongLong: [libraryID unsignedLongLongValue]];
        NSNumber* syncStatus = [songSyncDictionary objectForKey: number]; //objectForKey: libraryID
        
        // if this song hasn't been synced, add it to a set of songs to be added
        if(syncStatus == nil || [syncStatus boolValue] == NO){
            NSDictionary* songAddDict = [self dictionaryForMediaItem: mediaItem];
            [songAddArray addObject: songAddDict];
            
            //if(syncStatus == nil) NSLog(@"new ID: %llu", [libraryID unsignedLongLongValue]);
            
            // mark the song as synced initially (we'll mark it as unsynced in the case of a 409)
            [songSyncDictionary setObject: [NSNumber numberWithBool: YES] forKey:number];
            
            // if we have 200 songs, send them off to the server
            // TODO: change 50 to 200
            if([songAddArray count] == 200 || i == [songArray count]-1){
                NSLog(@"Sending %d songs to server", [songAddArray count]);
                RKResponse* response = [self addSongsToServer: [songAddArray JSONString]];

                // if there were conflicts, mark those songs as unsynced
                if([response statusCode] == 409){
                    NSArray* songConflictArray = [[response bodyAsString] objectFromJSONString];
                    NSLog(@"%d conflicts", [songConflictArray count]);
                    for(int i=0; i<[songConflictArray count]; i++){
                        [songSyncDictionary setObject: [NSNumber numberWithBool: NO] forKey: [songConflictArray objectAtIndex: i]];
                    }
                }
                else if([response statusCode] == 201) NSLog(@"%d songs added", [songAddArray count]);
                [songAddArray removeAllObjects];
            }
        }
    }
    
    [self saveLibraryEntries];
    [self toggleActivityView: NO];
}

-(RKResponse*)addSongsToServer:(NSString*)songCollectionString{
    
    RKClient* client = [RKClient sharedClient];
    
    //create url users/user_id/players/player_id/library/songs
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingFormat: @"/0_6/players/%d/library/songs", self.playerID, nil];
    
    //set up request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate: self.globalData];
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
    
    return [request sendSynchronously];
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
        
        [playerNameLabel setText: storedPlayer.name];
        self.createPlayerButton.hidden = YES;
        self.playerStateLabel.hidden = NO;
        self.playerStateSwitch.hidden = NO;
        
        [NSThread detachNewThreadSelector:@selector(updatePlayerMusic) toTarget:self withObject:nil];
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

-(void)sendPlayerStateRequest:(PlayerState)newState{
    RKClient* client = [RKClient sharedClient];
    
    //create url [POST] {prefix}/udj/0_6/players/player_id/state
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingFormat:@"%@%d%@", @"/0_6/players/", self.playerID, @"/state", nil];
    
    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate: self.globalData];
    request.queue = client.requestQueue;
    request.method = RKRequestMethodPOST;
    request.userData = [NSString stringWithString: @"changeState"];
    
    // set up the headers, including which type of request this is
    NSMutableDictionary* requestHeaders = [NSMutableDictionary dictionaryWithDictionary: globalData.headers];
    [requestHeaders setValue:@"playerMethodsDelegate" forKey:@"delegate"];
    request.additionalHTTPHeaders = requestHeaders;
    
    // include state parameter
    NSArray* stateArray = [NSArray arrayWithObjects:@"inactive", @"playing", @"paused", nil];
    request.params = [NSDictionary dictionaryWithObjectsAndKeys: [stateArray objectAtIndex: newState], @"state", nil];
    
    //send request
    [request send];
}

-(IBAction)playerStateValueChanged:(id)sender{
    UISwitch* stateSwitch = sender;
    PlayerState newState = stateSwitch.on ? PlayerStatePlaying : PlayerStateInactive;
    [self sendPlayerStateRequest: newState];
}

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
    [NSThread detachNewThreadSelector:@selector(updatePlayerMusic) toTarget:self withObject:nil];
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
    else if([requestType isEqualToString: @"songSetAdd"] && [response statusCode] == 201){
        //[self toggleActivityView: NO];
    }
    else if([requestType isEqualToString: @"changeState"] && [response isOK]){
        NSLog(@"Changed state");
    }
}

@end
