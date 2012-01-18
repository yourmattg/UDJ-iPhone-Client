//
//  UDJEventGoer.m
//  UDJ
//
//  Created by Matthew Graf on 1/18/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJEventGoer.h"

@implementation UDJEventGoer

@synthesize eventGoerId, userName, lastName, firstName, loggedIn;

+ (id) eventGoerFromDictionary:(NSDictionary *)eventGoerDict{
    if([eventGoerDict count]==0) return nil;
    UDJEventGoer* eventGoer = [UDJEventGoer new];
    eventGoer.eventGoerId = [[eventGoerDict objectForKey:@"id"] intValue];
    eventGoer.userName = [eventGoerDict objectForKey:@"username"];
    eventGoer.firstName = [eventGoerDict objectForKey:@"first_name"];
    eventGoer.lastName = [eventGoerDict objectForKey:@"last_name"];
    eventGoer.loggedIn = [[eventGoerDict objectForKey:@"logged_in"] boolValue];
    return [eventGoer autorelease];
}

-(void)dealloc{
    [userName release];
    [firstName release];
    [lastName release];
    [super dealloc];
}

@end
