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

#define PCELL_PADDING     5

#import "PlayerCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation PlayerCell

@synthesize cellImageView, eventNameLabel;
@synthesize containerView;

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGRect frame;
    
    frame = CGRectMake(boundsX+15, -3, 250, self.frame.size.height);
    eventNameLabel.frame = frame;
    
    
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIColor* containerColor = [UIColor colorWithRed:72.0/255.0 green:147.0/255.0 blue:203.0/255.0 alpha:0.85];
        UIColor* borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.9];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        containerView = [[UIView alloc] initWithFrame:CGRectMake(PCELL_PADDING, 0, 320-2*PCELL_PADDING, self.frame.size.height)];
        [containerView setBackgroundColor: containerColor];
        [containerView.layer setCornerRadius: 5];
        [containerView.layer setBorderColor: [borderColor CGColor]];
        [containerView.layer setBorderWidth: 1];
        [self.contentView addSubview:containerView];
        
        eventNameLabel = [[UILabel alloc] init];
        eventNameLabel.font = [UIFont fontWithName:@"Helvetica" size:22];
        eventNameLabel.textColor = [UIColor whiteColor];
        eventNameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview: eventNameLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if(selected){
        UIColor* containerColor = [UIColor colorWithRed:0.0/255.0 green:73.0/255.0 blue:128.0/255.0 alpha:0.85];
        [containerView setBackgroundColor:containerColor];
    }
    else{
        UIColor* containerColor = [UIColor colorWithRed:72.0/255.0 green:147.0/255.0 blue:203.0/255.0 alpha:0.85];
        [containerView setBackgroundColor:containerColor];
    }
    
}

@end
