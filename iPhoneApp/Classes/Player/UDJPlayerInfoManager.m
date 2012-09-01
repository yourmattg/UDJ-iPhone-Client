//
//  UDJPlayerInfoManager.m
//  UDJ
//
//  Created by Matthew Graf on 8/31/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJPlayerInfoManager.h"
#import "UDJStoredPlayer.h"
#import "UDJAppDelegate.h"
#import "UDJPlayer.h"
#import "UDJPlayerData.h"

@implementation UDJPlayerInfoManager

@synthesize playerID;
@synthesize playerName;
@synthesize playerPassword;
@synthesize stateLocation;
@synthesize city;
@synthesize zipCode;
@synthesize address;
@synthesize managedObjectContext;
@synthesize globalData;

#pragma mark - Initialization

static UDJPlayerInfoManager* _sharedPlayerInfoManager = nil;

+(UDJPlayerInfoManager*)sharedPlayerInfoManager{
    @synchronized([UDJPlayerInfoManager class]){
        if (!_sharedPlayerInfoManager)
            _sharedPlayerInfoManager = [[self alloc] init];        
        return _sharedPlayerInfoManager;
    }    
    return nil;
}

+(id)alloc{
    @synchronized([UDJPlayerInfoManager class]){
        NSAssert(_sharedPlayerManager == nil, @"Attempted to allocate a second instance of a singleton.");
        _sharedPlayerInfoManager = [super alloc];
        return _sharedPlayerInfoManager;
    }
    return nil;
}

-(id)init{
    if(self = [super init]){
        UDJAppDelegate* appDelegate = (UDJAppDelegate*)[[UIApplication sharedApplication] delegate];
        self.managedObjectContext = appDelegate.managedObjectContext;
        self.playerID = -1;
    }
    return self;
}


#pragma mark - Saving player to persistent store

// Saves the player information to the device
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
    [storedPlayer setName: self.playerName];
    [storedPlayer setAddress: self.address];
    [storedPlayer setCity: self.city];
    [storedPlayer setState: self.stateLocation];
    [storedPlayer setPassword: self.playerPassword];
    [storedPlayer setZipcode: self.zipCode];
    [storedPlayer setPlayerID: [NSNumber numberWithInt: self.playerID]];
    
    //Save the data
    error = nil;
    if (![managedObjectContext save:&error]) {
        //Handle any error with the saving of the context
    }
    
}

// Loads the player informatin from the device
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
        self.playerName = storedPlayer.name;
        self.playerPassword = storedPlayer.password;
        self.address = storedPlayer.address;
        self.city = storedPlayer.city;
        self.stateLocation = storedPlayer.state;
        self.zipCode = storedPlayer.zipcode;
        self.playerID = [storedPlayer.playerID intValue];
        
        [UDJPlayerManager sharedPlayerManager].playerID = self.playerID;
    }
}

#pragma mark - General player info

// Updates the global current player, so the rest of the app can make use of it
-(void)updateCurrentPlayer{
    UDJPlayer* player = [[UDJPlayer alloc] init];
    player.playerID = self.playerID;
    player.name = self.playerName;
    player.hostId = [globalData.userID intValue];
    player.hostUsername = globalData.username;
    [UDJPlayerData sharedPlayerData].currentPlayer = player;
}

-(void)updateInfoOnServer{
    // update password
    if([playerPassword isEqualToString:@""]) [self removePassword];
    else [self updatePassword];
}

#pragma mark - Password modification

-(void)removePassword{
    
}

-(void)updatePassword{
    RKRequest* request = [RKRequest UDJRequestWithMethod: RKRequestMethodPOST];
    request.delegate = self;
    // url 0_6/players/player_id/password
    NSString* urlString = [NSString stringWithFormat: @"%@/0_6/players/%d/password", [request.URL absoluteString], self.playerID];
    request.URL = [NSURL URLWithString: urlString];
    NSLog(urlString);
}

@end
