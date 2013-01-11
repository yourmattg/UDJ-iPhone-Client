//
//  UDJRequest.m
//  UDJ
//
//  Created by Matthew Graf on 1/7/13.
//
//

#import "UDJRequest.h"
#import "UDJClient.h"

@implementation UDJRequest

@synthesize userData;
@synthesize additionalHTTPHeaders;

/*
 
 UDJClient* client = [UDJClient sharedClient];
 UDJRequest* request = [UDJRequest requestWithURL: client.baseURL];
 request.method = method;
 request.queue = client.requestQueue;
 request.additionalHTTPHeaders = [UDJData sharedUDJData].headers;
 return request;
 */

#pragma mark - Factory methods and intializers

+(UDJRequest*)requestWithMethod:(UDJRequestMethod)method{
    UDJRequest* request = [[UDJRequest alloc] init];
    request.method = method;
    return request;
}


+(UDJRequest*)requestWithURL:(NSURL*)url{
    UDJRequest* request = [[UDJRequest alloc] initWithURL:url];
    return request;
}

-(id)initWithURL:(NSURL*)url{
    if(self = [self init]){
        self.URL = url;
    }
    return self;
}

#pragma mark - Sending

-(void)send{
    UDJClient* client = [UDJClient sharedClient];
    
    NSURLRequest* request = [NSURLRequest requestWithURL: self.URL];
    
}

-(UDJResponse*)sendSynchronously{
    
}

@end
