//
//  LibrarySearchViewController.m
//  UDJ
//
//  Created by Matthew Graf on 12/6/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "LibrarySearchViewController.h"
#import "LibraryResultsController.h"
#import "SearchingViewController.h"
#import "UDJConnection.h"
#import "UDJEventData.h"
#import "UDJSongList.h"
#import <QuartzCore/QuartzCore.h>

@implementation LibrarySearchViewController

@synthesize searchField, searchButton, randomButton, playlistButton, searchingBackgroundView, searchingView, cancelButton, currentRequestNumber, globalData;

-(void)sendLibSearchRequest:(NSString *)param eventId:(NSInteger)eventId maxResults:(NSInteger)maxResults{
    RKClient* client = [RKClient sharedClient];
    
    //create url [GET] /udj/events/event_id/available_music?query=query{&max_results=maximum_number_of_results}
    NSString* urlString = client.baseURL;
    param = [param stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    urlString = [urlString stringByAppendingFormat:@"%@%d%@%@%@%d",@"/events/",eventId,@"/available_music?query=",param,@"&max_results=",maxResults];
    
    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
    request.queue = client.requestQueue;
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = globalData.headers;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++];
    
    //send request
    [request send]; 
}

-(void)sendRandomSongRequest:(NSInteger)eventId maxResults:(NSInteger)maxResults{
    RKClient* client = [RKClient sharedClient];
    
    //create url [GET] /udj/events/event_id/available_music/random_songs{?max_randoms=number_desired}
    NSString* urlString = client.baseURL;
    urlString = [urlString stringByAppendingFormat:@"%@%d%@%d",@"/events/",eventId,@"/available_music/random_songs?max_randoms=",maxResults];
    
    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
    request.queue = client.requestQueue;
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = globalData.headers;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++];
    
    //send request
    [request send]; 
}

// Show or hide the "Leaving event" view; active = YES will show the view
-(void) toggleSearchingView:(BOOL) active{
    searchingBackgroundView.hidden = !active;
}


-(BOOL) isValidSearchQuery:(NSString*)string{
    NSCharacterSet *alphaSet = [NSCharacterSet alphanumericCharacterSet];
    NSString* testString = [NSString stringWithString: string];
    testString = [testString stringByReplacingOccurrencesOfString:@" " withString:@""];
    BOOL valid = [[testString stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""];
    return valid;
}

- (IBAction) OnButtonClick:(id) sender {
	if(sender==searchButton){
        NSString* searchParam = searchField.text;
        if([self isValidSearchQuery:searchParam]){
            NSInteger eventIdParam = [UDJEventData sharedEventData].currentEvent.eventId;
            NSInteger maxResultsParam = 100;
            

            [self toggleSearchingView: YES];
            
            // have UDJConnection send a request
            self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
            [self sendLibSearchRequest:searchParam eventId:eventIdParam maxResults:maxResultsParam];
        }
        
        else{
            UIAlertView* invalidSearchParam = [[UIAlertView alloc] initWithTitle:@"Invalid Query" message:@"Your search query can only contain alphanumeric characters. This includes A-Z, 0-9." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [invalidSearchParam show];
        }
    }
    
    if(sender==randomButton){
        NSInteger eventIdParam = [UDJEventData sharedEventData].currentEvent.eventId;
        NSInteger maxResultsParam = 50;
        
        [self toggleSearchingView: YES];
        
        // send a random song request
        self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
        [self sendRandomSongRequest:eventIdParam maxResults:maxResultsParam];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];    
    // Release any cached data, images, etc that aren't in use.
}

-(IBAction)playlistButtonClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.globalData = [UDJData sharedUDJData];
    
    // initialize searching view
    searchingView.layer.cornerRadius = 8;
    searchingView.layer.borderColor = [[UIColor whiteColor] CGColor];
    searchingView.layer.borderWidth = 3;
    
    [self toggleSearchingView: NO];
    
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewWillAppear:(BOOL)animated{
    self.navigationController.toolbarHidden = YES;
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// makes the keyboard disappear
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == searchField) {
		[textField resignFirstResponder];
	}
	return NO;
}

-(void)handleLibSearchResults:(RKResponse *)response{
    UDJSongList* tempList = [UDJSongList new];
    RKJSONParserJSONKit* parser = [RKJSONParserJSONKit new];
    NSArray* songArray = [parser objectFromString:[response bodyAsString] error:nil];
    for(int i=0; i<[songArray count]; i++){
        NSDictionary* songDict = [songArray objectAtIndex:i];
        UDJSong* song = [UDJSong songFromDictionary:songDict isLibraryEntry:YES];
        [tempList addSong:song];
    }
    
    [self toggleSearchingView: NO];
    
    LibraryResultsController* libraryResultsController = [[LibraryResultsController alloc] initWithNibName:@"LibraryResultsController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:libraryResultsController animated:YES];
    
    // set tempList to be the tableList of the libsearch results screen
    libraryResultsController.resultList = tempList;
}

// Handle responses from the server
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response { 
    
    NSLog(@"status code %d", [response statusCode]);
    
    NSNumber* requestNumber = request.userData;
    
    //NSLog([NSString stringWithFormat: @"response number %d, waiting on %d", [requestNumber intValue], [currentRequestNumber intValue]]);
    
    if(![requestNumber isEqualToNumber: currentRequestNumber]) return;
    
    // check if the event has ended
    if(response.statusCode == 410){
        //[self resetToEventView];
    }
    else if ([request isGET]) {
        [self handleLibSearchResults: response];        
    }
    
    self.currentRequestNumber = [NSNumber numberWithInt: -1];
}

@end
