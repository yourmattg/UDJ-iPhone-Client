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

#pragma mark - Sending helpers

-(NSString*)methodString{
    if([self method] == UDJRequestMethodGET){
        return @"GET";
    }
    else if([self method] == UDJRequestMethodPUT){
        return @"PUT";
    }
    else if([self method] == UDJRequestMethodPOST){
        return @"POST";
    }
    else if([self method] == UDJRequestMethodDELETE){
        return @"DELETE";
    }
    
    return @"";
}

#pragma mark - Sending

-(void)send{
    NSLog(@"about to send");
    UDJClient* client = [UDJClient sharedClient];
    
    // Convert UDJRequest to NSURLRequest
    NSMutableURLRequest* request = [client requestWithMethod:[self methodString] path:[[self URL] absoluteString] parameters: [self params]];
    [request setAllHTTPHeaderFields: [self additionalHTTPHeaders]];
    [request setTimeoutInterval: [self timeoutInterval]];
    
    // Create request operation and specify callbacks
    AFHTTPRequestOperation* operation = [client HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation* operation, id responseObj){
        [self success];
    } failure:^(AFHTTPRequestOperation* operation, NSError* error){
        [self failure];
    }];
    
    [client enqueueHTTPRequestOperation:operation];
}

-(UDJResponse*)sendSynchronously{
    return nil;
}

#pragma mark - Response callback

-(void)success{
    NSLog(@"Request success");
}

-(void)failure{
    NSLog(@"Request fail");
}


@end
