//
//  PartySearchViewController.m
//  UDJ
//
//  Created by Matthew Graf on 12/25/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "PartySearchViewController.h"
#import "SearchingViewController.h"
#import "EventList.h"

@implementation PartySearchViewController
@synthesize searchButton, searchField;

- (IBAction) OnButtonClick:(id) sender {
	if(sender == searchButton){
        NSString* searchParam = searchField.text;
        [self.navigationController popViewControllerAnimated:NO];
        SearchingViewController* searchingViewController = [[SearchingViewController alloc] initWithNibName:@"SearchingViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:searchingViewController animated:YES];
        [[EventList sharedEventList] getEventsByName:searchParam];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


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

@end
