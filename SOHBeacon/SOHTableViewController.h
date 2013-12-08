//
//  SOHTableViewController.h
//  SOHBeacon
//
//  Created by Asfanur Arafin on 8/12/2013.
//  Copyright (c) 2013 SOH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import <MobileCoreServices/MobileCoreServices.h>


#import "DirectoryWatcher.h"


@interface SOHTableViewController : UITableViewController <QLPreviewControllerDataSource,
QLPreviewControllerDelegate,
DirectoryWatcherDelegate,
UIDocumentInteractionControllerDelegate>


@end
