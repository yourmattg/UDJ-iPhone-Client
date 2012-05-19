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

@interface RandomViewController : UIViewController{
    NSInteger MAX_RESULTS;
}


@property(nonatomic,strong) IBOutlet UIActivityIndicatorView* searchIndicatorView;
@property(nonatomic,strong) IBOutlet UIButton* refreshButton;

@property(nonatomic,strong) IBOutlet UITableView* songTableView;
@property(nonatomic,strong) UDJSongList* resultList;

@property(nonatomic,strong) UDJData* globalData;
@property(nonatomic,strong) NSNumber* currentRequestNumber;

@end
