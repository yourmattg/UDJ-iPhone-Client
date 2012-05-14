//
//  UDJUser.h
//  UDJ
//
//  Created by Matthew Graf on 5/14/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UDJUser : NSObject

@property NSInteger userID;
@property(nonatomic,strong) NSString* username;
@property(nonatomic,strong) NSString* firstName;
@property(nonatomic,strong) NSString* lastName;

+(UDJUser*)userFromDict:(NSDictionary*)dict;

@end
