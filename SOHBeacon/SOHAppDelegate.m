//
//  SOHAppDelegate.m
//  SOHBeacon
//
//  Created by Ravi on 7/12/2013.
//  Copyright (c) 2013 SOH. All rights reserved.
//

#import "SOHAppDelegate.h"
#import "SOHBeaconHelper.h"


static NSString * const kUUID = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";
static NSString * const kRegionIdentifier = @"com.sydneyoperahouse";

//Green beacon  Major:40836 Minor:18108
//Purple beacon Major:29836 Minor:57466
//Blue beacon Major:394 Minor:58605

@interface SOHAppDelegate ()

@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic, strong) CLBeaconRegion *region;
@property (nonatomic, strong) CLBeacon *closestBeacon;
@property (nonatomic, strong) CLBeacon *currentBeacon;

@end

@implementation SOHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    NSUUID *estimoteUUID = [[NSUUID alloc] initWithUUIDString:kUUID];
    self.region = [[CLBeaconRegion alloc] initWithProximityUUID:estimoteUUID
                                                     identifier:kRegionIdentifier];
    
    // launch app when display is turned on and inside region
    self.region.notifyEntryStateOnDisplay = YES;
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        [_locationManager startMonitoringForRegion:self.region];
        
        // get status update right away for UI
        [_locationManager requestStateForRegion:self.region];
        
        // Start ranging for beacons
        [_locationManager startRangingBeaconsInRegion:self.region];
        
    } else {
        NSLog(@"This device does not support monitoring beacon regions");
    }
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region {
    
    NSString * relativeDistance;
    
    if (beacons.count > 0) {
        NSLog(@"Found beacons! %@", beacons);
        
        // TODO: Sort beacons by by distance
        _closestBeacon = [beacons objectAtIndex:0];
        
//        relativeDistance = [self proxmityString:_closestBeacon.proximity];
        relativeDistance = proxmityString(_closestBeacon.proximity);
        
        NSLog(@"%@, %@ • %@ • %.2fm • %li",
              _closestBeacon.major.stringValue,
              _closestBeacon.minor.stringValue, relativeDistance,
              _closestBeacon.accuracy,
              (long)_closestBeacon.rssi);
        
        
//        [self setProductOffer:_closestBeacon.minor];
        
        if ([_currentBeacon.minor isEqualToNumber:_closestBeacon.minor]) {
            NSLog(@"Current Beacon %@", _currentBeacon);
            //            if (_currentBeacon.proximity == CLProximityImmediate || _currentBeacon.proximity == CLProximityNear) {
            //                [self setProductOffer:_currentBeacon.minor];
            //
            //            }
            
            
        } else {
            // Moving to another beacon within the region
            NSLog(@"Current Beacon %@", _currentBeacon);
            
//            if (_isFBdataFetched) {
//                [self postDataToSpreadsheetViaForm];
//            }
            
            _currentBeacon = _closestBeacon;
        }
        
    } else {
        NSLog(@"No beacons found!");
        
    }
    
}

- (void)locationManager:(CLLocationManager *)manager
	  didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    
    NSLog(@"Beacon %@ UUID %@ major %@minor %@ identifier", self.region.proximityUUID, self.region.major, self.region.minor, self.region.identifier );
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        
        // don't send any notifications if app is open
        return;
    }
    
    // A user can transition in or out of a region while the application is not running.
    // When this happens CoreLocation will launch the application momentarily, call this delegate method
    // and we will let the user know via a local notification.
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    if(state == CLRegionStateInside) {
        NSLog(@"Inside Region %@", self.region.identifier);
        
        notification.alertBody = [NSString stringWithFormat:@"You're inside %@", self.region.identifier];
        //        notification.userInfo = @{@"beacon_minor": _closestBeacon.minor};
        
        
    } else if(state == CLRegionStateOutside) {
        NSLog(@"Outside Region %@", self.region.identifier);
        
        notification.alertBody = [NSString stringWithFormat:@"You're outside %@", self.region.identifier];
        
    } else {
        return;
    }
    
    // If the application is in the foreground, it will get a callback to application:didReceiveLocalNotification:.
    // If its not, iOS will display the notification to the user.
    //    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    
}


@end
