/**
 * Copyright 2011 Matthew M. Graf
 *
 * This file is part of UDJ.
 *
 * UDJ is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * UDJ is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with UDJ.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "PartyLoginViewController.h"
#import	"EventSearchViewController.h"
#import "PlaylistViewController.h"
#import "UDJEventData.h"


@implementation PartyLoginViewController

@synthesize passwordField, backButton, enterPartyButton, eventNameLabel;

/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */



 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
     [super viewDidLoad];
     eventNameLabel.text = [UDJEventData sharedEventData].currentEvent.name;
 }
 


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



- (void) viewDidAppear:(BOOL)animated{
    eventNameLabel.text = [UDJEventData sharedEventData].currentEvent.name;
}

- (IBAction) OnButtonClick:(id) sender {
	//pop this view to go back to nearby parties view
	if(sender == backButton) [self.navigationController popViewControllerAnimated:YES];
	//do something when user attempts to enter party
	else if(sender == enterPartyButton) {
		//authentication would go here
		if(![passwordField.text isEqualToString: @""]){
			PlaylistViewController* playlistViewController = [[PlaylistViewController alloc] initWithNibName:@"NewPlaylistViewController" bundle:[NSBundle mainBundle]];
			[self.navigationController pushViewController:playlistViewController animated:YES];
		}
	}
}

//this hides the keyboard when the user is done with a textfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == passwordField) {
		[textField resignFirstResponder];
	}
	return NO;
}


@end
