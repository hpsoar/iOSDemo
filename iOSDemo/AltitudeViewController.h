//
//  altitudeViewController.h
//  Altitude
//
//  Created by Matt Gabriel on 03/11/2013.
//  Copyright (c) 2013 Matt Gabriel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface AltitudeViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *heightLabel;
@property (strong, nonatomic) IBOutlet UIImageView *heightLabelBG;
@property (strong, nonatomic) IBOutlet UILabel *label;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *startLocation;

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation;

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error;

-(float)mapping:(float)currentValue
          inMin:(float)inMin
          inMax:(float)inMax
         outMin:(float)outMin
         outMax:(float)outMax;

@end

