//
//  AssetCodingValueViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 21/04/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetData.h"

@interface AssetCodingValueViewController : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate> {
    
    NSMutableArray* conditionArr;
    NSMutableArray* operatorClassArr;
    NSMutableArray* operatorSubclassArr;
    NSMutableArray* operatorTypeArr;
    NSMutableArray* categoryArr;
    NSMutableArray* typeArr;
    
    NSMutableArray* operatorSubclassSlaveArr;
    NSMutableArray* operatorClassSlaveArr;

    UIPickerView *picker1;
    NSString* selectedPickerContent1;
    UIPickerView *picker2;
    NSString* selectedPickerContent2;
    UIPickerView *picker3;
    NSMutableDictionary* selectedPickerContent3;
    UIPickerView *picker4;
    NSMutableDictionary* selectedPickerContent4;
    UIPickerView *picker5;
    NSMutableDictionary* selectedPickerContent5;
    UIPickerView *picker6;
    NSString* selectedPickerContent6;
    
    BOOL showKeyboardAnimation;
    CGPoint viewCenter;
    
    NSString* selectedOperatorClassId;
}

@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UITextField *typeTxtField;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;

@property (strong, nonatomic) IBOutlet UITextField *conditionTxtField;
@property (strong, nonatomic) IBOutlet UITextField *operatorClassTxtField;
@property (strong, nonatomic) IBOutlet UITextField *operatorSubclassTxtField;
@property (strong, nonatomic) IBOutlet UITextField *operatorTypeTxtField;
@property (weak, nonatomic) IBOutlet UITextField *categoryTxtField;
@property (strong, nonatomic) IBOutlet UIButton *addAuditButton;
@property (strong, nonatomic) IBOutlet UILabel *conditionLabel;
@property (strong, nonatomic) IBOutlet UILabel *operatorClassLabel;
@property (strong, nonatomic) IBOutlet UILabel *operatorSubclassLabel;
@property (strong, nonatomic) IBOutlet UILabel *operatorTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;


- (IBAction)saveButtonTapped:(id)sender;
- (IBAction)addAuditButtonTapped:(id)sender;


@property BOOL isAssetToBeUpdated;
@property BOOL isAuditToBePreviewed;
@property (strong, nonatomic) AssetData* assetToUpdate;
@property BOOL unableToLocate;

- (IBAction)backButtonTapped:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *internerStatusImgView;

@end
