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

#import "UDJViewController.h"
#import "PlaylistViewController.h"
#import "UDJData.h"
#import "KeychainItemWrapper.h"
#import "UDJAppDelegate.h"
#import "PlayerListViewController.h"
#import "RestKit/Restkit.h"
#import "UDJClient.h"


@implementation UDJViewController

@synthesize loginButton, usernameField, passwordField, registerButton, currentRequestNumber, globalData, loginView, loginBackgroundView, cancelButton;

@synthesize managedObjectContext;

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
    
    
    UDJAppDelegate* appDelegate = (UDJAppDelegate*)[[UIApplication sharedApplication] delegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    [self checkForUsername];
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


#pragma mark Keychain methods

-(void)savePasswordToKeychain{
    KeychainItemWrapper* keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"UDJLoginData" accessGroup:nil];
    [keychain setObject: passwordField.text forKey: (__bridge id)kSecValueData];
}

-(void)saveUsernameAndDate{
    
    UDJStoredData* storedData;
    NSError* error;
    
    //Set up a request to get the last stored data
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UDJStoredData" inManagedObjectContext:managedObjectContext]];
    storedData = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    
    if (error) {
        // error in getting info
    }
    
    // if there was no stored data before, create it
    if (!storedData) {
        storedData = (UDJStoredData*)[NSEntityDescription insertNewObjectForEntityForName:@"UDJStoredData" inManagedObjectContext:managedObjectContext];  
    }
    
    // update the username, save the date the ticket was assigned
    [storedData setUsername: usernameField.text]; 
    NSDate* currentDate = [NSDate date];
    [storedData setTicketDate: currentDate];
    
    //Save the data
    error = nil;
    if (![managedObjectContext save:&error]) {
        //Handle any error with the saving of the context
    }
    
    // save password in keychain
    [self savePasswordToKeychain];
    
}

-(void)getPasswordFromKeychain:(NSString*)username{
    KeychainItemWrapper* keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"UDJLoginData" accessGroup:nil];
    
    NSString* password = [keychain objectForKey: (__bridge id)kSecValueData];

    usernameField.text = username;
    passwordField.text = password;
    
    [self sendAuthRequest:username password:password];
}

-(void)checkForUsername{
    
    UDJStoredData* storedData;
    NSError* error;
    
    //Set up a request to get the last info
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UDJStoredData" inManagedObjectContext:managedObjectContext]];
    
    // find last info
    storedData = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    
    if (error) {
        // error in getting info
    }
    
    // if there was a username,
    if (storedData) {
        [self getPasswordFromKeychain: storedData.username];
    }
}


#pragma mark Authenticate methods

-(void)genericErrorMessage{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"UDJ encountered a networking error. Make sure you have an internet connection or try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

// authenticate: sends a POST with the username and password
- (void) sendAuthRequest:(NSString*)username password:(NSString*)pass{
    // make sure the right api version is being passed in
    NSDictionary* nameAndPass = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", pass, @"password", nil];
    NSMutableURLRequest* request = [[UDJClient sharedClient] requestWithMethod:@"POST" path:@"/auth" parameters:nameAndPass];
    
    NSDictionary* headers = [NSDictionary dictionaryWithObjectsAndKeys:@"0.5", @"X-Udj-Api-Version", nil];
    [request setAllHTTPHeaderFields:headers];
    
    // TODO: request count?
    
    [self toggleLoginView:YES];

    [[UDJClient sharedClient] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation* operation, id responseObject){
        [self request:request didLoadResponse:operation];
    }failure:^(AFHTTPRequestOperation* operation, NSError* error){
        [self genericErrorMessage];
    }];
}

// handleAuth: handle authorization response if credentials are valid
- (void)handleAuth:(RKResponse*)response{
    
    // save the username, password, and ticket assign date information to Core Data
    [self saveUsernameAndDate];
    
    self.currentRequestNumber = [NSNumber numberWithInt: -1];
    
    // save our username and password
    globalData.username = usernameField.text;
    globalData.password = passwordField.text;
    
    // only handle if we are waiting for an auth response
    RKJSONParserJSONKit* parser = [RKJSONParserJSONKit new];
    NSDictionary* responseDict = [parser objectFromString:[response bodyAsString] error:nil];
    globalData.ticket=[responseDict valueForKey:@"ticket_hash"];
    globalData.userID=[[responseDict valueForKey:@"user_id"] stringValue];
        
    //TODO: may need to change userID to [userID intValue]
    globalData.headers = [NSDictionary dictionaryWithObjectsAndKeys:globalData.ticket, @"X-Udj-Ticket-Hash", nil];
        
    // load the player list view
    PlayerListViewController* viewController = [[PlayerListViewController alloc] initWithNibName:@"PlayerListViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)denyAuth:(RKResponse*)response{
    // hide the login view
    [self toggleLoginView:NO];
    
    if([response statusCode] == 401 || [response statusCode] == 404){
        //let user know their credentials were invalid
        UIAlertView* authNotification = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"The username or password you entered is invalid." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [authNotification show];        
    }
    
    if([response statusCode] == 501){
        //let user know they have to update
        UIAlertView* authNotification = [[UIAlertView alloc] initWithTitle:@"Needs Update" message:@"Your UDJ client is outdated. Please download the latest version." delegate: self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Update", nil];
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
    
    if(![username isEqualToString: @""] && ![password isEqualToString: @""]){
        [self sendAuthRequest:username password:password];
    }
}

// Send user to the register page
-(IBAction)registerButtonClick:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.udjplayer.com/registration/register/"]];
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
