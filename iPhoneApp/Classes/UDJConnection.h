//
//  UDJConnection.h
//  UDJ
//
//  Created by Matthew Graf on 6/19/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestKit.h"

@interface UDJConnection : NSObject <RKRequestDelegate>


@property(nonatomic,weak) UIViewController* songAddDelegate;

@end
