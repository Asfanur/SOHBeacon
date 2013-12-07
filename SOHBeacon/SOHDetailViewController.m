//
//  SOHDetailViewController.m
//  SOHBeacon
//
//  Created by Asfanur Arafin on 7/12/2013.
//  Copyright (c) 2013 SOH. All rights reserved.
//

#import "SOHDetailViewController.h"

@interface SOHDetailViewController ()

@end

@implementation SOHDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:NO];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
