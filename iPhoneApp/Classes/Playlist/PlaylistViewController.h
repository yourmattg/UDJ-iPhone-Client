/**
 * Copyright 2011 Matthew M. Graf
 *
 * This file is part of UDJ.
 *
 * UDJ is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * UDJ is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with UDJ.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <UIKit/UIKit.h>
#import "UDJEvent.h"
#import "UDJPlaylist.h"
#import "RestKit/RestKit.h"
#import "PullRefreshTableViewController.h"

@interface PlaylistViewController : PullRefreshTableViewController <UIAlertViewDelegate, RKRequestDelegate>{

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
-(void)login;
-(void)post;

@property(nonatomic, strong) UDJSong* selectedSong;
@property (nonatomic, strong) UDJEvent* currentEvent;
@property (nonatomic, strong) UDJPlaylist* playlist;
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet UILabel* currentSongTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel* currentSongArtistLabel;
@property(nonatomic,strong) IBOutlet UILabel* statusLabel;
@property(nonatomic,strong) NSNumber* currentRequestNumber;
@property(nonatomic,strong) UDJData* globalData;

@property(nonatomic,strong) IBOutlet UIButton* leaveButton;
@property(nonatomic,strong) IBOutlet UIButton* libraryButton;

@property(nonatomic,strong) IBOutlet UILabel* eventNameLabel;

@property(nonatomic,strong) IBOutlet UIButton* refreshButton;
@property(nonatomic,strong) IBOutlet UIActivityIndicatorView* refreshIndicator;

@property(nonatomic,strong) IBOutlet UIView* voteNotificationView;
@property(nonatomic,strong) IBOutlet UILabel* voteNotificationLabel;
@property(nonatomic,strong) IBOutlet UIImageView* voteNotificationArrowView;

@property(nonatomic,strong) IBOutlet UILabel* playerNameLabel;

// host controls
@property(nonatomic,strong) IBOutlet UIView* hostControlView;
@property(nonatomic,strong) IBOutlet UIButton* playButton;
@property(nonatomic,strong) IBOutlet UISlider* volumeSlider;
@property(nonatomic,strong) IBOutlet UILabel* volumeLabel;
@property(nonatomic,strong) IBOutlet UIButton* controlButton;
@property BOOL playing;

@end
