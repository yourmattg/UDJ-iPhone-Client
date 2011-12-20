//
//  UDJConnection.m
//  UDJ
//
//  Created by Matthew Graf on 12/13/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJConnection.h"

static UDJConnection* sharedUDJConnection = nil;

@implementation UDJConnection

@synthesize serverPrefix, ticket, client;

#pragma mark Singleton Methods
// allows UDJConnection to be used anywhere in the  application
+ (id)sharedConnection {
    @synchronized(self) {
        if (sharedUDJConnection == nil)
            sharedUDJConnection = [[self alloc] init];
    }
    return sharedUDJConnection;
}
// this creates the RKClient and sets its base URL to 'prefix'
- (void) initWithServerPrefix:(NSString *)prefix{
    client = [RKClient clientWithBaseURL:prefix];
}

// sends a POST with the username and password
- (void) authenticate:(NSString*)username password:(NSString*)pass{
    // make sure the right api version is being passed in
    NSDictionary* nameAndPass = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", pass, @"password", @"0.2", @"udj_api_version", nil]; 
    [client post:@"/auth" params:nameAndPass delegate:self];
    NSLog(@"attemping to authenticate");
}

// handles responses from the server
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSLog(@"Got a response from the server");
    if ([request isGET]) {
        // Handling GET /foo.xml
        
        if([response isOK]) {
            // Success! Let's take a look at the data
            NSLog(@"Retrieved XML: %@", [response bodyAsString]);
        }
        
    } else if([request isPOST]) {
        
        // Handling POST /other.json
        if([response isJSON]) {
            NSLog(@"Got a JSON response back from our POST!");
        }
        else if([response isOK]) {
            NSLog(@"Retrieved XML from our POST: %@", [response bodyAsString]);
        }
        // Handle
    } else if([request isDELETE]) {
        
        // Handling DELETE /missing_resource.txt
        if([response isNotFound]) {
            NSLog(@"The resource path '%@' was not found.", [request resourcePath]);
        }
    }
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
    [serverPrefix release];
    [ticket release];
    [client release];
}

@end
