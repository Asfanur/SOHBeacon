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
    self.offerImage.image = [UIImage imageNamed:@"Asian tours-1360"];

}

-(void)viewWillAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:NO];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *moviePath = [bundle pathForResource:@"nelson-mandela" ofType:@"mp4"];
    NSURL *movieURL = [NSURL fileURLWithPath:moviePath];
    MPMoviePlayerViewController *theMovie = [[MPMoviePlayerViewController alloc]
                                             initWithContentURL: movieURL];
    [self presentMoviePlayerViewControllerAnimated:theMovie];

    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)setProductOffer:(NSNumber *)minor
//{
//    if ([minor isEqualToNumber:@58605]) {
//        self.offerImage.image = [UIImage imageNamed:@"Kenji Bento Box Opera_27.5.13 16327_edit"];
//        
//    } else if ([minor isEqualToNumber:@18108]) {
//        self.offerImage.image = [UIImage imageNamed:@"Asian tours-1360"];
//        
//    } else if ([minor isEqualToNumber:@57466]) {
//        self.offerImage.image = [NSURL URLWithString:@"SOH_TOURS_MANDARIN_v2"];
//        
//    } else {
//        self.offerImage.image = [UIImage imageNamed:@"purpleNotificationBig"];
//    }
//    
//}

@end
