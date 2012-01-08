//
//  LibraryResultsController.h
//  UDJ
//
//  Created by Matthew Graf on 1/7/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDJSongList.h"

@interface LibraryResultsController : UITableViewController{
    UDJSongList* resultList;
    UDJSong* selectedSong;
}

@property(nonatomic,retain) UDJSongList* resultList;
@property(nonatomic,retain) UDJSong* selectedSong;

@end
