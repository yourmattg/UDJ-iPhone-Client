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
#import "RestKit/RestKit.h"

@interface PlaylistViewController : UIViewController <UIAlertViewDelegate, RKRequestDelegate>{

    UDJPlaylist *playlist;
    UDJEvent* currentEvent;
    UITableView* tableView;
    UILabel* currentSongTitleLabel;
    UILabel* currentSongArtistLabel;
    UILabel* statusLabel;
    UDJSong* selectedSong;
    UDJData* globalData;
    
    UIView* leavingBackgroundView;
    UIView* leavingView;

}

-(void)sendRefreshRequest;
-(void)refreshTableList;
-(void)vote:(BOOL)up;
-(void)downVote;
-(void)upVote;
-(void)login;
-(void)post;
-(void)removeSong;
-(void)showEventGoers;
+(PlaylistViewController*) sharedPlaylistViewController;
-(void) toggleLeavingView:(BOOL) active;

@property(nonatomic, strong) UDJSong* selectedSong;
@property (nonatomic, strong) UDJEvent* currentEvent;
@property (nonatomic, strong) UDJPlaylist* playlist;
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet UILabel* currentSongTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel* currentSongArtistLabel;
@property(nonatomic,strong) IBOutlet UILabel* statusLabel;
@property(nonatomic,strong) NSNumber* currentRequestNumber;
@property(nonatomic,strong) UDJData* globalData;

@property(nonatomic,strong) IBOutlet UIView* leavingBackgroundView;
@property(nonatomic,strong) IBOutlet UIView* leavingView;

@property(nonatomic,strong) IBOutlet UIButton* leaveButton;
@property(nonatomic,strong) IBOutlet UIButton* libraryButton;

@property(nonatomic,strong) IBOutlet UILabel* eventNameLabel;

@property(nonatomic,strong) IBOutlet UIButton* refreshButton;
@property(nonatomic,strong) IBOutlet UIActivityIndicatorView* refreshIndicator;
@property(nonatomic,strong) IBOutlet UILabel* refreshLabel;

@property(nonatomic,strong) IBOutlet UIView* voteNotificationView;
@property(nonatomic,strong) IBOutlet UILabel* voteNotificationLabel;
@property(nonatomic,strong) IBOutlet UIImageView* voteNotificationArrowView;

@end
