//
//  UDJResultList.m
//  UDJ
//
//  Created by Matthew Graf on 1/7/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJSongList.h"

@implementation UDJSongList

@synthesize currentList;

-(id)init
{
    self = [super init];
    self.currentList = [[NSMutableArray new] autorelease];
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
