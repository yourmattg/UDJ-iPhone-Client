//
//  UDJAppDelegate.m
//  UDJ
//
//  Created by Matthew Graf on 9/24/11.
//  Copyright 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJAppDelegate.h"
#import "UDJViewController.h"
#import "UDJConnection.h"
#import "UDJEvent.h"
#import "UDJEventList.h"
#import "UDJPlaylist.h"
#import "UDJSongList.h"
#import "UDJMappableArray.h"

@implementation UDJAppDelegate

@synthesize window;
@synthesize viewController, navigationController;
@synthesize udjConnection;
@synthesize baseUrl;

// accessor methods for "data" property

- (void) setModelData:(NSString *) newData {
	modelData = newData;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"dataChangeEvent" object:self];
}

- (NSString *) getModelData {
	if ( modelData == nil ) {
		modelData = @"Hello World";
	}
	return modelData;
}

#pragma mark -
#pragma mark Appelication lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    // Override point for customization after application launch.
    
    // initialize udjConnection
    //baseUrl = @"https://udjevents.com:4897/udj";
    baseUrl = @"https://0.0.0.0:4897/udj";
    [[UDJConnection sharedConnection] initWithServerPrefix: baseUrl];
    [UDJEventList new]; // make our eventlist singleton
    [UDJPlaylist new]; // make UDJPlaylist singleton
    [[UDJPlaylist sharedUDJPlaylist] initVoteRecordKeeper];
    
	//create a UDJViewController (the login screen), and make it the root view
	viewController    = [[UDJViewController alloc] initWithNibName:@"UDJViewController" bundle:nil];
	self.navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [[UDJConnection sharedConnection] setNavigationController: self.navigationController];
	[self.navigationController setNavigationBarHidden:YES];
	//[self.navigationController setDelegate:self];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];

}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // leave any event we may be in
    [[UDJConnection sharedConnection] leaveEventRequest];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}




@end
