//
//  LocationManager.h
//  UDJ
//
//  Created by Zachary Halasz on 12/30/11.
//  Copyright 2011 University of Illinois. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject<CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    float latitude, longitude;
}

- (float)getLongitude;
- (float)getLatitude;

@end