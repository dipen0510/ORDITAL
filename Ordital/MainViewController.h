//
//  MainViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 20/09/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"
#import <DropboxSDK/DropboxSDK.h>
#import "FileDownloadInfo.h"
#import "AppDelegate.h"

@interface MainViewController : UIViewController<UIAlertViewDelegate,DBRestClientDelegate,NSURLSessionDelegate> {
    NSMutableArray* downloadedSetContent;
    NSString* errMsg;
    NSString* status;
    NSMutableArray* noteContentArr;
    
    NSMutableArray *assetListContentArr;
    
    NSMutableArray* auditContentArr;
    NSMutableArray* auditArr;
    int uploadCounter;
    
    BOOL isinternetForAssetList;
    
    int assetDatacount;
    int currentSavingIndex;
    
    NSMutableArray* tmpAuditArr;
    
    NSString* todayCount;
    NSString* todoCount;
    NSString* doneCount;
    
    NSMutableArray* offlineTodayArr;
    NSMutableArray* offlineTodoArr;
    NSMutableArray* offlineDoneArr;
}

- (IBAction)listAssetButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
- (IBAction)signInButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *syncUpdateButton;
- (IBAction)syncButtonTapped:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *uploadInfoButton;
@property (weak, nonatomic) IBOutlet UIImageView *internetStatusImg;
@property (weak, nonatomic) IBOutlet UIButton *slideMenuButon;
@property (weak, nonatomic) IBOutlet UIButton *findButton;
@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *findButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *listButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *syncImage;
@property (weak, nonatomic) IBOutlet UILabel *syncLabel;
@property (weak, nonatomic) IBOutlet UILabel *syncTxtLabel;
@property (weak, nonatomic) IBOutlet UILabel *uploadsValLbl;
@property (strong, nonatomic) IBOutlet UILabel *downloadsValLbl;
@property (weak, nonatomic) IBOutlet UIImageView *uploadsImage;
@property (weak, nonatomic) IBOutlet UILabel *uploadsTxtLbl;

@end
