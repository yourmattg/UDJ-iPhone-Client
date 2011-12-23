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
    NSString* eventId;
    NSString* name;
    NSString* hostId;
    NSString* latitude;
    NSString* longitude;
    
}
- (UDJEvent*) eventWithId:(NSString*)eventId name:(NSString*)name hostId:(NSString*)hostId latitude:(NSString*)lat longitude:(NSString*)lon;

@property(nonatomic,retain) NSString* eventId;
@property(nonatomic,retain) NSString* name;
@property(nonatomic,retain) NSString* hostId;
@property(nonatomic,retain) NSString* latitude;
@property(nonatomic,retain) NSString* longitude;

@end
