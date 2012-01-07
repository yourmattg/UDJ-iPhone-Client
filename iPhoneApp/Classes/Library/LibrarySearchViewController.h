//
//  LibrarySearchViewController.h
//  UDJ
//
//  Created by Matthew Graf on 12/6/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LibrarySearchViewController : UIViewController{
    UITextField* searchField;
    UIButton* searchButton;
    NSMutableArray *tableList;
}

@property(nonatomic,retain) IBOutlet UITextField* searchField;
@property(nonatomic,retain) IBOutlet UIButton* searchButton;

@end
