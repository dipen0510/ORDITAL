//
//  FindAssetViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 24/09/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindAssetViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>{
    NSMutableArray *nameContentArr;
    NSMutableArray *descriptionContentArr;
    NSMutableArray *searchContentArr;
    int internetStatus;
    int selectedIndex;
    
    NSMutableArray *parentContentArr;
    NSMutableArray *childContentArr;
    
    
    NSMutableArray *assetListContentArr;
    BOOL isinternetForAssetList;
    
    NSString* iacValue;
    BOOL isSearchOnSet;
    
    NSString* errMsg;
    NSString* status;
    
    NSMutableArray* assetIdToBeSyncedArr;
    
    NSMutableArray* scrollAssetContentArr;
    
    int segmentSelectedIndex;
}
@property (weak, nonatomic) IBOutlet UILabel *internetStatusLabel;
@property (weak, nonatomic) IBOutlet UISearchBar *assetSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;

@property BOOL isSearchedContentToBeSelected;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
- (IBAction)segmentControlValueChanged:(id)sender;
- (IBAction)backButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *internetStatusImg;
@property (weak, nonatomic) IBOutlet UIView *uncompletedView;
@property (weak, nonatomic) IBOutlet UIView *completedView;
@property (weak, nonatomic) IBOutlet UILabel *uncompletedValLbl;
@property (weak, nonatomic) IBOutlet UILabel *uncompletedLbl;
@property (weak, nonatomic) IBOutlet UIImageView *uncompletedImg;
@property (weak, nonatomic) IBOutlet UIImageView *completedImg;
@property (weak, nonatomic) IBOutlet UILabel *completedValLbl;
@property (weak, nonatomic) IBOutlet UILabel *completedLbl;

@property (strong, nonatomic) NSString* todoCount;
@property (strong, nonatomic) NSString* doneCount;

@end
