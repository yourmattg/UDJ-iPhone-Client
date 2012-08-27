//
//  UDJPlayerManager.h
//  UDJ
//
//  Created by Matthew Graf on 7/28/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UDJData.h"
#import <AVFoundation/AVFoundation.h>
#import "UDJPlaylist.h"

typedef enum {
    PlayerStateInactive,
    PlayerStatePlaying,
    PlayerStatePaused
} PlayerState;

@interface UDJPlayerManager : NSObject <RKRequestDelegate>

@property(nonatomic,strong) NSString* playerName;
@property(nonatomic,strong) NSString* playerPassword;
@property(nonatomic,strong) NSString* address;
@property(nonatomic,strong) NSString* stateLocation;
@property(nonatomic,strong) NSString* city;
@property(nonatomic,strong) NSString* zipCode;
@property NSInteger playerID;

@property BOOL isInPlayerMode;
@property PlayerState playerState;
@property BOOL isInBackground;

@property(nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property(nonatomic,strong) NSMutableDictionary* songSyncDictionary;
@property(nonatomic,strong) UDJData* globalData;

@property(nonatomic,strong) AVQueuePlayer* audioPlayer;
@property(nonatomic,strong) MPMediaItem* currentMediaItem;
@property BOOL nextSongAdded;

@property double songLength;
@property double songPosition;

@property(nonatomic,strong) NSTimer* playlistTimer;

@property(nonatomic,weak) UIViewController* UIDelegate;
@property(nonatomic,weak) UDJPlaylist* playlist;

+(UDJPlayerManager*)sharedPlayerManager;
-(void)updateCurrentPlayer;
-(void)loadPlayerInfo;
-(void)savePlayerInfo;
-(void)updatePlayerMusic;
-(void)changePlayerState:(PlayerState)newState;

-(float)currentPlaybackTime;

-(void)enterBackgroundMode;
-(void)exitBackgroundMode;

-(BOOL)play;
-(void)pause;
-(void)updateSongPosition:(NSInteger)seconds;
-(void)playNextSong;

-(void)resetAudioPlayer;

-(void)beginPlaylistUpdates;
-(void)endPlaylistUpdates;

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response;

@end
