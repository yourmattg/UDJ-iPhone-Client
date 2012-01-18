//
//  PlaylistEntryCell.m
//  UDJ
//
//  Created by Matthew Graf on 1/17/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "PlaylistEntryCell.h"

@implementation PlaylistEntryCell

@synthesize songLabel, addedByLabel, artistLabel, upArrowImage, downArrowImage, upVoteLabel, downVoteLabel;

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGRect frame;

    frame= CGRectMake(boundsX+10 ,5, 300, 25);
    songLabel.frame = frame;
    
    frame= CGRectMake(boundsX+20 ,30, 250, 20);
    artistLabel.frame = frame;
    
    frame= CGRectMake(boundsX+20 ,50, 250, 20);
    addedByLabel.frame = frame;
    
    frame = CGRectMake(boundsX+225, 35, 16, 23);
    upArrowImage.frame = frame;
    
    frame = CGRectMake(boundsX+275, 35, 16, 23);
    downArrowImage.frame = frame;
    
    frame = CGRectMake(boundsX+245, 35, 30, 20);
    upVoteLabel.frame = frame;
    
    frame = CGRectMake(boundsX+294, 35, 30, 20);
    downVoteLabel.frame = frame;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        songLabel = [[UILabel alloc] init];
        songLabel.textAlignment = UITextAlignmentLeft;
        songLabel.font = [UIFont fontWithName:@"Helvetica" size:20];
        songLabel.textColor=[UIColor whiteColor];
        songLabel.backgroundColor = [UIColor blackColor];
        
        artistLabel = [[UILabel alloc]init];
        artistLabel.textAlignment = UITextAlignmentLeft;
        artistLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
        artistLabel.textColor = [UIColor whiteColor];
        artistLabel.backgroundColor = [UIColor blackColor];
        
        addedByLabel = [[UILabel alloc]init];
        addedByLabel.textAlignment = UITextAlignmentLeft;
        addedByLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
        addedByLabel.textColor = [UIColor whiteColor];
        addedByLabel.backgroundColor = [UIColor blackColor];
        
        upArrowImage = [[UIImageView alloc] init];
        downArrowImage = [[UIImageView alloc] init];
        UIImage* upArrow = [UIImage imageNamed:@"uparrow.jpg"];
        UIImage* downArrow = [UIImage imageNamed:@"downarrow.jpg"];
        upArrowImage.image = upArrow;
        downArrowImage.image = downArrow;
        
        upVoteLabel = [[UILabel alloc] init];
        downVoteLabel = [[UILabel alloc] init];
        upVoteLabel.textColor = [UIColor greenColor];
        upVoteLabel.backgroundColor = [UIColor blackColor];
        upVoteLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
        upVoteLabel.textAlignment = UITextAlignmentLeft;
        downVoteLabel.textColor = [UIColor redColor];
        downVoteLabel.backgroundColor = [UIColor blackColor];
        downVoteLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
        downVoteLabel.textAlignment = UITextAlignmentLeft;
        
        
        [self.contentView addSubview:songLabel];
        [self.contentView addSubview:artistLabel];
        [self.contentView addSubview:addedByLabel];
        [self.contentView addSubview:upArrowImage];
        [self.contentView addSubview:downArrowImage];
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

-(void) dealloc{
    [songLabel release];
    [artistLabel release];
    [addedByLabel release];
    [upArrowImage release];
    [downArrowImage release];
    [upVoteLabel release];
    [downVoteLabel release];
    [super dealloc];
}

@end
