//
//  UDJSongAdd.h
//  UDJ
//
//  Created by Matthew Graf on 1/8/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>

// UDJSongAdd is used when adding songs to the playlist, it is intended only to be serialized and sent in a request
@interface UDJSongAdd : NSObject{
    NSInteger librarySongId;
    NSInteger clientRequestId;
}

@property(nonatomic) NSInteger librarySongId;
@property(nonatomic) NSInteger clientRequestId;

@end
