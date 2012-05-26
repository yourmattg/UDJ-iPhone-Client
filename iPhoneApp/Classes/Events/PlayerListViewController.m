//
//  PlayerListViewController.m
//  UDJ
//
//  Created by Matthew Graf on 5/24/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "PlayerListViewController.h"

@interface PlayerListViewController ()

@end

@implementation PlayerListViewController

@synthesize eventData, tableList, tableView;
@synthesize statusLabel, globalData, currentRequestNumber;
@synthesize playerSearchBar, findNearbyButton, searchIndicatorView;


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
    
    self.tableList = [[NSMutableArray alloc] init];
    
    self.globalData = [UDJData sharedUDJData];
    
    // set up eventData and get nearby events
    self.eventData = [UDJEventData sharedEventData];
    self.eventData.getEventsDelegate = self;
    self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
    
    // initialize search bar
    playerSearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - UI Events
// Hide the keyboard when user hits return
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end
