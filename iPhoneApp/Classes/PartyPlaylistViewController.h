//
//  PartyPlaylistViewController.h
//  UDJ
//
//  Created by Matthew Graf on 12/6/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PartyPlaylistViewController : UITableViewController{

    NSMutableArray *playlist;

}

@property (nonatomic, retain) NSMutableArray *playlist;
@end
