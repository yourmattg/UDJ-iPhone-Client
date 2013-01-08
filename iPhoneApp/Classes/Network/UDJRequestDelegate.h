//
//  UDJResponseDelegate.h
//  UDJ
//
//  Created by Matthew Graf on 1/7/13.
//
//

#import <Foundation/Foundation.h>
#import "UDJRequest.h"
#import "UDJResponse.h"

@protocol UDJRequestDelegate <NSObject>

@required

-(void)request:(UDJRequest*) didLoadResponse:(UDJResponse*)response;

@end
