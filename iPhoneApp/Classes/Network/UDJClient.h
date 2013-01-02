//
//  UDJClient.h
//  UDJ
//
//  Created by Matthew Graf on 12/27/12.
//
//

#import <RestKit/RestKit.h>

@interface UDJClient : AFHTTPClient

+(UDJClient*)sharedClient;

@end
