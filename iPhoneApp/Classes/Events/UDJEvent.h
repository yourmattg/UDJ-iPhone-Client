//
//  UDJEvent.h
//  UDJ
//
//  Created by Matthew Graf on 12/23/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UDJEvent : NSObject{
    @private
    NSInteger eventId;
    NSString* name;
    NSString* hostUsername;
    NSInteger hostId;
    BOOL hasPassword;
    double latitude;
    double longitude;
    
}
+ (UDJEvent*) eventFromDictionary:(NSDictionary*)eventDict;

@property(nonatomic) NSInteger eventId;
@property(nonatomic,strong) NSString* name;
@property(nonatomic) NSInteger hostId;
@property(nonatomic) double latitude;
@property(nonatomic) double longitude;
@property(nonatomic) BOOL hasPassword;
@property(nonatomic,strong) NSString* hostUsername;

@end
