//
//  PreviewPendingAuditsViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 01/01/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import "PreviewPendingAuditsViewController.h"
#import "DataManager.h"
#import "PendingAuditDetailViewController.h"

@interface PreviewPendingAuditsViewController ()

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSMutableArray *arrFileDownloadData;

-(int)getFileDownloadInfoIndexWithTaskIdentifier:(unsigned long)taskIdentifier;
-(void)initializeFileDownloadDataArray;

@end

@implementation PreviewPendingAuditsViewController

@synthesize auditCollectionView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    auditContentArr = [[NSMutableArray alloc] init];
    auditImageArr = [[NSMutableArray alloc] init];
    auditContentArr = [[DataManager sharedManager] getAllAuditData];
    for (int i = 0; i<[auditContentArr count]; i++) {
        NSDictionary* currentAudit = [auditContentArr objectAtIndex:i];
        [auditImageArr addObject:[[DataManager sharedManager] loadAuditImagewithPath:[currentAudit valueForKey:@"imgURL"]]];
    }
    [auditCollectionView reloadData];
    
    
    if ([[DataManager sharedManager] isAuditUploadInProgress]) {
       
        self.resyncButton.hidden = YES;
        
    }
    else {
        
        self.resyncButton.hidden = NO;
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [auditImageArr count];
}
// 2

// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"pendingAuditPreviewCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
    recipeImageView.image = [auditImageArr objectAtIndex:indexPath.row];
    
    UIImageView *uploadImageView = (UIImageView *)[cell viewWithTag:101];
    
    AuditData* audit = [[AuditData alloc] init];
    audit = [auditContentArr objectAtIndex:indexPath.row];
    
    if (audit.isUploaded) {
        uploadImageView.hidden = NO;
    }
    else {
        uploadImageView.hidden = YES;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    selectedIndex = indexPath.row;
    
    //[self performSegueWithIdentifier:@"showFullScreenView" sender:nil];
    [self performSegueWithIdentifier:@"showAuditDetailSegue" sender:nil];
    
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
//    if ([segue.identifier isEqualToString:@"showFullScreenView"]) {
//        
//        PendingAuditFullScreenViewController* controller = [segue destinationViewController];
//        
//        
//        [controller setAuditContentArr:auditContentArr];
//        [controller setAuditImgArr:auditImageArr];
//        
//        
//        [controller setSelectedIndex:selectedIndex];
//        
//    }
    if ([segue.identifier isEqualToString:@"showAuditDetailSegue"]) {
        
        PendingAuditDetailViewController* controller = [segue destinationViewController];
        
        AuditData* tmpAudit = [[AuditData alloc] init];
        tmpAudit = [auditContentArr objectAtIndex:selectedIndex];
        
        [controller setAudit:tmpAudit];
        
    }
    
}


- (IBAction)backButtonTapped:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)purgeButtonTapped:(id)sender {
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Are you sure you want to resync all photos." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        [self initializeFileDownloadDataArray];
        
        if ([auditArr count]>0 && [[DataManager sharedManager] getSyncRecordsDetails]) {
            
            if ([[DataManager sharedManager] isInternetConnectionAvailableForAudits] && [[DataManager sharedManager] isLoggedIn]) {
                
                [SVProgressHUD showWithStatus:@"Re-sync in progress"];
                //[self startSingleUpload];
                [self startAWSUpload];
                
            }
        }
        
        
//        NSMutableArray* syncedAuditArr = [[NSMutableArray alloc] initWithArray:[[DataManager sharedManager] getCompletedAuditData]];
//        
//        for (int i = 0; i < syncedAuditArr.count; i++) {
//            
//            AuditData* audit = [[AuditData alloc] init];
//            audit = [syncedAuditArr objectAtIndex:i];
//            
//            [[DataManager sharedManager] deleteAllAuditImagesWithAuditId:audit.auditId];
//            [[DataManager sharedManager] deleteAuditWithId:audit.auditId];
//            
//        }
        
    }
    
}


