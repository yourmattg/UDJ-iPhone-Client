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

@synthesize songId, librarySongId, title, artist, album, duration, downVoters, upVoters, timeAdded, adderId, adderName, track, genre;

+ (id) songFromDictionary:(NSDictionary *)songDict isLibraryEntry:(BOOL)isLibEntry{
    if([songDict count]==0) return nil;
    UDJSong* song = [UDJSong new];
    
    // get the library entry info
    NSDictionary* libEntryDict = [songDict objectForKey: @"song"];
    
    song.title = [libEntryDict objectForKey:@"title"];
    song.librarySongId = [[libEntryDict objectForKey:@"id"] intValue];
    song.artist = [libEntryDict objectForKey:@"artist"];
    song.album = [libEntryDict objectForKey:@"album"];
    song.duration = [[libEntryDict objectForKey:@"duration"] intValue];
    song.track = [[libEntryDict objectForKey:@"track"] intValue];
    song.genre = [libEntryDict objectForKey:@"genre"];
    song.upVoters = [songDict objectForKey:@"upvoters"];
    song.downVoters = [songDict objectForKey:@"downvoters"];
    song.timeAdded = [songDict objectForKey:@"time_added"];
    
    // TODO: parse adder JSON object
    //song.adderId = [[songDict objectForKey:@"adder_id"] intValue];
    //song.adderName = [songDict objectForKey:@"adder_username"];
    return song;
}

@end
