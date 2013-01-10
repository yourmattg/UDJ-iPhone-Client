//
//  UDJResponse.h
//  UDJ
//
//  Created by Matthew Graf on 1/7/13.
//
//

#import <Foundation/Foundation.h>

@interface UDJResponse : NSObject

@property(nonatomic,strong) NSDictionary* allHeaderFields;
@property NSInteger statusCode;
@property(nonatomic,strong) NSString* bodyAsString;

-(BOOL)isOK;

@end
