//
//  UDJVoteRecord.m
//  UDJ
//
//  Created by Matthew Graf on 5/27/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJVoteRecord.h"

@implementation UDJVoteRecord

@synthesize librarySongIdAsNumber, timeAdded;

-(id)initWithSong:(UDJSong*)song{
    if(self = [super init]){
        self.librarySongIdAsNumber = [NSNumber numberWithInteger: song.librarySongId];
        self.timeAdded = [NSString stringWithString: song.timeAdded];
    }
    
    return self;
}

@end
