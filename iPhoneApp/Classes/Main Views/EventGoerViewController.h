//
//  EventGoerViewController.h
//  UDJ
//
//  Created by Matthew Graf on 1/18/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "UDJEventGoerList.h"

@interface EventGoerViewController : UITableViewController<RKRequestDelegate>{
    
    UDJEventGoerList* eventGoerList;
    
}

@property(nonatomic,strong) UDJEventGoerList* eventGoerList;

@end
