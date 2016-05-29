//
//  EditAssetViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria  on 9/27/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileDownloadInfo.h"
#import "AppDelegate.h"

@interface EditAssetViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,NSURLSessionDelegate> {
    
    NSMutableArray *nameContentArr;
    NSMutableArray *descriptionContentArr;
    NSMutableArray *assetContentArr;
    
    NSMutableArray *conditionArr;
    NSMutableArray* operatorClassArr;
    NSMutableArray* operatorSubclassArr;
    NSMutableArray* operatorTypeArr;
    NSMutableArray* categoryArr;
    
    dispatch_queue_t myQueue;
    
    int isCancelled;
    
    NSString* errMsg;
    NSString* status;
    
    int uploadCounter;
}
@property (weak, nonatomic) IBOutlet UITableView *assetTblView;
- (IBAction)syncButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *syncCountLbl;
- (IBAction)backButtonTapped:(id)sender;

@end
