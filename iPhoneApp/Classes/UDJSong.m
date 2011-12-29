//
//  UDJSong.m
//  UDJ
//
//  Created by Matthew Graf on 12/27/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJSong.h"

@implementation UDJSong

@synthesize songId, librarySongId, title, artist, album, duration, downVotes, upVotes, timeAdded, adderId, adderName;

+ (id) songFromDictionary:(NSDictionary *)songDict{
    UDJSong* song = [UDJSong new];
    song.title = [songDict objectForKey:@"title"];
    song.songId = [[songDict objectForKey:@"id"] intValue];
    song.librarySongId = [[songDict objectForKey:@"lib_song_id"] intValue];
    song.artist = [songDict objectForKey:@"artist"];
    song.album = [songDict objectForKey:@"album"];
    song.duration = [[songDict objectForKey:@"duration"] intValue];
    song.upVotes = [[songDict objectForKey:@"up_votes"] intValue];
    song.downVotes = [[songDict objectForKey:@"down_votes"] intValue];
    song.timeAdded = [songDict objectForKey:@"time_added"];
    song.adderId = [[songDict objectForKey:@"adder_id"] intValue];
    song.adderName = [songDict objectForKey:@"adder_username"];
    return song;
}

/*
 {
 "lib_song_id" : id of the library entry on the server this playlist entry represents
 "song" : title of the song
 "artist" : song's artist
 "album" : song's album
 "duration" : duration of song in seconds
 "up_votes" : number of up-votes this entry has
 "down_votes" : number of down-votes this entry has
 "time_added" : Time the entry was added
 "time_played" : Time the entry started playing
 "adder_id" : user id of user who added the song to the playlist
 "adder_username" : username of the user who added the song to the playlist
 }
 */

// memory managed
-(void)dealloc{
    [title release];
    [artist release];
    [adderName release];
    [super dealloc];
}

@end
