//
//  UDJResultList.h
//  UDJ
//
//  Created by Matthew Graf on 1/7/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UDJSong.h"

// UDJResultList is used to store the results of a library search
// it is basically a wrapper class to ensure LibraryResultsController is using
// an array that only has UDJSongs in it
@interface UDJSongList : NSObject{
    NSMutableArray* currentList;
}

@property(nonatomic,retain) NSMutableArray* currentList;

-(void)addSong:(UDJSong*)song;
-(UDJSong*)songAtIndex:(NSUInteger)index;
-(NSInteger)count;


@end
