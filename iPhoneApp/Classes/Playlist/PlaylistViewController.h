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
#import "PlaylistEntryCell.h"

@interface PlaylistViewController : UIViewController <UIAlertViewDelegate>{

    UDJPlaylist *playlist;
    UDJEvent* theEvent;
    UDJSong* selectedSong;
    UITableView* tableView;
    UILabel* currentSongTitleLabel;
    UILabel* currentSongArtistLabel;

}

-(void)showLibrary;
-(void)leaveEvent;
-(void)sendRefreshRequest;
-(void)refreshTableList;
-(void)vote:(BOOL)up;
-(void)downVote;
-(void)upVote;
-(void)removeSong;
-(void)showEventGoers;
+(PlaylistViewController*) sharedPlaylistViewController;

@property(nonatomic, assign) UDJSong* selectedSong;
@property (nonatomic, retain) UDJEvent* theEvent;
@property (nonatomic, retain) UDJPlaylist* playlist;
@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UILabel* currentSongTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel* currentSongArtistLabel;

@end
