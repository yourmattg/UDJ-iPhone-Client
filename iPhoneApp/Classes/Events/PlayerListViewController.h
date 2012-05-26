//
//  PlayerListViewController.h
//  UDJ
//
//  Created by Matthew Graf on 5/24/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDJData.h"
#import "UDJEventData.h"

enum SearchType {
    SearchTypeNull = 0,
    SearchTypeName = 1,
    SearchTypeNearby = 2
};

@interface PlayerListViewController : UIViewController


@property enum SearchType lastSearchType;

@property(nonatomic,strong) UDJEventData* eventData;

@property(nonatomic,strong) NSMutableArray *tableList;
@property(nonatomic,strong) IBOutlet UITableView* tableView;
@property(nonatomic,strong) IBOutlet UILabel* statusLabel;

@property(nonatomic,strong) UDJData* globalData;
@property(nonatomic,strong) NSNumber* currentRequestNumber;

@property(nonatomic,strong) IBOutlet UISearchBar* playerSearchBar;
@property(nonatomic,strong) IBOutlet UIButton* findNearbyButton;
@property(nonatomic,strong) IBOutlet UIActivityIndicatorView* searchIndicatorView;

//@property enum SearchType lastSearchType;

@end
