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
    UDJSong* currentSong;
    NSMutableDictionary* voteRecordKeeper;
}

+ (UDJPlaylist*)sharedUDJPlaylist;
- (void)initVoteRecordKeeper;
- (UDJSong*)songPlaying;
- (UDJSong*)songAtIndex:(NSInteger)i;
- (void)loadPlaylist;
- (NSInteger)count;
- (void)clearPlaylist;

@property(nonatomic,strong) NSMutableArray* playlist;
@property(nonatomic) NSInteger eventId;
@property(nonatomic,strong) UDJSong* currentSong;
@property(nonatomic,strong) NSMutableDictionary* voteRecordKeeper;

@end
