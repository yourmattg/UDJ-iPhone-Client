//
//  RKRequest+UDJRequest.h
//  UDJ
//
//  Created by Matthew Graf on 8/31/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "RKRequest.h"

@interface RKRequest (UDJRequest)

-(RKRequest*)UDJRequestWithMethod:(RKRequestMethod)method;

@end
