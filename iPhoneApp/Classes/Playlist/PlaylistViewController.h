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
    UDJSong* __weak selectedSong;
    UITableView* tableView;
    UILabel* currentSongTitleLabel;
    UILabel* currentSongArtistLabel;
    UILabel* statusLabel;

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

@property(nonatomic, weak) UDJSong* selectedSong;
@property (nonatomic, strong) UDJEvent* theEvent;
@property (nonatomic, strong) UDJPlaylist* playlist;
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet UILabel* currentSongTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel* currentSongArtistLabel;
@property(nonatomic,strong) IBOutlet UILabel* statusLabel;

@end
