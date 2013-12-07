//
//  SOHBeaconHelper.m
//  SOHBeacon
//
//  Created by Ravi on 7/12/2013.
//  Copyright (c) 2013 SOH. All rights reserved.
//

#import "SOHBeaconHelper.h"


NSString * proxmityAsString(CLProximity proximity)
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