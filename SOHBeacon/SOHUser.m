//
//  SOHUser.m
//  SOHBeacon
//
//  Created by Ravi on 7/12/2013.
//  Copyright (c) 2013 SOH. All rights reserved.
//

#import "SOHUser.h"
#import "SOHBeaconHelper.h"

static NSString * const kSpreadsheetURL = @"https://docs.google.com/forms/d/1H-_Iw5t7A4rKOktPMBlTSUrtMvwmCcbN7D2Qe0DxIT8/formResponse";


@implementation SOHUser

+ (id)sharedInstance {
    static SOHUser *userInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userInstance = [[self alloc] init];
    });
    return userInstance;
}


- (SOHUser *)init
{
    self = [super init];
    if (self) {
        //Custom initializations
    }
    
    return self;
}

#pragma mark - GDataAPI

// spreadsheet cells
# define EST_UUID       @"entry.1684824394"
# define MAJOR          @"entry.637100903"
# define MINOR          @"entry.995003597"
# define RSSI           @"entry.1713907850"
# define FB_ID          @"entry.2126786069"
# define FB_FIRST_NAME  @"entry.2007134088"
# define FB_LAST_NAME   @"entry.751109484"
# define FB_GENDER      @"entry.590995976"
# define FB_LOCATION    @"entry.1585663854"
# define FB_EMAIL       @"entry.539490866"


- (void)postDataToSpreadsheet:(CLBeacon *)closestBeacon withUserInfo:(SOHUser *)user;
{
    NSURL *url = [[NSURL alloc] initWithString:kSpreadsheetURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSLog(@"%@ User Data", user);
    NSString *relativeDistance = [self proxmityString:closestBeacon.proximity];
//    NSString *relativeDistance = proxmityString(closestBeacon.proximity);
    
    //&draftResponse=[]&pageHistory=0&fbzx=4798022380500650763
    NSString *params = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",
                        EST_UUID, closestBeacon.proximityUUID.UUIDString,
                        MAJOR, closestBeacon.major.stringValue,
                        MINOR, closestBeacon.minor.stringValue,
                        RSSI, relativeDistance,
                        FB_ID, user.userId,
                        FB_FIRST_NAME, user.firstName,
                        FB_LAST_NAME, user.lastName,
                        FB_GENDER, user.userGender,
                        FB_LOCATION, user.userLocation,
                        FB_EMAIL, user.userEmail ];
    
    NSData *paramsData = [params dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:paramsData];
    
    //    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    //    [connection start];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if (data.length > 0 && connectionError == nil) {
                                   //                                    NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   //                                    NSLog(@"HTML = %@", html);
                                   NSLog(@"== Successfully posted data ==");
                                   
                               } else if (data.length == 0 && connectionError == nil) {
                                   NSLog(@"No data");
                               } else if (connectionError != nil) {
                                   NSLog(@"Connection Error %@", connectionError);
                               }
                               
                           }];
    
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


@end
