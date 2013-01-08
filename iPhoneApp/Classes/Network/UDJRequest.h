//
//  UDJRequest.h
//  UDJ
//
//  Created by Matthew Graf on 1/7/13.
//
//

#import <Foundation/Foundation.h>
#import "UDJRequestDelegate.h"

typedef enum UDJRequestMethod{
    UDJRequestMethodGET,
    UDJRequestMethodPUT,
    UDJRequestMethodPOST,
    UDJRequestMethodDELETE
}UDJRequestMethod;

@interface UDJRequest : NSObject

@property(nonatomic,strong) id<UDJRequestDelegate> delegate;
@property UDJRequestMethod method;

@end
