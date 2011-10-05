//
//  UDJAppDelegate.h
//  UDJ
//
//  Created by Matthew Graf on 9/24/11.
//  Copyright 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UDJViewController;

@interface UDJAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UDJViewController *viewController;
	UINavigationController *navigationController;
	
	//Application Model Data
	NSString *modelData;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UDJViewController *viewController;
@property (nonatomic, retain) UINavigationController *navigationController;

- (void) setModelData:(NSString *)modelData;
- (NSString *) getModelData;


@end

