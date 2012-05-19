//
//  SongListViewController.h
//  UDJ
//
//  Created by Matthew Graf on 5/18/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDJSong.h"
#import "UDJSongList.h"

@interface SongListViewController : UIViewController{
    NSInteger MAX_RESULTS;
}



@property(nonatomic,strong) IBOutlet UILabel* statusLabel;
@property(nonatomic,strong) IBOutlet UIActivityIndicatorView* searchIndicatorView;
@property(nonatomic,strong) IBOutlet UITableView* songTableView;

@property(nonatomic,strong) NSNumber* currentRequestNumber;

@property(nonatomic,strong) UDJSongList* resultList;

-(void)getSongsByArtist:(NSString*)artist;
-(void)getSongsByQuery:(NSString*)query;

@end
