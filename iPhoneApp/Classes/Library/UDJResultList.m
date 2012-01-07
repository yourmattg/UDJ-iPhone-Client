//
//  UDJResultList.m
//  UDJ
//
//  Created by Matthew Graf on 1/7/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJResultList.h"

@implementation UDJResultList

@synthesize currentList;

-(id)init
{
    self = [super init];
    return self;
}

-(void)addSong:(UDJSong*)song{
    [self.currentList addObject:song];
}

-(UDJSong*)songAtIndex:(NSUInteger)index{
    UDJSong* song = [currentList objectAtIndex:index];
    return song;
}

-(NSInteger)count{
    return [currentList count];
}

-(void) dealloc{
    [currentList release];
    [super dealloc];
}


@end
