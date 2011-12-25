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
    NSInteger hostId;
    double latitude;
    double longitude;
    
}
+ (UDJEvent*) eventWithId:(NSInteger)eventId name:(NSString*)name hostId:(NSInteger)hostId latitude:(double)lat longitude:(double)lon;

@property(nonatomic) NSInteger eventId;
@property(nonatomic,retain) NSString* name;
@property(nonatomic) NSInteger hostId;
@property(nonatomic) double latitude;
@property(nonatomic) double longitude;

@end
