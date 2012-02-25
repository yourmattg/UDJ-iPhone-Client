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

@property(nonatomic,strong) UILabel* usernameLabel;
@property(nonatomic,strong) UILabel* firstNameLabel;
@property(nonatomic,strong) UILabel* lastNameLabel;

@end
