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
    LibrarySearchViewController* librarySearchViewController = [[LibrarySearchViewController alloc] initWithNibName:@"LibrarySearchViewController" bundle:[NSBundle mainBundle]];
    librarySearchViewController.title = NSLocalizedString(@"Library", @"Library");
    self.viewControllers = [NSArray arrayWithObjects:playlistViewController, librarySearchViewController, nil];
    
    self.tabBar.tintColor = [UIColor colorWithRed:(57.0/255.0) green:(97.0/255.0) blue:(127.0/255.0) alpha:1];
    
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
