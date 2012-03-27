//
//  LibraryResultsController.h
//  UDJ
//
//  Created by Matthew Graf on 1/7/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

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

@end
