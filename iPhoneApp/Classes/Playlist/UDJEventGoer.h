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

@property(nonatomic) NSInteger eventGoerId;
@property(nonatomic,retain) NSString* userName;
@property(nonatomic,retain) NSString* firstName;
@property(nonatomic,retain) NSString* lastName;
@property(nonatomic) BOOL loggedIn;

@end