//
//  PartyLoginViewController.m
//  UDJ
//
//  Created by Matthew Graf on 9/24/11.
//  Copyright 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "PartyLoginViewController.h"
#import	 "PartyListViewController.h"


@implementation PartyLoginViewController

@synthesize passwordField, nearbyPartiesButton;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
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
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == passwordField) {
		[textField resignFirstResponder];
	}
	return NO;
}

//when a button is clicked
- (IBAction) OnButtonClick:(id) sender {
	// this view will set our model data
	if(sender==nearbyPartiesButton)
	{
		PartyListViewController* partyListViewController = [[PartyListViewController alloc] initWithNibName:@"PartyListViewController" bundle:[NSBundle mainBundle]];
		[self.view addSubview:partyListViewController.view];
	}
}


@end
