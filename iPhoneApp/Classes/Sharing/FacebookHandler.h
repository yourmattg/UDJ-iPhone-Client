//
//  FacebookHandler.h
//  UDJ
//
//  Created by Shao Ping Lee on 2/11/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"

@interface FacebookHandler : NSObject <FBDialogDelegate,FBSessionDelegate,FBRequestDelegate> 
{
    Facebook *facebook;
}

@property (nonatomic,retain) Facebook *facebook;

+(id) sharedHandler;
-(void) logout;
-(void) login;
-(void) postWithParam: (NSMutableDictionary *)params;

@end
