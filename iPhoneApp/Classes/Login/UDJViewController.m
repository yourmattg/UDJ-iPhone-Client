//
//  UDJViewController.m
//  UDJ
//
//  Created by Matthew Graf on 9/24/11.
//  Copyright 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJViewController.h"
#import "PartyListViewController.h"
#import "UDJConnection.h"
#import "AuthenticateViewController.h"
#import "PlaylistViewController.h"

@implementation UDJViewController

@synthesize loginButton, usernameField, passwordField;

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
	[self.navigationController setNavigationBarHidden:NO];
	//self.navigationController.navigationBar.tintColor = [UIColor blackColor];
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


- (void)dealloc {
    [loginButton release];
    [usernameField release];
    [passwordField release];
    [super dealloc];
}


- (IBAction) OnButtonClick:(id) sender {
	// handle user's login attempt
    NSString* username = usernameField.text;
    NSString* password = passwordField.text;
    
	if(![username isEqualToString: @""] && ![password isEqualToString: @""])
	{
        // load waiting screen
        AuthenticateViewController* authenticateViewController = [[AuthenticateViewController alloc] initWithNibName:@"AuthenticateViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:authenticateViewController animated:NO];
        [authenticateViewController release];
        
        // attempt authorization
        [[UDJConnection sharedConnection] setCurrentController: self];
        [[UDJConnection sharedConnection] authenticate:username password: password];
        
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == usernameField || textField == passwordField) {
		[textField resignFirstResponder];
	}
	return NO;
}


@end
