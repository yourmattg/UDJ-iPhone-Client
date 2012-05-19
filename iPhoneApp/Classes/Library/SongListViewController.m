//
//  SongListViewController.m
//  UDJ
//
//  Created by Matthew Graf on 5/18/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "SongListViewController.h"
#import "RestKit/RestKit.h"

@implementation SongListViewController

@synthesize statusLabel, searchIndicatorView, currentRequestNumber;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Search request methods

-(void)getSongsByArtist:(NSString *)artist{
    // /udj/players/player_id/available_music/artists/artist_name
    
    // update the status label
    statusLabel.text = [NSString stringWithFormat: @"Getting songs by %@", artist, nil];
    [statusLabel sizeToFit];
}

-(void)getSongsByQuery:(NSString *)query{
    
}

#pragma mark - Response handling

// Handle responses from the server
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response { 
    
    NSLog(@"status code %d", [response statusCode]);
    
    NSNumber* requestNumber = request.userData;
    NSDictionary* headerDict = [response allHeaderFields];
    
    if(![requestNumber isEqualToNumber: currentRequestNumber]) return;
    
    // check if player has ended
    if(response.statusCode == 404){
        if([[headerDict objectForKey: @"X-Udj-Missing-Resource"] isEqualToString:@"player"]){}
        //[self resetToPlayerResultView];
    }
    else if ([request isGET] && [response isOK]) {
              
    }
    
    //self.currentRequestNumber = [NSNumber numberWithInt: -1];
}

@end
