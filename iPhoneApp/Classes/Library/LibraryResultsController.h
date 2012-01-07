//
//  LibraryResultsController.h
//  UDJ
//
//  Created by Matthew Graf on 1/7/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDJResultList.h"

@interface LibraryResultsController : UITableViewController{
    UDJResultList* resultList;
}

@property(nonatomic,retain) UDJResultList* resultList;

@end
