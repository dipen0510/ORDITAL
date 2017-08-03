//
//  PendingAuditDetailViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 22/06/16.
//  Copyright © 2016 Home. All rights reserved.
//

#import "PendingAuditDetailViewController.h"

@interface PendingAuditDetailViewController ()

@end

@implementation PendingAuditDetailViewController

@synthesize audit;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([audit isKindOfClass:[NSDictionary class]]) {
        
        AuditData* tmpAudit = [[AuditData alloc] init];
        
        tmpAudit.altitude = [[audit valueForKey:@"altitude"] doubleValue];
        tmpAudit.assetId = [audit valueForKey:@"assetId"];
        
        tmpAudit.assetName = [audit valueForKey:@"assetName"];
        tmpAudit.auditId = [audit valueForKey:@"auditId"];
        tmpAudit.auditType = [audit valueForKey:@"auditType"];
        tmpAudit.dateTime = [audit valueForKey:@"dateTime"];
        tmpAudit.imgURL = [audit valueForKey:@"imgURL"];
        tmpAudit.latitude = [[audit valueForKey:@"latitude"] doubleValue];
        tmpAudit.longitude = [[audit valueForKey:@"longitude"] doubleValue];
        tmpAudit.isUploaded = [[audit valueForKey:@"uploaded"] boolValue];
        
        audit = [[AuditData alloc] init];
        audit = tmpAudit;
        
    }
    
    
    
    [self setupInitialUI];
    
}

- (void) setupInitialUI {
    
    self.auditImgView.image = [[DataManager sharedManager] loadAuditImagewithPath:audit.imgURL];
    
    self.deviceFileNameLabel.text = [NSString stringWithFormat:@"File Name - %@",[[audit.imgURL componentsSeparatedByString:@"/"] lastObject]];
    
    NSData *imgData = UIImageJPEGRepresentation(self.auditImgView.image, 1.0);
    NSLog(@"Size of Image(bytes):%lu",(unsigned long)[imgData length]);
    
    self.deviceFileSizeLabel.text = [NSString stringWithFormat:@"File Size - %lu bytes",(unsigned long)[imgData length]];
    self.deviceCreatedLabel.text = [NSString stringWithFormat:@"Created - %@",audit.dateTime];
    
    if (audit.isUploaded) {
        self.auditUploadStatusImgView.hidden = NO;
        _deletePhotoFromQueueButton.hidden = YES;
    }
    else {
        self.auditUploadStatusImgView.hidden = YES;
        _deletePhotoFromQueueButton.hidden = NO;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)checkSyncButtonTapped:(id)sender {
    
    [SVProgressHUD showWithStatus:@"Checking Sync Status" maskType:SVProgressHUDMaskTypeGradient];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        fileArr = [[NSMutableArray alloc] init];
        [self listFilesAWS_S3WithBucketName:[[DataManager sharedManager] getBucket]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
        });
    });
    
    
    
    
}

- (IBAction)backButtonTapped:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)uplaodButtonTapped:(id)sender {
    
    [SVProgressHUD showWithStatus:@"Uploading Audit" maskType:SVProgressHUDMaskTypeGradient];
    [self startAWSUpload];
    
}

- (IBAction)deletePhotoFromQueueTapped:(id)sender {
    
    [[DataManager sharedManager] deleteAllAuditImagesWithAuditId:audit.auditId];
    [[DataManager sharedManager] deleteAuditWithId:audit.auditId];
    
    [self backButtonTapped:nil];
    
}

- (void) startAWSUpload {
    
    [[DataManager sharedManager] setIsAuditUploadInProgress:YES];
    
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
        
        [SVProgressHUD dismiss];
        
        if(task.error) {
            NSLog(@"Upload Failed");
            [SVProgressHUD showErrorWithStatus:@"Upload Failed. Please try again later"];
        }
        if (task.result) {
            NSLog(@"%@ uploaded successfully",audit.auditId);
            AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
            // The file uploaded successfully.
            [[DataManager sharedManager] updateUploadStatusForAuditId:audit.auditId];
            
            [SVProgressHUD showSuccessWithStatus:@"Audit uploaded successfully"];
            
        }
        return nil;
    }];
    
}

- (void) listFilesAWS_S3WithBucketName: (NSString *) bucketName
{
    AWSS3 *s3 = [AWSS3 defaultS3];
    
    AWSS3ListObjectsRequest *listObjectReq=[AWSS3ListObjectsRequest new];
    listObjectReq.bucket=bucketName;
    listObjectReq.prefix = audit.auditId;
    
    [[[s3 listObjects:listObjectReq] continueWithBlock:^id(AWSTask *task)
      {
          [SVProgressHUD dismiss];
          
          if(task.error)
          {
              NSLog(@"the request failed. error %@",task.error);
              [SVProgressHUD showErrorWithStatus:@"Status check failed. Please try again later"];
          }
          else if(task.result)
          {
              AWSS3ListObjectsOutput *listObjectsOutput=task.result;
              NSArray * files = listObjectsOutput.contents;
              NSLog(@"files: %@\ncount: %lu", files, (unsigned long)files.count);
              
              fileArr = [files mutableCopy];
              
              [self performSelectorOnMainThread:@selector(updateServerSpecificUI) withObject:nil waitUntilDone:YES];
              
          }
          return nil;
          
      }] waitUntilFinished];
}

- (void) updateServerSpecificUI {
    
    if (fileArr.count>0) {
        
        AWSS3Object* obj = [[AWSS3Object alloc] init];
        obj = [fileArr objectAtIndex:0];
        
        NSString *key = [obj key];
        NSLog(@"%@", key);
        
        self.auditUploadStatusImgView.hidden = NO;
        self.serverBucketLabel.hidden = NO;
        self.serverFileNameLabel.hidden = NO;
        //self.serverFileSizeLabel.hidden = NO;
        self.serverCreatedLabel.hidden = NO;
        self.serverBucketLabel.text = [NSString stringWithFormat:@"Bucket - %@",[[DataManager sharedManager] getBucket]];
        self.serverFileNameLabel.text = [NSString stringWithFormat:@"File Name - %@",key];
        //self.serverFileSizeLabel.text = [NSString stringWithFormat:@"File Size - %lu bytes",(unsigned long)obj.size];
        self.serverCreatedLabel.text = [NSString stringWithFormat:@"Created - %@",[obj lastModified]];
        
        _deletePhotoFromQueueButton.hidden = YES;
        
    }
    else {
        
        self.auditUploadStatusImgView.hidden = YES;
        self.serverBucketLabel.hidden = YES;
        self.serverFileNameLabel.hidden = YES;
        self.serverFileSizeLabel.hidden = YES;
        self.serverCreatedLabel.hidden = YES;
        _deletePhotoFromQueueButton.hidden = NO;
        
    }
    
    [SVProgressHUD showSuccessWithStatus:@"Status updated successfully"];
    
}
@end