- (void) startAWSUpload {
    
    [[DataManager sharedManager] setIsAuditUploadInProgress:YES];
    
    AuditData* audit = [[AuditData alloc] init];
    audit = [auditArr objectAtIndex:uploadCounter];
    
    NSString* urlStr = [[[DataManager sharedManager] auditImagePath] stringByAppendingPathComponent:[[audit.imgURL componentsSeparatedByString:@"/"] lastObject]];
    
    NSURL* fileUrl = [NSURL fileURLWithPath:urlStr];
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    //upload the image
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.body = fileUrl;
    uploadRequest.bucket = [[DataManager sharedManager] getBucket];
    uploadRequest.key = [NSString stringWithFormat:@"%@.jpg",audit.auditId];
    uploadRequest.contentType = @"image/jpeg";
    uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
        if(task.error) {
            NSLog(@"Upload Failed");
            [[DataManager sharedManager] setIsAuditUploadInProgress:NO];
            uploadCounter = 0;
        }
        if (task.result) {
            NSLog(@"%@ uploaded successfully",audit.auditId);
            AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
            // The file uploaded successfully.
            [[DataManager sharedManager] updateUploadStatusForAuditId:audit.auditId];
            uploadCounter++;
            
            if (uploadCounter < auditArr.count) {
                [self startAWSUpload];
            }
            else {
                [[DataManager sharedManager] setIsAuditUploadInProgress:NO];
            }
            
        }
        return nil;
    }];
    
}


- (void) startSingleUpload {
    
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.ordital.ordital"];
    sessionConfiguration.HTTPMaximumConnectionsPerHost = 5;
    
    
    self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                 delegate:self
                                            delegateQueue:nil];
    
    
    [[DataManager sharedManager] setIsAuditUploadInProgress:YES];
    
    
    //for (int i = 0; i<auditCount; i++) {
    
    
    // Get the FileDownloadInfo object being at the cellIndex position of the array.
    FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:uploadCounter];
    
    // The isDownloading property of the fdi object defines whether a downloading should be started
    // or be stopped.
    if (!fdi.isUploading) {
        // This is the case where a download task should be started.
        
        // Create a new task, but check whether it should be created using a URL or resume data.
        if (fdi.taskIdentifier == -1) {
            // If the taskIdentifier property of the fdi object has value -1, then create a new task
            // providing the appropriate URL as the download source.
            
            AuditData* audit = [[AuditData alloc] init];
            audit = [auditArr objectAtIndex:uploadCounter];
            
            
            [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nUploading %d of %ld Images\n%@ Image upload started at %@",(uploadCounter+1),[auditArr count],[[audit.imgURL componentsSeparatedByString:@"/"] lastObject],[NSDate date]]]];
            
            NSString *post = [self getJsonStringForSingleSyncUpdatesWithAudit:audit];
            NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
            
            NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
            
            
            NSURL *url = [NSURL URLWithString:fdi.uploadSource];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                               timeoutInterval:300.0];
            
            [request setHTTPMethod:@"POST"];
            [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request addValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request addValue:HEADER_REQUEST_VALUE forHTTPHeaderField:HEADER_REQUEST_KEY];
            [request setHTTPBody:postData];
            
            
            
            fdi.uploadTask = [self.session dataTaskWithRequest:request];
            // Keep the new task identifier.
            fdi.taskIdentifier = fdi.uploadTask.taskIdentifier;
            
            // Start the task.
            [fdi.uploadTask resume];
        }
        else{
            
        }
    }
    
    // Change the isDownloading property value.
    fdi.isUploading = !fdi.isUploading;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
    
}


#pragma mark - Private method implementation

