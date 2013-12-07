//
//  SOHUser.h
//  SOHBeacon
//
//  Created by Ravi on 7/12/2013.
//  Copyright (c) 2013 SOH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class SOHUser;

@interface SOHUser : NSObject

@property (nonatomic, strong)NSString * userId; // Facebook userId
@property (nonatomic, strong)NSString * firstName;
@property (nonatomic, strong)NSString * lastName;
@property (nonatomic, strong)NSString * userGender;
@property (nonatomic, strong)NSString * userLocation;
@property (nonatomic, strong)NSString * userEmail;

- (void)postDataToSpreadsheet:(CLBeacon *)closesBeacon withUserInfo:(SOHUser *)user;

@end
