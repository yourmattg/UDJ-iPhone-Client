//
//  LibrarySearchViewController.h
//  UDJ
//
//  Created by Matthew Graf on 12/6/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestKit/RestKit.h"
#import "UDJData.h"

@interface LibrarySearchViewController : UIViewController <RKRequestDelegate>{
    UITextField* searchField;
    UIButton* searchButton;
    NSMutableArray *tableList;
    UIButton* randomButton;
    
}

@property(nonatomic,strong) IBOutlet UITextField* searchField;
@property(nonatomic,strong) IBOutlet UIButton* searchButton;
@property(nonatomic,strong) IBOutlet UIButton* randomButton;
@property(nonatomic,strong) IBOutlet UIButton* playlistButton;

@property(nonatomic,strong) IBOutlet UIView* searchingView;
@property(nonatomic,strong) IBOutlet UIView* searchingBackgroundView;
@property(nonatomic,strong) IBOutlet UIButton* cancelButton;

@property(nonatomic,strong) NSNumber* currentRequestNumber;

@property(nonatomic,strong) UDJData* globalData;

@end
