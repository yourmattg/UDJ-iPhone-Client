//
//  RandomViewController.h
//  UDJ
//
//  Created by Matthew Graf on 5/17/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDJSongList.h"
#import "UDJData.h"
#import "PullRefreshTableViewController.h"

@interface RandomViewController : PullRefreshTableViewController{
    NSInteger MAX_RESULTS;
}

@property(nonatomic,strong) UDJSongList* resultList;

@property(nonatomic,strong) UDJData* globalData;
@property(nonatomic,strong) NSNumber* currentRequestNumber;

@property(nonatomic,strong) IBOutlet UIView* addNotificationView;
@property(nonatomic,strong) IBOutlet UILabel* addNotificationLabel;

@end
