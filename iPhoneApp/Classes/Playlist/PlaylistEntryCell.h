//
//  PlaylistEntryCell.h
//  UDJ
//
//  Created by Matthew Graf on 1/17/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaylistEntryCell : UITableViewCell{
    UILabel* songLabel;
    UILabel* artistLabel;
    UILabel* addedByLabel;
    UIImageView* upArrowImage;
    UIImageView* downArrowImage;
    UILabel* upVoteLabel;
    UILabel* downVoteLabel;
}

@property(nonatomic,retain) UILabel* songLabel;
@property(nonatomic,retain) UILabel* artistLabel;
@property(nonatomic,retain) UILabel* addedByLabel;
@property(nonatomic,retain) UIImageView* upArrowImage;
@property(nonatomic,retain) UIImageView* downArrowImage;
@property(nonatomic,retain) UILabel* upVoteLabel;
@property(nonatomic,retain) UILabel* downVoteLabel;

@end
