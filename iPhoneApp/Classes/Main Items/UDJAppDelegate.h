//
//  UDJAppDelegate.h
//  UDJ
//
//  Created by Matthew Graf on 9/24/11.
//  Copyright 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDJConnection.h"

@class UDJViewController;

@interface UDJAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UDJViewController *viewController;
	UINavigationController *navigationController;
    UDJConnection* udjConnection;
    NSString* baseUrl;
	
	//Application Model Data
	NSString *modelData;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UDJViewController *viewController;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) UDJConnection* udjConnection;
@property (nonatomic, retain) NSString* baseUrl;

- (void) setModelData:(NSString *)modelData;
- (NSString *) getModelData;


@end

