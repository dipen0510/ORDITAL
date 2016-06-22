//
//  PendingAuditDetailViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 22/06/16.
//  Copyright © 2016 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PendingAuditDetailViewController : UIViewController {
    NSMutableArray* fileArr;
}

@property (weak, nonatomic) IBOutlet UIImageView *auditImgView;
@property (weak, nonatomic) IBOutlet UIImageView *auditUploadStatusImgView;
@property (weak, nonatomic) IBOutlet UILabel *deviceFileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceFileSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceCreatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *serverBucketLabel;
@property (weak, nonatomic) IBOutlet UILabel *serverFileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serverFileSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *serverCreatedLabel;

@property (nonatomic, strong) AuditData* audit;


- (IBAction)checkSyncButtonTapped:(id)sender;
- (IBAction)backButtonTapped:(id)sender;
- (IBAction)uplaodButtonTapped:(id)sender;

@end
