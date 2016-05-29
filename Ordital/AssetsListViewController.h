//
//  AssetsListViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 21/10/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssetsListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate> {
    NSMutableArray *nameContentArr;
    NSMutableArray *descriptionContentArr;
    int selectedIndex;
    
    NSMutableArray* scrollAssetContentArr;
    NSMutableArray* assetListContentArr;
    NSString* errMsg;
    NSString* status;
    
    int viewNotLoadedForFirstTime;
    
    int segmentSelectedIndex;
    NSMutableArray* assetStatusArr;
    
    BOOL isSecondTime;
    int pendingTodayAssetCount;
    int todoDiffCount;
    int doneDiffCount;
    
}
@property (strong, nonatomic) IBOutlet UITableView *assetListTblView;
@property (strong, nonatomic) NSMutableArray *searchContentArr;
@property BOOL internetStatus;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;

- (IBAction)segmentControlValueChanged:(id)sender;

- (IBAction)backButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *internetStatusImg;
@property (weak, nonatomic) IBOutlet UIView *uncompletedView;
@property (weak, nonatomic) IBOutlet UIView *completedView;
@property (weak, nonatomic) IBOutlet UIView *todayView;
@property (weak, nonatomic) IBOutlet UILabel *uncompletedValLbl;
@property (weak, nonatomic) IBOutlet UILabel *uncompletedLbl;
@property (weak, nonatomic) IBOutlet UIImageView *uncompletedImg;
@property (weak, nonatomic) IBOutlet UIImageView *completedImg;
@property (weak, nonatomic) IBOutlet UILabel *completedValLbl;
@property (weak, nonatomic) IBOutlet UILabel *completedLbl;
@property (weak, nonatomic) IBOutlet UIImageView *todayImg;
@property (weak, nonatomic) IBOutlet UILabel *todayValLbl;
@property (weak, nonatomic) IBOutlet UILabel *todayLbl;

@property (strong, nonatomic) NSString* todayCount;
@property (strong, nonatomic) NSString* todoCount;
@property (strong, nonatomic) NSString* doneCount;

@property (strong, nonatomic) NSMutableArray* offlineTodayArr;
@property (strong, nonatomic) NSMutableArray* offlineTodoArr;
@property (strong, nonatomic) NSMutableArray* offlineDoneArr;

@end
