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

#import "PlaylistEntryCell.h"
#import "PlaylistViewController.h"

@implementation PlaylistEntryCell

@synthesize songLabel, addedByLabel, artistLabel, upVoteButton, downVoteButton, upVoteLabel, downVoteLabel, parentViewController;

- (IBAction) onButtonClick: (id) sender {
    UIButton* button = sender;
    [PlaylistViewController sharedPlaylistViewController].selectedSong = [[UDJPlaylist sharedUDJPlaylist] songAtIndex: button.tag];
    if(sender == upVoteButton) {
        [[PlaylistViewController sharedPlaylistViewController] vote:YES];
    }    
    else if(sender == downVoteButton){
        [[PlaylistViewController sharedPlaylistViewController] vote:NO];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGRect frame;

    frame= CGRectMake(boundsX+10 ,3, 300, 20);
    songLabel.frame = frame;
    
    frame= CGRectMake(boundsX+14 ,24, 250, 17);
    artistLabel.frame = frame;
    
    frame= CGRectMake(boundsX+14 ,42, 250, 16);
    addedByLabel.frame = frame;
    
    frame = CGRectMake(boundsX+215, 4, 38, 38);
    upVoteButton.frame = frame;
    
    frame = CGRectMake(boundsX+275, 4, 38, 38);
    downVoteButton.frame = frame;
    
    frame = CGRectMake(boundsX+229, 42, 30, 20);
    upVoteLabel.frame = frame;
    
    frame = CGRectMake(boundsX+289, 42, 30, 20);
    downVoteLabel.frame = frame;
    
    if(!self.upVoteLabel.hidden){
        frame= CGRectMake(boundsX+10 ,3, 200, 20);
        songLabel.frame = frame;
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        songLabel = [[UILabel alloc] init];
        songLabel.textAlignment = UITextAlignmentLeft;
        songLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
        songLabel.textColor=[UIColor whiteColor];
        songLabel.backgroundColor = [UIColor colorWithRed:50 green:112 blue:176 alpha:0];
        
        artistLabel = [[UILabel alloc]init];
        artistLabel.textAlignment = UITextAlignmentLeft;
        artistLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        artistLabel.textColor = [UIColor whiteColor];
        artistLabel.backgroundColor = [UIColor clearColor];
        
        addedByLabel = [[UILabel alloc]init];
        addedByLabel.textAlignment = UITextAlignmentLeft;
        addedByLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        addedByLabel.textColor = [UIColor whiteColor];
        addedByLabel.backgroundColor = [UIColor clearColor];
        
        UIImage* upVoteImage = [UIImage imageNamed:@"voteup.png"];
        upVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [upVoteButton setImage:upVoteImage forState:UIControlStateNormal];
        [upVoteButton addTarget:self action:@selector(onButtonClick:)   
            forControlEvents:UIControlEventTouchUpInside];
        UIImage* downVoteImage = [UIImage imageNamed:@"votedown.png"];
        downVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [downVoteButton setImage:downVoteImage forState:UIControlStateNormal];
        [downVoteButton addTarget:self action:@selector(onButtonClick:)   
               forControlEvents:UIControlEventTouchUpInside];
     
        upVoteLabel = [[UILabel alloc] init];
        downVoteLabel = [[UILabel alloc] init];
        upVoteLabel.textColor = [UIColor greenColor];
        upVoteLabel.backgroundColor = [UIColor clearColor];
        upVoteLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
        upVoteLabel.textAlignment = UITextAlignmentLeft;
        downVoteLabel.textColor = [UIColor redColor];
        downVoteLabel.backgroundColor = [UIColor clearColor];
        downVoteLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
        downVoteLabel.textAlignment = UITextAlignmentLeft;
        
        upVoteLabel.hidden=YES;
        downVoteLabel.hidden=YES;
        addedByLabel.hidden=YES;
        
        self.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:songLabel];
        [self.contentView addSubview:artistLabel];
        [self.contentView addSubview:addedByLabel];
        [self.contentView addSubview:upVoteButton];
        [self.contentView addSubview:downVoteButton];
        [self.contentView addSubview:upVoteLabel];
        [self.contentView addSubview:downVoteLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
