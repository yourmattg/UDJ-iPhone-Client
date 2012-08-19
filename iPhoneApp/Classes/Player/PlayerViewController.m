//
//  PlayerViewController.m
//  UDJ
//
//  Created by Matthew Graf on 8/16/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "PlayerViewController.h"
#import "PlayerInfoViewController.h"
#import "UDJPlaylist.h"

@interface PlayerViewController ()

@end

@implementation PlayerViewController

@synthesize playerNameLabel, playerInfoButton;
@synthesize songTitleLabel, artistLabel, albumLabel;
@synthesize timePassedLabel, timeLeftLabel;
@synthesize songPositionSlider, togglePlayButton, skipButton;
@synthesize volumeSlider;
@synthesize playerManager, globalData, managedObjectContext, playerID;
@synthesize leaveButton;
@synthesize playerController, currentMediaItem;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.playerManager = [UDJPlayerManager sharedPlayerManager];
    
    //[playerNameLabel setText:[playerManager playerName]];
    
    
    [playerManager updateCurrentPlayer];
    [[UDJPlaylist sharedUDJPlaylist] sendPlaylistRequest];
    
    [playerManager changePlayerState: PlayerStatePaused];
    [playerManager updatePlayerMusic];
    
    self.playerController = [MPMusicPlayerController applicationMusicPlayer];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear: animated];
    if(self.playerManager.playerID == -1){
        PlayerInfoViewController* viewController = [[PlayerInfoViewController alloc] initWithNibName: @"PlayerInfoViewController" bundle:[NSBundle mainBundle]];
        [self presentModalViewController: viewController animated: YES];  
        viewController.playerManager = self.playerManager;
    }
}

#pragma mark - Play and pause

-(void)updateSongDisplay{
    // update the UI for current song
}

-(IBAction)playToggleClick:(id)sender{
    if(currentMediaItem == nil){
        unsigned long long mediaItemID;
        if(![UDJPlaylist sharedUDJPlaylist].currentSong && [[UDJPlaylist sharedUDJPlaylist] count] > 0) 
            [UDJPlaylist sharedUDJPlaylist].currentSong = [[UDJPlaylist sharedUDJPlaylist] songAtIndex:0];
        mediaItemID = [UDJPlaylist sharedUDJPlaylist].currentSong.librarySongId;
        
        NSLog(@"mediaItemID: %llu", mediaItemID);
        MPMediaPropertyPredicate* predicate = [MPMediaPropertyPredicate predicateWithValue: [NSNumber numberWithUnsignedLongLong:mediaItemID] forProperty:MPMediaItemPropertyPersistentID];
        MPMediaQuery* query = [[MPMediaQuery alloc] initWithFilterPredicates: [NSSet setWithObject: predicate]];
        self.currentMediaItem = [[query items] objectAtIndex: 0];
        [self.playerController setQueueWithQuery: query];
        [playerController play];
    }
    else{
        [playerController play];
    }
}

#pragma mark - Closing out of player

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        [self.navigationController popViewControllerAnimated: YES];
        [playerManager changePlayerState: PlayerStateInactive];
    }
}

-(IBAction)leaveButtonClick:(id)sender{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Player" message:@"Your player will become inactive if you leave this screen. Are you sure you want to leave?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Leave", nil];
    [alertView show];
}


#pragma mark - Player info

-(IBAction)playerInfoButtonClick:(id)sender{
    PlayerInfoViewController* viewController = [[PlayerInfoViewController alloc] initWithNibName: @"PlayerInfoViewController" bundle:[NSBundle mainBundle]];
    [self presentModalViewController: viewController animated: YES];
    viewController.playerManager = self.playerManager;
}

@end
