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

#import "UDJData.h"
#import "UDJStoredData.h"
#import "UDJAppDelegate.h"

@implementation UDJData

@synthesize requestCount, ticket, headers, userID, username, password, loggedIn, managedObjectContext;


#pragma mark - Ticket validation

-(BOOL)ticketIsValid{
    
    UDJStoredData* storedData;
    NSError* error;
    
    //Set up a request to get the stored data
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UDJStoredData" inManagedObjectContext:managedObjectContext]];
    storedData = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    
    if (error) {
        // error in getting info
    }
    
    // if there we had previous data
    if (storedData) {
        NSDate* currentDate = [NSDate date];
        NSDate* lastDate = [storedData ticketDate];
        float secondsSince = [currentDate timeIntervalSinceDate: lastDate];
        float hoursSince = secondsSince/60/60;
        
        // if it has been more than 20 hours, we'll renew the ticket to be safe
        if(hoursSince >= 20){
            return NO;
        }
        
        // otherwise this ticket is valid (at least for the next 4 hours)
        else return YES;
    }
    
    // If there is no data that means we've never logged in,
    // meaning the user is about to log in and get a ticket.
    // So don't worry about it and consider it valid
    
    return YES;
}

-(void)renewTicket{
    
    if(self.username == nil) return;
    
    RKClient* client = [RKClient sharedClient];
    
    // make sure the right api version is being passed in
    NSDictionary* nameAndPass = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", password, @"password", nil]; 
    
    // put the API version in the header
    NSDictionary* apiHeader = [NSDictionary dictionaryWithObjectsAndKeys:@"0.2", @"X-Udj-Api-Version", nil];
    
    // create the URL
    NSMutableString* urlString = [NSMutableString stringWithString: client.baseURL];
    [urlString appendString: @"/auth"];
    
    // set up request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
    request.queue = client.requestQueue;
    request.params = nameAndPass;
    request.method = RKRequestMethodPOST;
    request.additionalHTTPHeaders = apiHeader;

    [request send];    
}

-(void)handleRenewTicket:(RKResponse*)response{
    if([response isOK]){
        NSLog(@"successfully renewed ticket");
        // create a new dictionary for our ticket and user id
        NSDictionary* headerDict = [response allHeaderFields];
        self.ticket=[headerDict valueForKey:@"X-Udj-Ticket-Hash"];
        self.userID=[headerDict valueForKey:@"X-Udj-User-Id"];
        
        //TODO: may need to change userID to [userID intValue]
        self.headers = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.ticket, @"X-Udj-Ticket-Hash", self.userID, @"X-Udj-User-Id", nil];
    }
    else{
        NSLog(@"couldnt renew ticket, trying again");
        [self renewTicket];
    }
}


// Handle responses from the server
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSLog(@"status code %d", [response statusCode]);
    
    if([request isPOST]) {
        [self handleRenewTicket:response];
    }
}


#pragma mark Singleton methods
static UDJData* _sharedUDJData = nil;

+(UDJData*)sharedUDJData{
	@synchronized([UDJData class]){
		if (!_sharedUDJData){
			_sharedUDJData = [[self alloc] init]; 
    
        }
		return _sharedUDJData;
	}    
	return nil;
}

+(id)alloc{
	@synchronized([UDJData class]){
		NSAssert(_sharedUDJData == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedUDJData = [super alloc];
		return _sharedUDJData;
	}
	return nil;
}

-(id)init{
    if(self = [super init]){
        UDJAppDelegate* appDelegate = (UDJAppDelegate*)[[UIApplication sharedApplication] delegate];
        self.managedObjectContext = [appDelegate managedObjectContext];
    }
    return self;
}

@end
