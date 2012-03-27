//
//  PlaylistEntryCell.h
//  UDJ
//
//  Created by Matthew Graf on 1/17/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaylistViewController.h"

@interface PlaylistEntryCell : UITableViewCell{
    UILabel* songLabel;
    UILabel* artistLabel;
    UILabel* addedByLabel;
    UIButton* upVoteButton;
    UIButton* downVoteButton;
    UILabel* upVoteLabel;
    UILabel* downVoteLabel;
}

@property(nonatomic,strong) UILabel* songLabel;
@property(nonatomic,strong) UILabel* artistLabel;
@property(nonatomic,strong) UILabel* addedByLabel;
@property(nonatomic,strong) UIButton* upVoteButton;
@property(nonatomic,strong) UIButton* downVoteButton;
@property(nonatomic,strong) UILabel* upVoteLabel;
@property(nonatomic,strong) UILabel* downVoteLabel;

@property(nonatomic,strong) PlaylistViewController* parentViewController;

@end
