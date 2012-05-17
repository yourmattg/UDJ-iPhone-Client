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

#import "LibraryEntryCell.h"
#import "UDJConnection.h"
#import "UDJEventData.h"

@implementation LibraryEntryCell

@synthesize songLabel, artistLabel, addButton, parentViewController;

// addSong: add the selected song to the event playlist
-(void)addSong:(NSInteger)librarySongId{
    parentViewController.currentRequestNumber = [NSNumber numberWithInt: parentViewController.globalData.requestCount];
    [parentViewController sendAddSongRequest:librarySongId eventId:[UDJEventData sharedEventData].currentEvent.eventId];
    
    // TODO: make this notification less invasive
    UIAlertView* notification = [[UIAlertView alloc] initWithTitle:@"Song Add" message:@"Thanks! Your song will be added to the playlist shortly!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [notification show];
}

- (IBAction) onButtonClick: (id) sender {
    UIButton* button = sender;
    [self addSong:button.tag];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGRect frame;
    frame = CGRectMake(boundsX+275 ,2, 40, 40);
    addButton.frame = frame;
    
    frame= CGRectMake(boundsX+10 ,3, 250, 19);
    songLabel.frame = frame;
    
    frame= CGRectMake(boundsX+14 ,25, 250, 14);
    artistLabel.frame = frame;
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
        songLabel.backgroundColor = [UIColor clearColor];
        
        artistLabel = [[UILabel alloc]init];
        artistLabel.textAlignment = UITextAlignmentLeft;
        artistLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        artistLabel.textColor = [UIColor whiteColor];
        artistLabel.backgroundColor = [UIColor clearColor];
        
        UIImage* addButtonImg = [UIImage imageNamed:@"addbutton.png"];
        addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addButton.tintColor = [UIColor blackColor];
        [addButton setImage:addButtonImg forState:UIControlStateNormal];
        addButton.titleLabel.textColor = [UIColor blackColor];
        addButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24];
        [addButton addTarget:self action:@selector(onButtonClick:)   
           forControlEvents:UIControlEventTouchUpInside];
        
        self.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:songLabel];
        [self.contentView addSubview:artistLabel];
        [self.contentView addSubview:addButton];
        
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
