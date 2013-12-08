//
//  SOHViewController.m
//  SOHBeacon
//
//  Created by Ravi on 7/12/2013.
//  Copyright (c) 2013 SOH. All rights reserved.
//

#import "SOHViewController.h"
#import "SOHUser.h"
#import <stdlib.h>

static NSString * const kUUID = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";
static NSString * const kRegionIdentifier = @"com.sydneyoperahouse";

@interface SOHViewController ()

@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic, strong) CLBeaconRegion *region;
@property (nonatomic, strong) CLBeacon *closestBeacon;
@property (nonatomic, strong) CLBeacon *currentBeacon;
@property (nonatomic, strong) UILocalNotification *notification;

@end

@implementation SOHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:YES];
    
}

-(ACAccountStore *) accountStore {
    
    if (!_accountStore) {
        _accountStore = [[ACAccountStore alloc]init];
    }
    
    return _accountStore;
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    if ([touch view] == self
        .imageTouch)
    {
        
        ACAccountType *FBaccountType= [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        
        NSString *key = @"671618406192240";
        NSDictionary *dictFB = [NSDictionary dictionaryWithObjectsAndKeys:key,ACFacebookAppIdKey,@[@"email"],ACFacebookPermissionsKey, nil];
        
        
        [self.accountStore requestAccessToAccountsWithType:FBaccountType options:dictFB completion:
         ^(BOOL granted, NSError *e) {
             
             NSLog(@"test");
             if (granted) {
                 
                 
                 
                 if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
                 {
                     NSArray *accounts = [self.accountStore accountsWithAccountType:FBaccountType];
                     //it will always be the last object with single sign on
                     NSArray *c = @[@"properties"];
                     self.facebookAccount = [accounts lastObject];
                     
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         NSLog(@"%@",[[[self.facebookAccount dictionaryWithValuesForKeys:c] objectForKey:@"properties"] objectForKey:@"ACPropertyFullName"]);
                         NSLog(@"emal %@",self.facebookAccount);
                         SOHUser *user = [SOHUser sharedInstance];
                         user.firstName = [[[self.facebookAccount dictionaryWithValuesForKeys:c] objectForKey:@"properties"] objectForKey:@"ACPropertyFullName"];
                         user.userEmail = self.facebookAccount.username;
                         
                         [self performSegueWithIdentifier:@"detailView" sender:self];
                         
                         
                     });
                     
                 } else {
                     
                     dispatch_async(dispatch_get_main_queue(), ^ {
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You Dont Have a Facebook account" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                         [alertView show];
                     });
                     
                 }
                 
                 
             } else {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Council would like to know who is reporting a problem in order to do that please go to settings and enable This App to use Facebook " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                     [alertView show];
                     
                     
                 });
                 
             }
         }];
        
        
    }
    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region {
    
    NSString * relativeDistance;
    SOHUser *user = [SOHUser sharedInstance];
    
//    SOHDetailViewController *SOHdvc = [[SOHDetailViewController alloc] init];
    
    if (beacons.count > 0) {
        NSLog(@"Found beacons! %@", beacons);
        
        // TODO: Sort beacons by by distance
        _closestBeacon = [beacons objectAtIndex:0];
        
        relativeDistance = [self proxmityString:_closestBeacon.proximity];
        //        relativeDistance = proxmityString(_closestBeacon.proximity);
        
        NSLog(@"%@, %@ • %@ • %.2fm • %li",
              _closestBeacon.major.stringValue,
              _closestBeacon.minor.stringValue, relativeDistance,
              _closestBeacon.accuracy,
              (long)_closestBeacon.rssi);
        
        
        //        [self setProductOffer:_closestBeacon.minor];
        [self setProductOffer:_closestBeacon.minor];
//        [self navigationController] pushViewController:self animated:YES];
        
        
        if ([_currentBeacon.minor isEqualToNumber:_closestBeacon.minor]) {
            NSLog(@"Current Beacon %@", _currentBeacon);
            //            if (_currentBeacon.proximity == CLProximityImmediate || _currentBeacon.proximity == CLProximityNear) {
            //                [self setProductOffer:_currentBeacon.minor];
            //
            //            }
            [self postToServer:@"1" beacon:@"beacon1" inbound:YES];

            
        } else {
            // Moving to another beacon within the region
            NSLog(@"Current Beacon %@", _currentBeacon);
            
            //            if (_isFBdataFetched) {
            //                [self postDataToSpreadsheetViaForm];
            //            }
            [[SOHUser sharedInstance] postDataToSpreadsheet:_currentBeacon withUserInfo:user];
            [self getOfferFromServer:@"beacon1" inbound:NO];

            
            _currentBeacon = _closestBeacon;
        }
        
    } else {
        NSLog(@"No beacons found!");
        
    }
    
}

