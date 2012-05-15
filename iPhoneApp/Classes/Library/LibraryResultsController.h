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
#import "RestKit/RestKit.h"
#import "UDJSongList.h"
#import "UDJData.h"

@interface LibraryResultsController : UIViewController<RKRequestDelegate>{
    UDJSongList* resultList;
    UDJSong* selectedSong;
    UITableView* tableView;
    UILabel* statusLabel;
}

@property(nonatomic,strong) UDJSongList* resultList;
@property(nonatomic,strong) UDJSong* selectedSong;
@property(nonatomic,strong) IBOutlet UITableView* tableView;
@property(nonatomic,strong) IBOutlet UILabel* statusLabel;
@property(nonatomic,strong) IBOutlet UIButton* randomButton;

@property(nonatomic,strong) IBOutlet UIButton* backButton;

@property(nonatomic,strong) UDJData* globalData;

@property(nonatomic,strong) NSNumber* currentRequestNumber;

@property(nonatomic,strong) IBOutlet UIActivityIndicatorView* searchingIndicator;
@property(nonatomic,strong) IBOutlet UILabel* searchingLabel;

-(void)sendAddSongRequest:(NSInteger)librarySongId eventId:(NSInteger)eventId;

@end
