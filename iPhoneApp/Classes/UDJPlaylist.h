//
//  UDJPlaylist.h
//  UDJ
//
//  Created by Matthew Graf on 12/27/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UDJSong.h"

@interface UDJPlaylist : NSObject{
    
    NSMutableArray* playlist;
    NSInteger eventId;
}

+ (UDJPlaylist*)sharedUDJPlaylist;
- (UDJSong*)songAtIndex:(NSInteger)i;
- (void)loadPlaylist;
- (NSInteger)count;

@property(nonatomic,retain) NSMutableArray* playlist;
@property(nonatomic) NSInteger eventId;

@end