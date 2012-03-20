//
//  EventResultsViewController.h
//  UDJ
//
//  Created by Matthew Graf on 3/20/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventResultsViewController : UIViewController

@property(nonatomic,strong) NSMutableArray* tableList;
@property(nonatomic,strong) IBOutlet UITableView* tableView;

@end
