//
//  UDJEventGoer.h
//  UDJ
//
//  Created by Matthew Graf on 1/18/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UDJEventGoer : NSObject{
    NSInteger eventGoerId;
    NSString* userName;
    NSString* firstName;
    NSString* lastName;
    BOOL loggedIn;
}

+(id)eventGoerFromDictionary:(NSDictionary*)eventGoerDict;

@property(nonatomic) NSInteger eventGoerId;
@property(nonatomic,strong) NSString* userName;
@property(nonatomic,strong) NSString* firstName;
@property(nonatomic,strong) NSString* lastName;
@property(nonatomic) BOOL loggedIn;

@end