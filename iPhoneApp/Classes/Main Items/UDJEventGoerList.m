//
//  UDJEventGoerList.m
//  UDJ
//
//  Created by Matthew Graf on 1/18/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJEventGoerList.h"

@implementation UDJEventGoerList

@synthesize eventGoerList;

-(UDJEventGoer*)eventGoerAtIndex:(NSInteger)i{
    UDJEventGoer* eventGoer = [eventGoerList objectAtIndex:i];
    return eventGoer;
}

-(void)addEventGoer:(UDJEventGoer*)eventGoer{
    [eventGoerList addObject:eventGoer];
}

-(NSInteger)count{
    return [eventGoerList count];
}

@end
