//
//  SongListViewController.h
//  UDJ
//
//  Created by Matthew Graf on 5/18/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongListViewController : UIViewController

@property(nonatomic,strong) IBOutlet UILabel* statusLabel;
@property(nonatomic,strong) IBOutlet UIActivityIndicatorView* searchIndicatorView;
@property(nonatomic,strong) IBOutlet UITableView* songTableView;

@property(nonatomic,strong) NSNumber* currentRequestNumber;

-(void)getSongsByArtist:(NSString*)artist;
-(void)getSongsByQuery:(NSString*)query;

@end
