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

+ (id)songFromDictionary:(NSDictionary*)songDict;

@property(nonatomic) NSInteger songId;
@property(nonatomic) NSInteger librarySongId;
@property(nonatomic,retain) NSString* title;
@property(nonatomic,retain) NSString* artist;
@property(nonatomic,retain) NSString* album;
@property(nonatomic) NSInteger duration;
@property(nonatomic) NSInteger downVotes;
@property(nonatomic) NSInteger upVotes;
@property(nonatomic,retain) NSString* timeAdded;
@property(nonatomic) NSInteger adderId;
@property(nonatomic,retain) NSString* adderName;

@end