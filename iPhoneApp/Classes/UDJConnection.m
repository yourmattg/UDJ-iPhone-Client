//
//  UDJConnection.m
//  UDJ
//
//  Created by Matthew Graf on 12/13/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJConnection.h"

@implementation UDJConnection

@synthesize serverPrefix, ticket, client;

// this creates the RKClient and sets its base URL to 'prefix'
- (void) initWithServerPrefix:(NSString *)prefix{
    client = [RKClient clientWithBaseURL:prefix];
}

// sends a POST request with the username and password
- (void) authenticate:(NSString*)username password:(NSString*)pass{
    NSDictionary* nameAndPass = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", pass, @"password", nil]; 
    [client post:@"/auth" params:nameAndPass delegate:self];
}

// handles responses from the server
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    if ([request isGET]) {
        // Handling GET /foo.xml
        
        if ([response isOK]) {
            // Success! Let's take a look at the data
            NSLog(@"Retrieved XML: %@", [response bodyAsString]);
        }
        
    } else if ([request isPOST]) {
        
        // Handling POST /other.json
        if ([response isJSON]) {
            NSLog(@"Got a JSON response back from our POST!");
        }
        
    } else if ([request isDELETE]) {
        
        // Handling DELETE /missing_resource.txt
        if ([response isNotFound]) {
            NSLog(@"The resource path '%@' was not found.", [request resourcePath]);
        }
    }
}

@end
