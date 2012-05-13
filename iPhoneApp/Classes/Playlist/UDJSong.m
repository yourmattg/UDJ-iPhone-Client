//
//  UDJSong.m
//  UDJ
//
//  Created by Matthew Graf on 12/27/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJSong.h"

// Active Playlist Entry
@implementation UDJSong

@synthesize songId, librarySongId, title, artist, album, duration, downVoters, upVoters, timeAdded, adderId, adderName;

+ (id) songFromDictionary:(NSDictionary *)songDict isLibraryEntry:(BOOL)isLibEntry{
    if([songDict count]==0) return nil;
    UDJSong* song = [UDJSong new];
    
    // get the library entry info
    NSDictionary* libEntryDict = [songDict objectForKey: @"song"];
    
    song.title = [songDict objectForKey:@"title"];
    song.songId = [[songDict objectForKey:@"id"] intValue];
    if(isLibEntry) song.librarySongId = [[songDict objectForKey:@"id"] intValue];
    else song.librarySongId = [[songDict objectForKey:@"lib_song_id"] intValue];
    song.artist = [songDict objectForKey:@"artist"];
    song.album = [songDict objectForKey:@"album"];
    song.duration = [[songDict objectForKey:@"duration"] intValue];
    song.upVoters = [songDict objectForKey:@"upvoters"];
    song.downVoters = [songDict objectForKey:@"downvoters"];
    song.timeAdded = [songDict objectForKey:@"time_added"];
    song.adderId = [[songDict objectForKey:@"adder_id"] intValue];
    song.adderName = [songDict objectForKey:@"adder_username"];
    return song;
}

@end
