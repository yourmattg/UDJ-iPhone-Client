//
//  LocationManager.m
//  UDJ
//
//  Created by Zachary Halasz on 12/30/11.
//  Copyright 2011 University of Illinois. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager

- (id)init
{
    self = [super init];
    if (self) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
        [locationManager startUpdatingLocation];
    }
    
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    latitude = newLocation.coordinate.latitude;
    longitude = newLocation.coordinate.longitude;
}

- (float) getLatitude {
    return latitude;
}

- (float) getLongitude {
    return longitude;
}

@end