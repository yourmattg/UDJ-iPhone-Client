//
//  EventCell.m
//  UDJ
//
//  Created by Matthew Graf on 3/24/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "EventCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation EventCell

@synthesize cellImageView, eventNameLabel;

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGRect frame;
    
    frame= CGRectMake(boundsX+25 ,3, 270, 50);
    cellImageView.frame = frame;
    
    frame = CGRectMake(boundsX+50, 3, 250, 50);
    eventNameLabel.frame = frame;
    
    
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        cellImageView = [[UIImageView alloc] init];
        cellImageView.backgroundColor = [UIColor colorWithRed:149 green:207 blue:233 alpha: 0.3];
        cellImageView.layer.cornerRadius = 8;
        cellImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
        cellImageView.layer.borderWidth = 3;
        [self.contentView addSubview: cellImageView];
        
        eventNameLabel = [[UILabel alloc] init];
        eventNameLabel.font = [UIFont fontWithName:@"Helvetica" size:22];
        eventNameLabel.textColor = [UIColor whiteColor];
        eventNameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview: eventNameLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
