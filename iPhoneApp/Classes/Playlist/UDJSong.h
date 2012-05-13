//
//  UDJSong.h
//  UDJ
//
//  Created by Matthew Graf on 12/27/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UDJSong : NSObject{
    NSInteger songId;
    NSInteger librarySongId;
    NSString* title;
    NSString* artist;
    NSString* album;
    NSInteger duration;
    NSInteger downVotes;
    NSInteger upVotes;
    NSString* timeAdded;
    NSInteger adderId;
    NSString* adderName;
}

+ (id)songFromDictionary:(NSDictionary*)songDict isLibraryEntry:(BOOL)isLibEntry;

@property(nonatomic) NSInteger songId;
@property(nonatomic) NSInteger librarySongId;
@property(nonatomic,strong) NSString* title;
@property(nonatomic,strong) NSString* artist;
@property(nonatomic,strong) NSString* album;
@property(nonatomic) NSInteger duration;
@property(nonatomic,strong) NSString* timeAdded;
@property(nonatomic) NSInteger adderId;
@property(nonatomic,strong) NSString* adderName;
@property(nonatomic,strong) NSArray* upVoters;
@property(nonatomic,strong) NSArray* downVoters;

@end