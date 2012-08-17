//
//  PlayerViewController.m
//  UDJ
//
//  Created by Matthew Graf on 8/16/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "PlayerViewController.h"
#import "PlayerInfoViewController.h"

@interface PlayerViewController ()

@end

@implementation PlayerViewController

@synthesize playerNameLabel, playerInfoButton;
@synthesize songTitleLabel, artistLabel, albumLabel;
@synthesize timePassedLabel, timeLeftLabel;
@synthesize songPositionSlider, togglePlayButton, skipButton;
@synthesize volumeSlider;
@synthesize playerManager, globalData, managedObjectContext, playerID;

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
    
    self.playerManager = [[UDJPlayerManager alloc] init];
    NSLog(@"playerManager ID: %d", self.playerManager.playerID);
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear: animated];
    if(self.playerManager.playerID == -1){
        PlayerInfoViewController* viewController = [[PlayerInfoViewController alloc] initWithNibName: @"PlayerInfoViewController" bundle:[NSBundle mainBundle]];
        [self presentModalViewController: viewController animated: YES];  
        viewController.playerManager = self.playerManager;
    }
}


#pragma mark - Player info

-(IBAction)playerInfoButtonClick:(id)sender{
    PlayerInfoViewController* viewController = [[PlayerInfoViewController alloc] initWithNibName: @"PlayerInfoViewController" bundle:[NSBundle mainBundle]];
    [self presentModalViewController: viewController animated: YES];
    viewController.playerManager = self.playerManager;
}

@end
