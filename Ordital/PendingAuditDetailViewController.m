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
    
    [self setupInitialUI];
    
}

- (void) setupInitialUI {
    
    self.auditImgView.image = [[DataManager sharedManager] loadAuditImagewithPath:audit.imgURL];
    
    self.deviceFileNameLabel.text = [NSString stringWithFormat:@"File Name - %@",[[audit.imgURL componentsSeparatedByString:@"/"] lastObject]];
    
    NSData *imgData = UIImageJPEGRepresentation(self.auditImgView.image, 1.0);
    NSLog(@"Size of Image(bytes):%lu",(unsigned long)[imgData length]);
    
    self.deviceFileNameLabel.text = [NSString stringWithFormat:@"File Size - %lu",(unsigned long)[imgData length]];
    self.deviceCreatedLabel.text = [NSString stringWithFormat:@"Created - %@",audit.dateTime];
    
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
}

- (IBAction)backButtonTapped:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)uplaodButtonTapped:(id)sender {
    
    [SVProgressHUD showWithStatus:@"Uploading Audit" maskType:SVProgressHUDMaskTypeGradient];
    [self startAWSUpload];
    
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
            
            [SVProgressHUD showSuccessWithStatus:@"Audit uplaoded successfully"];
            
        }
        return nil;
    }];
    
}
@end
