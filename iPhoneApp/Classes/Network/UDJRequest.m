//
//  UDJRequest.m
//  UDJ
//
//  Created by Matthew Graf on 1/7/13.
//
//

#import "UDJRequest.h"

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

@end
