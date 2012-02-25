//
//  UDJMappableArray.h
//  UDJ
//
//  Created by Matthew Graf on 1/10/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>

// a class that can be mapped into a JSON array
@interface UDJMappableArray : NSObject{
    NSArray* array;
}

@property(nonatomic,strong) NSArray* array;

@end