-(void)initializeFileDownloadDataArray{
    
    self.arrFileDownloadData = [[NSMutableArray alloc] init];
    auditContentArr = [[NSMutableArray alloc] init];
    auditArr = [[NSMutableArray alloc] init];
    uploadCounter = 0;
    
    NSMutableArray* assetArr = [[DataManager sharedManager] getPendingAuditData];
    auditArr = [[DataManager sharedManager] getPendingAuditData];
    
    NSString*theURL;
    if ([[DataManager sharedManager] restEnv]) {
        theURL =  [NSString stringWithFormat:@"%@?action_type=syncImages&instance_url=%@&access_token=%@&bucket=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[[DataManager sharedManager] getBucket]];
    }
    else {
        theURL =  [NSString stringWithFormat:@"%@?action_type=syncImages&instance_url=%@&access_token=%@&bucket=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[[DataManager sharedManager] getBucket]];
    }
    
    for (int i = 0 ; i < assetArr.count; i++) {
        
        AuditData* asset = [[AuditData alloc] init];
        asset = [assetArr objectAtIndex:i];
        
        [auditContentArr addObject:asset];
        
        [self.arrFileDownloadData addObject:[[FileDownloadInfo alloc] initWithFileTitle:asset.auditId andFileURL:asset.imgURL andDownloadSource:theURL]];
        
    }
}


-(int)getFileDownloadInfoIndexWithTaskIdentifier:(unsigned long)taskIdentifier{
    int index = 0;
    for (int i=0; i<[self.arrFileDownloadData count]; i++) {
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:i];
        if (fdi.taskIdentifier == taskIdentifier) {
            index = i;
            break;
        }
    }
    
    return index;
}



#pragma mark - NSURLSession Delegate method implementation

-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    
    [self performSelectorOnMainThread:@selector(handleIfFailed) withObject:nil waitUntilDone:YES];
    
}
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error != nil) {
        NSLog(@"Upload completed with error: %@", [error localizedDescription]);
        [SVProgressHUD dismiss];
        uploadCounter = 0;
        [[DataManager sharedManager] setIsAuditUploadInProgress:NO];
    }
    else{
        NSLog(@"Upload finished successfully.");
        
        uploadCounter++;
        
        // Change the flag values of the respective FileDownloadInfo object.
        int index = [self getFileDownloadInfoIndexWithTaskIdentifier:task.taskIdentifier];
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:index];
        
        fdi.isUploading = NO;
        fdi.uploadComplete = YES;
        
        // Set the initial value to the taskIdentifier property of the fdi object,
        // so when the start button gets tapped again to start over the file download.
        fdi.taskIdentifier = -1;
        
        // In case there is any resume data stored in the fdi object, just make it nil.
        fdi.taskResumeData = nil;
        
        
        [self performSelectorOnMainThread:@selector(auditProgressCompleted:) withObject:fdi.fileTitle waitUntilDone:YES];
        
        
        [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\n%@ Image upload success at %@",[[fdi.fileURL componentsSeparatedByString:@"/"] lastObject],[NSDate date]]]];
        
        
        if (uploadCounter == auditContentArr.count) {
            
            [self performSelectorOnMainThread:@selector(handleAllUploadCommpleted) withObject:nil waitUntilDone:YES];
            
        }
        else {
            [self performSelectorOnMainThread:@selector(startSingleUpload) withObject:nil waitUntilDone:YES];
        }
    }
    
}


-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    if (totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown) {
        NSLog(@"Unknown transfer size");
    }
    else{
        // Locate the FileDownloadInfo object among all based on the taskIdentifier property of the task.
        int index = [self getFileDownloadInfoIndexWithTaskIdentifier:downloadTask.taskIdentifier];
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:index];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Calculate the progress.
            fdi.uploadProgress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
            
            
        }];
    }
}


-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    // Check if all download tasks have been finished.
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        
        if ([uploadTasks count] == 0) {
            if (appDelegate.backgroundTransferCompletionHandler != nil) {
                // Copy locally the completion handler.
                void(^completionHandler)() = appDelegate.backgroundTransferCompletionHandler;
                
                // Make nil the backgroundTransferCompletionHandler.
                appDelegate.backgroundTransferCompletionHandler = nil;
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // Call the completion handler to tell the system that there are no other background transfers.
                    completionHandler();
                    
                    // Show a local notification when all downloads are over.
                    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                    localNotification.alertBody = @"All files have been uploaded!";
                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                    uploadCounter = 0;
                    [[DataManager sharedManager] setIsAuditUploadInProgress:NO];
                }];
            }
        }
    }];
}

- (void) handleAllUploadCommpleted {
    
    [SVProgressHUD dismiss];
    [SVProgressHUD showSuccessWithStatus:@"Synced successfully"];
    uploadCounter = 0;
    [[DataManager sharedManager] setIsAuditUploadInProgress:NO];
    
}

- (void) handleIfFailed {
    
    [SVProgressHUD dismiss];
    [SVProgressHUD showErrorWithStatus:@"Sync Failed"];
    uploadCounter = 0;
    [[DataManager sharedManager] setIsAuditUploadInProgress:NO];
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nImage upload failed at %@",[NSDate date]]]];
    
}

- (void)auditProgressCompleted:(NSString *)auditId {
    
    [[DataManager sharedManager] deleteAllAuditImagesWithAuditId:auditId];
    
    [[DataManager sharedManager] deleteAuditWithId:auditId];
}

-(NSString*)getJsonStringForSingleSyncUpdatesWithAudit:(AuditData*) audit{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self prepareDictonaryForSingleSyncUpdatesWithAsset:audit] options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(NSDictionary *)prepareDictonaryForSingleSyncUpdatesWithAsset:(AuditData *)audit {
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:audit.auditId forKey:@"name"];
    
    UIImage* currImg = [[DataManager sharedManager] loadAuditImagewithName:[[audit.imgURL componentsSeparatedByString:@"/"] lastObject]];
    if (currImg) {
        [dict setObject:[[DataManager sharedManager] convertImageToString:currImg] forKey:@"image"];
    }
    else {
        [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nImage not found in DB for Audit id  %@",audit.auditId]]];
    }
    return dict;
}

@end
