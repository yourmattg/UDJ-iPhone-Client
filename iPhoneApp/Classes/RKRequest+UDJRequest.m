//
//  RKRequest+UDJRequest.m
//  UDJ
//
//  Created by Matthew Graf on 8/31/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "RKRequest+UDJRequest.h"
#import "RestKit/RKClient.h"
#import "UDJData.h"

@implementation RKRequest (UDJRequest)

+(RKRequest*)UDJRequestWithMethod:(RKRequestMethod)method{
    RKClient* client = [RKClient sharedClient];
    RKRequest* request = [RKRequest requestWithURL: client.baseURL];
    request.method = method;
    request.queue = client.requestQueue;
    request.additionalHTTPHeaders = [UDJData sharedUDJData].headers;
    return request;
}

@end
