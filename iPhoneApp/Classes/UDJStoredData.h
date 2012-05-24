//
//  UDJStoredData.h
//  UDJ
//
//  Created by Matthew Graf on 5/23/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UDJStoredData : NSManagedObject

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSDate * ticketDate;

@end
