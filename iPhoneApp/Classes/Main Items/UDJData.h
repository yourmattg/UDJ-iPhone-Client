//
//  GlobalData.h
//  UDJ
//
//  Created by Matthew Graf on 3/18/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UDJData : NSObject{
    NSString* ticket;
    NSDictionary* headers;
    NSNumber* userID;
    NSString* username;
}

@property NSInteger requestCount;
@property(nonatomic,strong) NSString* ticket;
@property(nonatomic,strong) NSDictionary* headers;
@property(nonatomic,strong) NSNumber* userID;
@property(nonatomic,strong) NSString* username;

+(UDJData*)sharedUDJData;

@end
