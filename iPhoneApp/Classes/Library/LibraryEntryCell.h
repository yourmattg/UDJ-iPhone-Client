//
//  LibraryEntryCell.h
//  UDJ
//
//  Created by Matthew Graf on 1/16/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LibraryResultsController.h"

@interface LibraryEntryCell : UITableViewCell{
    UILabel* songLabel;
    UILabel* artistLabel;
    UIButton* addButton;
}

@property(nonatomic,strong) UILabel* songLabel;
@property(nonatomic,strong) UILabel* artistLabel;
@property(nonatomic,strong) UIButton* addButton;
@property(nonatomic,strong) LibraryResultsController* parentViewController;

@end