- (void)locationManager:(CLLocationManager *)manager
	  didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    
    NSLog(@"Beacon %@ identifier ", region.identifier );
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        
        // don't send any notifications if app is open
        return;
    }
    
    // A user can transition in or out of a region while the application is not running.
    // When this happens CoreLocation will launch the application momentarily, call this delegate method
    // and we will let the user know via a local notification.
    _notification = [[UILocalNotification alloc] init];
    
    if(state == CLRegionStateInside) {
        NSLog(@"Inside Region %@", region.identifier);
        
        _notification.alertBody = [NSString stringWithFormat:@"You're inside %@", region.identifier];
        //        notification.userInfo = @{@"beacon_minor": _closestBeacon.minor};
        
        [self getOfferFromServer:@"beacon1" inbound:YES];

    } else if(state == CLRegionStateOutside) {
        NSLog(@"Outside Region %@", region.identifier);
        
        _notification.alertBody = [NSString stringWithFormat:@"You're outside %@", region.identifier];
        [self postToServer:@"1" beacon:@"beacon1" inbound:NO];

        [self getOfferFromServer:@"beacon1" inbound:NO];
    } else {
        return;
    }
    
    // If the application is in the foreground, it will get a callback to application:didReceiveLocalNotification:.
    // If its not, iOS will display the notification to the user.
    //    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    [[UIApplication sharedApplication] scheduleLocalNotification:_notification];
    
    
}

- (void)setProductOffer:(NSNumber *)minor
{
    if ([minor isEqualToNumber:@58605]) {
        self.imageTouch.image = [UIImage imageNamed:@"Kenji Bento Box Opera_27.5.13 16327_edit.jpg"];
        
    } else if ([minor isEqualToNumber:@18108]) {
        self.imageTouch.image = [UIImage imageNamed:@"Asian tours-1360.jpg"];
        
    } else if ([minor isEqualToNumber:@57466]) {
        int r = arc4random() * 10000;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://10.10.0.104:8080/stores/uploaded.jpg?cache=%d", r ]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        self.imageTouch.image = [UIImage imageWithData:data];
        
    } else {
        self.imageTouch.image = [UIImage imageNamed:@"purpleNotificationBig"];
    }
    
}

//// relative distance string value to beacon
- (NSString *)proxmityString:(CLProximity)proximity
{
    NSString *proximityString;
    
    switch (proximity) {
        case CLProximityNear:
            proximityString = @"Near";
            break;
        case CLProximityImmediate:
            proximityString = @"Immediate";
            break;
        case CLProximityFar:
            proximityString = @"Far";
            break;
        case CLProximityUnknown:
        default:
            proximityString = @"Unknown";
            break;
    }
    
    return proximityString;
}

- (void)postToServer:(NSString *)userId beacon:(NSString *)beacon inbound:(BOOL)inbound
{
    NSURL *url = [[NSURL alloc] initWithString:@"http://10.10.0.104:8080/UpdateUserRegistrationAtLocation"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *params = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@",
                        @"userId", userId,
                        @"beacon", beacon,
                        @"inbound", inbound ? @1 : @0];
    
    NSData *paramsData = [params dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:paramsData];
    
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if (data.length > 0 && connectionError == nil) {
                                   //                                    NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   //                                    NSLog(@"HTML = %@", html);
                                   NSLog(@"== posted data to Server==");
                                   
                               } else if (data.length == 0 && connectionError == nil) {
                                   NSLog(@"No data");
                               } else if (connectionError != nil) {
                                   NSLog(@"Connection Error %@", connectionError);
                               }
                               
                           }];
}


- (void)getOfferFromServer:(NSString *)beacon inbound:(BOOL)inbound
{
    NSURL *url = [[NSURL alloc] initWithString:@"http://10.10.0.104:8080/OfferForBeacon"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *params = [NSString stringWithFormat:@"%@=%@&%@=%@",
                        @"beacon", beacon,
                        @"inbound", inbound ? @1 : @0];
    
    NSData *paramsData = [params dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:paramsData];
    
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if (data.length > 0 && connectionError == nil) {
                                   //                                    NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   //                                    NSLog(@"HTML = %@", html);
                                   NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingAllowFragments error:nil];
                                   
//                                   [[NSString alloc ]initWithData:data encoding:NSUTF8StringEncoding]
                                   
                                   NSLog(@"== offer from server== %@", jsonData);
                                   NSLog(@"== offer from server== %@", jsonData);
                                   NSLog(@"== offer from server== %@", jsonData);
                                   NSLog(@"== offer from server== %@", jsonData);
                                   _notification = [[UILocalNotification alloc] init];

                                   _notification.alertBody = [jsonData objectForKey:@"beaconAlertText"];
                                   _notification.userInfo = jsonData;
                                   [[UIApplication sharedApplication] scheduleLocalNotification:_notification];

                                   
                               } else if (data.length == 0 && connectionError == nil) {
                                   NSLog(@"No data");
                               } else if (connectionError != nil) {
                                   NSLog(@"Connection Error %@", connectionError);
                               }
                               
                           }];
}



@end
