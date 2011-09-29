//
//  UDJViewController.m
//  UDJ
//
//  Created by Matthew Graf on 9/24/11.
//  Copyright 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJViewController.h"
#import "PartyListViewController.h"

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


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


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
    [super dealloc];
}


- (IBAction) OnButtonClick:(id) sender {
	// this view will set our model data
	if(![usernameField.text isEqualToString: @""] && ![passwordField.text isEqualToString: @""])
	{
		PartyListViewController* partyListViewController = [[PartyListViewController alloc] initWithNibName:@"PartyListViewController" bundle:[NSBundle mainBundle]];
		[self.view addSubview:partyListViewController.view];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == usernameField || textField == passwordField) {
		[textField resignFirstResponder];
	}
	return NO;
}


@end
