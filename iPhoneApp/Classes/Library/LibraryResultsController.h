//
//  LibraryResultsController.h
//  UDJ
//
//  Created by Matthew Graf on 1/7/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LibraryResultsController : UITableViewController{
    NSMutableArray* tableList;
}

@property(nonatomic,retain) NSMutableArray* tableList;

@end
