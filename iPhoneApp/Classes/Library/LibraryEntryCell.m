//
//  LibraryEntryCell.m
//  UDJ
//
//  Created by Matthew Graf on 1/16/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "LibraryEntryCell.h"
#import "UDJConnection.h"
#import "UDJEventList.h"

@implementation LibraryEntryCell

@synthesize songLabel, artistLabel, addButton;

// addSong: add the selected song to the event playlist
-(void)addSong:(NSInteger)librarySongId{
    UIAlertView* notification = [[UIAlertView alloc] initWithTitle:@"Song Add" message:@"Thanks! Your song will be added to the playlist shortly!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [[UDJConnection sharedConnection] sendAddSongRequest:librarySongId eventId:[UDJEventList sharedEventList].currentEvent.eventId];
    [notification show];
    [notification release];
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
    frame = CGRectMake(boundsX+275 ,12, 35, 35);
    addButton.frame = frame;
    
    frame= CGRectMake(boundsX+10 ,5, 250, 25);
    songLabel.frame = frame;
    
    frame= CGRectMake(boundsX+20 ,30, 250, 20);
    artistLabel.frame = frame;
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
        songLabel.backgroundColor = [UIColor clearColor];
        
        artistLabel = [[UILabel alloc]init];
        artistLabel.textAlignment = UITextAlignmentLeft;
        artistLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
        artistLabel.textColor = [UIColor whiteColor];
        artistLabel.backgroundColor = [UIColor clearColor];
        
        UIImage* addButtonImg = [UIImage imageNamed:@"addbutton.jpg"];
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
    //[addButton release];
    [super dealloc];
}

@end
