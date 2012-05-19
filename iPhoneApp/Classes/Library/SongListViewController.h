//
//  SongListViewController.h
//  UDJ
//
//  Created by Matthew Graf on 5/18/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDJSong.h"
#import "UDJSongList.h"
#import "UDJData.h"

enum UDJQueryType {
    UDJQueryTypeArtist,
    UDJQueryTypeGeneric
};

@interface SongListViewController : UIViewController{
    NSInteger MAX_RESULTS;
}



@property(nonatomic,strong) IBOutlet UILabel* statusLabel;
@property(nonatomic,strong) IBOutlet UIActivityIndicatorView* searchIndicatorView;
@property(nonatomic,strong) IBOutlet UITableView* songTableView;

@property(nonatomic,strong) UDJData* globalData;
@property(nonatomic,strong) NSNumber* currentRequestNumber;

@property(nonatomic,strong) UDJSongList* resultList;

@property(nonatomic,strong) NSString* lastQuery;
@property enum UDJQueryType lastQueryType;

@property(nonatomic,strong) IBOutlet UIView* addNotificationView;
@property(nonatomic,strong) IBOutlet UILabel* addNotificationLabel;

@property(nonatomic,strong) IBOutlet UISearchBar* searchBar;

-(void)getSongsByArtist:(NSString*)artist;
-(void)getSongsByQuery:(NSString*)query;

@end
