//
//  SOHTableViewController.m
//  SOHBeacon
//
//  Created by Asfanur Arafin on 8/12/2013.
//  Copyright (c) 2013 SOH. All rights reserved.
//

#import "SOHTableViewController.h"

static NSString* documents[] =
{   
    @"Neko Case.pdf",
    @"Dance At The House.pdf",
    @"Summer Sunset Tour.pdf",
    @"Life Of Mandela.mp4"
    
    
};

#define NUM_DOCS 4
#define kRowHeight 68.0f




@interface SOHTableViewController ()


@property (nonatomic, strong) DirectoryWatcher *docWatcher;
@property (nonatomic, strong) NSMutableArray *documentURLs;
@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;



@end


@implementation SOHTableViewController

- (void)setupDocumentControllerWithURL:(NSURL *)url
{
    if (self.docInteractionController == nil)
    {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.docInteractionController.delegate = self;
    }
    else
    {
        self.docInteractionController.URL = url;
    }
}




- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.docWatcher = [DirectoryWatcher watchFolderWithPath:[self applicationDocumentsDirectory] delegate:self];
    self.documentURLs = [NSMutableArray array];
    [self directoryDidChange:self.docWatcher];
    self.title = @"Today's Events";
}

-(void)viewWillAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:NO];
    
}



- (void)viewDidUnload
{
    self.documentURLs = nil;
    self.docWatcher = nil;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGesture
{
    if (longPressGesture.state == UIGestureRecognizerStateBegan)
    {
        NSIndexPath *cellIndexPath = [self.tableView indexPathForRowAtPoint:[longPressGesture locationInView:self.tableView]];
        
		NSURL *fileURL;
		if (cellIndexPath.section == 0)
        {
            
            fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:documents[cellIndexPath.row] ofType:nil]];
		}
        else
        {
            
            fileURL = [self.documentURLs objectAtIndex:cellIndexPath.row];
		}
        self.docInteractionController.URL = fileURL;
		
		[self.docInteractionController presentOptionsMenuFromRect:longPressGesture.view.frame
                                                           inView:longPressGesture.view
                                                         animated:YES];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return NUM_DOCS;
    }
    else
    {
        return self.documentURLs.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
    if (section == 0)
    {
        title = @"";
    }
    else
    {
        if (self.documentURLs.count > 0)
            title = @"This Months Events";
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSURL *fileURL;
    if (indexPath.section == 0)
    {
		fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:documents[indexPath.row] ofType:nil]];
    }
    else
    {
		fileURL = [self.documentURLs objectAtIndex:indexPath.row];
    }
	[self setupDocumentControllerWithURL:fileURL];
	
    NSArray *myArray = [[[fileURL path] lastPathComponent] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
    cell.textLabel.text = [myArray objectAtIndex:0];
    NSInteger iconCount = [self.docInteractionController.icons count];
    if (iconCount > 0)
    {
        
            cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",[myArray objectAtIndex:0]]];
        NSLog(@"%@",[[fileURL path] lastPathComponent]);
        
    }
    
    NSString *fileURLString = [self.docInteractionController.URL path];
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileURLString error:nil];
    NSInteger fileSize = [[fileAttributes objectForKey:NSFileSize] intValue];
    NSString *fileSizeStr = [NSByteCountFormatter stringFromByteCount:fileSize
                                                           countStyle:NSByteCountFormatterCountStyleFile];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", fileSizeStr, self.docInteractionController.UTI];
    
    // attach to our view any gesture recognizers that the UIDocumentInteractionController provides
    //cell.imageView.userInteractionEnabled = YES;
    //cell.contentView.gestureRecognizers = self.docInteractionController.gestureRecognizers;
    //
    // or
    // add a custom gesture recognizer in lieu of using the canned ones
    //
    UILongPressGestureRecognizer *longPressGesture =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [cell.imageView addGestureRecognizer:longPressGesture];
    cell.imageView.userInteractionEnabled = YES;    // this is by default NO, so we need to turn it on
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSURL *fileURL;
    if (indexPath.section == 0)
    {
        fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:documents[indexPath.row] ofType:nil]];
    }
    else
    {
        fileURL = [self.documentURLs objectAtIndex:indexPath.row];
    }
    [self setupDocumentControllerWithURL:fileURL];
    [self.docInteractionController presentPreviewAnimated:YES];
    
    
    // for case 3 we use the QuickLook APIs directly to preview the document -
    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    previewController.dataSource = self;
    previewController.delegate = self;
    
    // start previewing the document at the current section index
    previewController.currentPreviewItemIndex = indexPath.row;
    [[self navigationController] pushViewController:previewController animated:YES];
}



- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kRowHeight;
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
    NSInteger numToPreview = 0;
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedIndexPath.section == 0)
        numToPreview = NUM_DOCS;
    else
        numToPreview = self.documentURLs.count;
    
    return numToPreview;
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    // if the preview dismissed (done button touched), use this method to post-process previews
}

// returns the item that the preview controller should preview
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
    NSURL *fileURL = nil;
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedIndexPath.section == 0)
    {
        fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:documents[idx] ofType:nil]];
    }
    else
    {
        fileURL = [self.documentURLs objectAtIndex:idx];
    }
    
    return fileURL;
}


#pragma mark - File system support

- (NSString *)applicationDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher
{
	[self.documentURLs removeAllObjects];
	NSString *documentsDirectoryPath = [self applicationDocumentsDirectory];
    
    
    
	NSArray *documentsDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath
                                                                                              error:NULL];
    
    
	for (NSString* curFileName in [documentsDirectoryContents objectEnumerator])
	{
		NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:curFileName];
		NSURL *fileURL = [NSURL fileURLWithPath:filePath];
		BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
        if (!(isDirectory))
        {
            [self.documentURLs addObject:fileURL];
        } else {
            
            NSArray *documentsDirectoryInboxContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath
                                                                                                           error:NULL];
            for (NSString* curFileInboxName in [documentsDirectoryInboxContents objectEnumerator])
            {
                NSString *fileInboxPath = [filePath stringByAppendingPathComponent:curFileInboxName];
                NSURL *fileInboxURL = [NSURL fileURLWithPath:fileInboxPath];
                
                BOOL isInboxDirectory;
                [[NSFileManager defaultManager] fileExistsAtPath:fileInboxPath isDirectory:&isInboxDirectory];
                
                if (!(isInboxDirectory))
                {
                    [self.documentURLs addObject:fileInboxURL];
                }
            }
            
            
        }
	}
	
	[self.tableView reloadData];
}



@end
