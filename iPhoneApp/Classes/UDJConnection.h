//
//  UDJConnection.h
//  UDJ
//
//  Created by Matthew Graf on 12/13/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface UDJConnection : NSObject<RKRequestDelegate>{
    @public
    
    @private
    NSString* serverPrefix; // without spaces: https ://www.bazaarsolutions.com:4897/udj
    NSString* ticket;
    RKClient* client; // configures, dispatches request
}

+ (id) sharedConnection;
- (void) initWithServerPrefix:(NSString*)prefix;
- (void) authenticate:(NSString*)username password:(NSString*)pass;

@property(nonatomic,retain) NSString* serverPrefix;
@property(nonatomic,retain) NSString* ticket;
@property(nonatomic,retain) RKClient* client;

@end
