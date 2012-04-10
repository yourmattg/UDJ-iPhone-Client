//
//  UDJViewController.m
//  UDJ
//
//  Created by Matthew Graf on 9/24/11.
//  Copyright 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJViewController.h"
#import "EventSearchViewController.h"
#import "UDJConnection.h"
#import "PlaylistViewController.h"
#import "UDJData.h"

@implementation UDJViewController

@synthesize loginButton, usernameField, passwordField, registerButton, currentRequestNumber, globalData, loginView, loginBackgroundView, cancelButton;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // bring the user to the UDJ app store page to update
    if([alertView.title isEqualToString:@"Needs Update"] && buttonIndex == 1){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.com/apps/udj"]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self.navigationController setNavigationBarHidden:YES];
    globalData = [UDJData sharedUDJData];
    
    // initialize login view
    loginBackgroundView.hidden = YES;
    loginView.layer.cornerRadius = 8;
    loginView.layer.borderColor = [[UIColor whiteColor] CGColor];
    loginView.layer.borderWidth = 3;
    
    // initialize text fields
    usernameField.placeholder = @"Username";
    passwordField.placeholder = @"Password";
    usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
    
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

// Show or hide the "logging in.." view; active = YES will show the view
-(void) toggleLoginView:(BOOL) active{
    loginBackgroundView.hidden = !active;
    loginButton.enabled = !active;
    registerButton.enabled = !active;
    usernameField.enabled = !active;
    passwordField.enabled = !active;
}


#pragma mark Authenticate methods

// authenticate: sends a POST with the username and password
- (void) sendAuthRequest:(NSString*)username password:(NSString*)pass{
    RKClient* client = [RKClient sharedClient];
    
    // make sure the right api version is being passed in
    NSDictionary* nameAndPass = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", pass, @"password", nil]; 
    
    // put the API version in the header
    NSDictionary* headers = [NSDictionary dictionaryWithObjectsAndKeys:@"0.2", @"X-Udj-Api-Version", nil];
    
    // create the URL
    NSMutableString* urlString = [NSMutableString stringWithString: client.baseURL];
    [urlString appendString: @"/auth"];
    
    // set up request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
    request.queue = client.requestQueue;
    request.params = nameAndPass;
    request.method = RKRequestMethodPOST;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++]; 
    request.additionalHTTPHeaders = headers;
    
    // remember the request we are waiting on
    self.currentRequestNumber = request.userData;
    
    [self toggleLoginView:YES];
    
    [request send];
    
}

// handleAuth: handle authorization response if credentials are valid
- (void)handleAuth:(RKResponse*)response{
    self.currentRequestNumber = [NSNumber numberWithInt: -1];
    
    // save our username and password
    globalData.username = usernameField.text;
    globalData.password = passwordField.text;
    
    // only handle if we are waiting for an auth response
    NSDictionary* headerDict = [response allHeaderFields];
    globalData.ticket=[headerDict valueForKey:@"X-Udj-Ticket-Hash"];
    globalData.userID=[headerDict valueForKey:@"X-Udj-User-Id"];
        
    //TODO: may need to change userID to [userID intValue]
    globalData.headers = [NSDictionary dictionaryWithObjectsAndKeys:globalData.ticket, @"X-Udj-Ticket-Hash", globalData.userID, @"X-Udj-User-Id", nil];
        
    // load the party list view
    EventSearchViewController* eventSearchViewController = [[EventSearchViewController alloc] initWithNibName:@"EventSearchViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:eventSearchViewController animated:YES];
}

-(void)denyAuth:(RKResponse*)response{
    // hide the login view
    [self toggleLoginView:NO];
    
    if([response statusCode] == 403){
        //let user know their credentials were invalid
        UIAlertView* authNotification = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"The username or password you entered is invalid." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [authNotification show];        
    }
    
    if([response statusCode] == 501){
        //let user know their credentials were invalid
        UIAlertView* authNotification = [[UIAlertView alloc] initWithTitle:@"Needs Update" message:@"It looks like your UDJ client is outdated. Please take a moment to download the latest version from the App Store." delegate: self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Update", nil];
        [authNotification show];        
    }
}

// When user presses cancel, hide login view and let controller know
// we aren't waiting on any requests
-(IBAction)cancelButtonClick:(id)sender{
    self.currentRequestNumber = [NSNumber numberWithInt: -1];
    [self toggleLoginView:NO];
}

// Send a login attempt if the user entered a name/pass
- (IBAction) OnButtonClick:(id) sender {
	// handle user's login attempt
    NSString* username = usernameField.text;
    NSString* password = passwordField.text;
    
	if(![username isEqualToString: @""] && ![password isEqualToString: @""])
	{
        [self sendAuthRequest:username password:password];
        
	}
}

// Send user to the register page
-(IBAction)registerButtonClick:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.udjevents.com/registration/register/"]];
}

// Hide the keyboard when user hits return
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == usernameField || textField == passwordField) {
		[textField resignFirstResponder];
	}
	return NO;
}

// Handle responses from the server
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSLog(@"status code %d", [response statusCode]);
    
    NSNumber* requestNumber = request.userData;
    
    if(![requestNumber isEqualToNumber: currentRequestNumber]) return;
    
    // check if the event has ended
    if(response.statusCode == 410){
        //[self resetToEventView];
    }
    else if([request isPOST]) {
        // If we got a response back from our authenticate request
        if([response isOK])
            [self handleAuth:response];
        else
            [self denyAuth:response];
    }
    
    self.currentRequestNumber = [NSNumber numberWithInt: -1];
}


@end
