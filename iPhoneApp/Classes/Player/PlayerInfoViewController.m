//
//  PlayerInfoViewController.m
//  UDJ
//
//  Created by Matthew Graf on 6/25/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "PlayerInfoViewController.h"

@interface PlayerInfoViewController ()

@end

@implementation PlayerInfoViewController

@synthesize playerNameField, playerPasswordField;
@synthesize useLocationSwitch, addressField, cityField, stateField, zipCodeField;
@synthesize playerStateSwitch;

-(void)toggleAddressFields:(BOOL)showing{
    
    BOOL enabled = showing;
    addressField.enabled = enabled;
    cityField.enabled = enabled;
    zipCodeField.enabled = enabled;
    stateField.enabled = enabled;
    
    float alpha = enabled ? 1 : 0.5;
    addressField.alpha = alpha;
    cityField.alpha = alpha;
    zipCodeField.alpha = alpha;
    stateField.alpha = alpha; 
    
}

-(IBAction)locationSwitchValueChanged:(id)sender{
    BOOL enabled = ![(UISwitch*)sender isOn];
    
    [self toggleAddressFields: enabled];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self toggleAddressFields: NO];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
