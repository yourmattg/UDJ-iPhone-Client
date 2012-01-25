//
//  UDJEventGoerList.h
//  UDJ
//
//  Created by Matthew Graf on 1/18/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UDJEventGoer.h"

@interface UDJEventGoerList : NSObject{
    NSMutableArray* eventGoerList;
}

-(UDJEventGoer*)eventGoerAtIndex:(NSInteger)i;
-(void)addEventGoer:(UDJEventGoer*)eventGoer;
-(NSInteger)count;

@property(nonatomic,retain) NSMutableArray* eventGoerList;

@end
