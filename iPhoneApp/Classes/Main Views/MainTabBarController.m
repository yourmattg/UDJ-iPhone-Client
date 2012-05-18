//
//  MainTabBarController.m
//  UDJ
//
//  Created by Matthew Graf on 5/16/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "MainTabBarController.h"
#import "PlaylistViewController.h"
#import "LibrarySearchViewController.h"
#import "RandomViewController.h"
#import "SearchViewController.h"

@implementation MainTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib. 
    PlaylistViewController* playlistViewController = [[PlaylistViewController alloc] initWithNibName:@"NewPlaylistViewController" bundle:[NSBundle mainBundle]];
    playlistViewController.title = NSLocalizedString(@"Playlist", @"Playlist");
    SearchViewController* searchViewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:[NSBundle mainBundle]];
    searchViewController.title = NSLocalizedString(@"Library", @"Library");
    RandomViewController* randomViewController = [[RandomViewController alloc] initWithNibName:@"RandomViewController" bundle:[NSBundle mainBundle]];
    randomViewController.title = NSLocalizedString(@"Random", @"Random");
    self.viewControllers = [NSArray arrayWithObjects:playlistViewController, searchViewController, randomViewController, nil];
    
    self.tabBar.tintColor = [UIColor colorWithRed:(35.0/255.0) green:(59.0/255.0) blue:(79.0/255.0) alpha:1];
    
    // set tab bar images
    UITabBarItem* playlistItem = [self.tabBar.items objectAtIndex: 0];
    [playlistItem setImage: [UIImage imageNamed: @"playlisticon.png"]];
    
    UITabBarItem* libraryItem = [self.tabBar.items objectAtIndex: 1];
    [libraryItem setImage: [UIImage imageNamed: @"libraryicon.png"]];
    
    UITabBarItem* randomItem = [self.tabBar.items objectAtIndex: 2];
    [randomItem setImage: [UIImage imageNamed: @"randomicon.png"]];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
