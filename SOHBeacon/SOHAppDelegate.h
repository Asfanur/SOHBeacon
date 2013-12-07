//
//  SOHAppDelegate.h
//  SOHBeacon
//
//  Created by Ravi on 7/12/2013.
//  Copyright (c) 2013 SOH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface SOHAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
