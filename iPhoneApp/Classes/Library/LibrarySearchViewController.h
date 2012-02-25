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
    UIButton* randomButton;
}

@property(nonatomic,strong) IBOutlet UITextField* searchField;
@property(nonatomic,strong) IBOutlet UIButton* searchButton;
@property(nonatomic,strong) IBOutlet UIButton* randomButton;

@end
