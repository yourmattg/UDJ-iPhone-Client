//
//  PartySearchViewController.m
//  UDJ
//
//  Created by Matthew Graf on 12/25/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "PartySearchViewController.h"
#import "SearchingViewController.h"
#import "UDJEventList.h"

@implementation PartySearchViewController
@synthesize searchButton, searchField, findNearbyButton;

// textFieldShouldReturn: hide keyboard when user is done with it
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
	return NO;
}

// check if this is a valid query
-(BOOL) isValidSearchQuery:(NSString*)string{
    NSCharacterSet *alphaSet = [NSCharacterSet alphanumericCharacterSet];
    NSString* testString = [NSString stringWithString: string];
    testString = [testString stringByReplacingOccurrencesOfString:@" " withString:@""];
    BOOL valid = [[testString stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""];
    return valid;
}

- (IBAction) OnButtonClick:(id) sender {
	if(sender == searchButton || sender == findNearbyButton){
        NSString* searchParam = searchField.text;
        if(sender == searchButton && ![self isValidSearchQuery:searchParam]){
            UIAlertView* invalidSearchParam = [[UIAlertView alloc] initWithTitle:@"Invalid Query" message:@"Your search query can only contain alphanumeric characters. This includes A-Z, 0-9." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [invalidSearchParam show];
            return;
        }
        
        // show the "searching..." view
        UINavigationController* navigationController = self.navigationController;
        [navigationController popViewControllerAnimated:NO];
        SearchingViewController* searchingViewController = [[SearchingViewController alloc] initWithNibName:@"SearchingViewController" bundle:[NSBundle mainBundle]];
        [navigationController pushViewController:searchingViewController animated:NO];
        
        // send the search request
        if(sender==searchButton) [[UDJEventList sharedEventList] getEventsByName:searchParam];
        else [[UDJEventList sharedEventList] getNearbyEvents];
        [navigationController popViewControllerAnimated:YES];
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
