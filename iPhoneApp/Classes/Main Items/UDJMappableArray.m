//
//  UDJMappableArray.m
//  UDJ
//
//  Created by Matthew Graf on 1/10/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJMappableArray.h"

@implementation UDJMappableArray

@synthesize array;

-(id)objectAtIndex:(NSUInteger)index{
    return [array objectAtIndex:index];
}


@end
