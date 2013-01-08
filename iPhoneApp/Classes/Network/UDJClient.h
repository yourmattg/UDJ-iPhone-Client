//
//  UDJClient.h
//  UDJ
//
//  Created by Matthew Graf on 12/27/12.
//
//

#import <RestKit/RestKit.h>
#import "UDJRequestDelegate.h"
#import "UDJRequest.h"
#import "UDJResponse.h"

@interface UDJClient : AFHTTPClient

+(UDJClient*)sharedClient;

@end
