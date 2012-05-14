//
//  UDJUser.m
//  UDJ
//
//  Created by Matthew Graf on 5/14/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJUser.h"

@implementation UDJUser

@synthesize userID, username, firstName, lastName;

+(UDJUser*)userFromDict:(NSDictionary*)dict{
    UDJUser* user = [UDJUser new];
    user.userID = [[dict objectForKey: @"id"] intValue];
    user.username = [dict objectForKey: @"username"];
    user.firstName = [dict objectForKey: @"first_name"];
    user.lastName = [dict objectForKey: @"last_name"];
    return user;
}

@end
