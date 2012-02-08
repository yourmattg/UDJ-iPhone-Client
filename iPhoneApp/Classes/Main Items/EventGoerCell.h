//
//  EventGoerCell.h
//  UDJ
//
//  Created by Matthew Graf on 2/7/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventGoerCell : UITableViewCell{
    UILabel* usernameLabel;
    UILabel* firstNameLabel; 
    UILabel* lastNameLabel;
}

@property(nonatomic,retain) UILabel* usernameLabel;
@property(nonatomic,retain) UILabel* firstNameLabel;
@property(nonatomic,retain) UILabel* lastNameLabel;

@end
