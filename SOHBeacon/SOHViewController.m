//
//  SOHViewController.m
//  SOHBeacon
//
//  Created by Ravi on 7/12/2013.
//  Copyright (c) 2013 SOH. All rights reserved.
//

#import "SOHViewController.h"

@interface SOHViewController ()

@end

@implementation SOHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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

- (IBAction)facebook:(id)sender {
    
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
                     NSLog(@"%@",[[[self.facebookAccount dictionaryWithValuesForKeys:c] objectForKey:@"properties"] objectForKey:@"fullname"]);
                     NSLog(@"emal %@",self.facebookAccount.username);
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
@end
