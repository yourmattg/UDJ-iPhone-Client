//
//  PartyPlaylistViewController.h
//  UDJ
//
//  Created by Matthew Graf on 12/6/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDJEvent.h"
#import "UDJPlaylist.h"

@interface PlaylistViewController : UITableViewController{

    UDJPlaylist *playlist;
    UDJEvent* theEvent;

}

@property (nonatomic, retain) UDJPlaylist *playlist;
@property (nonatomic, retain) UDJEvent* theEvent;

@end
