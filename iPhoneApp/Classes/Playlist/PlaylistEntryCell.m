//
//  PlaylistEntryCell.m
//  UDJ
//
//  Created by Matthew Graf on 1/17/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "PlaylistEntryCell.h"

@implementation PlaylistEntryCell

@synthesize songLabel, addedByLabel, artistLabel;

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
        
        [self.contentView addSubview:songLabel];
        [self.contentView addSubview:artistLabel];
        [self.contentView addSubview:addedByLabel];
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
    [super dealloc];
}

@end
