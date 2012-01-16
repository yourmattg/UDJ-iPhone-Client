//
//  LibrarySearchViewController.m
//  UDJ
//
//  Created by Matthew Graf on 12/6/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "LibrarySearchViewController.h"
#import "SearchingViewController.h"
#import "UDJConnection.h"
#import "UDJEventList.h"

@implementation LibrarySearchViewController

@synthesize searchField, searchButton;

- (IBAction) OnButtonClick:(id) sender {
	if(sender==searchButton){
        NSString* searchParam = searchField.text;
        NSInteger eventIdParam = [UDJEventList sharedEventList].currentEvent.eventId;
        NSInteger maxResultsParam = 100;
        // show the searching screen
        SearchingViewController* searchingViewController = [[SearchingViewController alloc] initWithNibName:@"SearchingViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:searchingViewController animated:NO];
        [[UDJConnection sharedConnection] setCurrentController:searchingViewController];
        [searchingViewController release];
        // have UDJConnection send a request
        [[UDJConnection sharedConnection] sendLibSearchRequest:searchParam eventId:eventIdParam maxResults:maxResultsParam];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];    
    // Release any cached data, images, etc that aren't in use.
}

-(void)backToPlaylist{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    // set up back to playlist button
    UIBarButtonItem *playlistButton = [[UIBarButtonItem alloc] initWithTitle:@"Playlist" style:UIBarButtonItemStylePlain target:self action:@selector(backToPlaylist)];
    self.navigationItem.leftBarButtonItem = playlistButton;
    [playlistButton release];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// makes the keyboard disappear
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == searchField) {
		[textField resignFirstResponder];
	}
	return NO;
}

@end
