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
#pragma mark Application lifecycle

// initObjectMappings: set up our RKObjectMappings for events, songs, etc.
- (void)initObjectMappings{
    // create our RKObjectManager: this is a singleton
    RKObjectManager *manager = [RKObjectManager objectManagerWithBaseURL:baseUrl];
    [manager setSerializationMIMEType:RKMIMETypeJSON]; // we're using JSON
    
    // set up event mappings
    // may only need this part for posting events
    /*RKObjectMapping *eventRequestMapping = [RKObjectMapping mappingForClass:[UDJEvent class]];
    [eventRequestMapping mapKeyPath:@"id" toAttribute:@"id"];
     ...
    [[manager mappingProvider] setSerializationMapping:[eventRequestMapping inverseMapping] forClass:[UDJEvent class]];*/
    
    RKObjectMapping *eventMapping = [RKObjectMapping mappingForClass:[UDJEvent class]];
    [eventMapping mapKeyPathsToAttributes:@"id", @"eventId", @"name", @"name", @"host_id", @"hostId", @"latitude", @"latitude", @"longitude", @"longitude", nil];
    [[manager mappingProvider] addObjectMapping:eventMapping];
    
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    // Override point for customization after application launch.
    
    // initialize udjConnection
    baseUrl = @"http://0.0.0.0:4897/udj";
    [[UDJConnection sharedConnection] initWithServerPrefix: baseUrl];
    
	//create a UDJViewController (the login screen), and make it the root view
	viewController    = [[UDJViewController alloc] initWithNibName:@"UDJViewController" bundle:nil];
	self.navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
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
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
