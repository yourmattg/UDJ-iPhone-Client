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
