//
//  CreateAssetViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 20/09/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetData.h"

@interface CreateAssetViewController : UIViewController<UITextFieldDelegate,UIScrollViewDelegate>{
    AssetData* assetObj;
    UIPickerView *picker;
    NSString* selectedPickerContent;
    NSMutableArray* typeContentArr;
    UIBarButtonItem *navigation;
    NSMutableArray *childrenContentArr;
    
    NSMutableDictionary* parentContent;
    
    UISwipeGestureRecognizer* swipeLeft;
    UISwipeGestureRecognizer* swipeRight;
    
    CGRect frame1;
    CGRect frame2;
    
}
@property (weak, nonatomic) IBOutlet UITextField *assetNameTxtField;
@property (weak, nonatomic) IBOutlet UITextField *plantNameTxtField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTxtField;
@property (weak, nonatomic) IBOutlet UITextField *tagTxtField;
@property (weak, nonatomic) IBOutlet UITextField *parentTxtField;
@property BOOL isAssetToBeUpdated;
@property BOOL isAuditToBePreviewed;
@property (strong, nonatomic) AssetData* assetToUpdate;
- (IBAction)addAuditButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *addAuditButton;
//@property (weak, nonatomic) IBOutlet UIButton *addNoteButton;
//- (IBAction)unableToLocateSwitchTapped:(id)sender;
@property (strong, nonatomic) IBOutlet UISwitch *unableToLocateSwitch;
@property (strong, nonatomic) IBOutlet UILabel *unableToLocateLabel;
@property (weak, nonatomic) IBOutlet UITextField *typeTxtField;

@property (strong, nonatomic) NSMutableArray *scrollContentArr;
@property int currentAssetViewType;
@property int currentScrollAssetIndex;
@property int currentInternetStatus;
@property BOOL isNewChildAsset;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
- (IBAction)rightButtonTapped:(id)sender;
- (IBAction)leftButtonTapped:(id)sender;
- (IBAction)addChildAssetButtonTapped:(id)sender;
- (IBAction)searchParentAssetButtonTapped:(id)sender;
- (IBAction)saveAssetButtonTapped:(id)sender;

-(IBAction) viewChilds:(id) sender;
@property (strong, nonatomic) IBOutlet UIButton *downArrowButton;
@property (strong, nonatomic) IBOutlet UIButton *upArrowButton;
@property (strong, nonatomic) IBOutlet UIButton *addChildAssetButton;
@property (strong, nonatomic) IBOutlet UIButton *searchParentAssetButton;
- (IBAction)upArrowButtonTapped:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *parentLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)assetCodingButtonTapped:(id)sender;

- (IBAction)backButtonTapped:(id)sender;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *assetCodingTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *assetCodingRightArrowTopCOnstrain;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *assetNameTxtFieldTrailConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *addPhotoTopConstraint;
@property (strong, nonatomic) IBOutlet UIImageView *internetStatusImgView;
@property (weak, nonatomic) IBOutlet UIButton *assetCodingRightArrowButton;
@property (weak, nonatomic) IBOutlet UILabel *assetCodingLabel;
@property (weak, nonatomic) IBOutlet UILabel *createAssetNavLbl;
@property (weak, nonatomic) IBOutlet UIImageView *circleImgView;
@property (weak, nonatomic) IBOutlet UILabel *editAssetCountLbl;

@property (weak, nonatomic) IBOutlet UILabel *assetNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;

@property BOOL isDoneTodayPreview;

@end
