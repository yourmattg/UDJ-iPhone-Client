//
//  UDJVoteRecord.h
//  UDJ
//
//  Created by Matthew Graf on 5/27/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UDJSong.h"

@interface UDJVoteRecord : NSObject

@property(nonatomic,strong) NSNumber* librarySongIdAsNumber;
@property(nonatomic,strong) NSString* timeAdded;

-(id)initWithSong:(UDJSong*)song;

@end
