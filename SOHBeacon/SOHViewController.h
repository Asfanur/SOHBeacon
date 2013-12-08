//
//  SOHViewController.h
//  SOHBeacon
//
//  Created by Ravi on 7/12/2013.
//  Copyright (c) 2013 SOH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <CoreLocation/CoreLocation.h>



@interface SOHViewController : UIViewController <CLLocationManagerDelegate>
@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccount *facebookAccount;
@property (strong, nonatomic) ACAccount *twitterAccount;
@property (weak, nonatomic) IBOutlet UIImageView *imageTouch;


 
@end
