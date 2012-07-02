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

@synthesize mainScrollView;
@synthesize textFieldArray;
@synthesize playerNameField, playerPasswordField;
@synthesize useLocationSwitch, addressField, cityField, stateField, zipCodeField;
@synthesize playerStateSwitch;
@synthesize shadeView;

#pragma mark - Text fields

-(void)initTextFields{
    for(int i=0; i < [textFieldArray count]; i++){
        UITextField* textField= [textFieldArray objectAtIndex: i];
        textField.delegate = self;
        textField.tag = i;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSInteger yCoord = textField.frame.origin.y;
    [self.mainScrollView scrollRectToVisible: CGRectMake(0, yCoord-6, 320, 367) animated:YES];
    
    [self.mainScrollView bringSubviewToFront: self.shadeView];
    self.shadeView.hidden = NO;
    [self.mainScrollView bringSubviewToFront: textField];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSInteger index = textField.tag + 1;
    
    // if this is the last field, hide the keyboard
    if(index >= [textFieldArray count]){
        [textField resignFirstResponder];
        self.shadeView.hidden = YES;
    }
    
    // set focus to the next field
    else{
        UITextField* nextField = [textFieldArray objectAtIndex: index];
        [nextField becomeFirstResponder];        
    }
    
    return NO;
}

#pragma mark - Address fields

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

#pragma mark - View lifecycle

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
    
    [self.mainScrollView setContentSize: CGSizeMake(320, 700)];
    
    // initialize shade view
    self.shadeView.frame = CGRectMake(0, 0, 320, 700);
    self.shadeView.hidden = YES;
    [self.mainScrollView addSubview: self.shadeView];
    
    [self initTextFields];
    
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
