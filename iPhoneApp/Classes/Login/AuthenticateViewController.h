//
//  AuthenticateViewController.h
//  UDJ
//
//  Created by Matthew Graf on 12/20/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthenticateViewController : UIViewController{
    
    UIButton* cancelButton;
    
}

@property (strong,nonatomic) IBOutlet UIButton* cancelButton;

- (IBAction) OnButtonClick:(id) sender;
@end
