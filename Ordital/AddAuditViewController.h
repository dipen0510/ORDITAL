//
//  AddAuditViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 21/09/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuditData.h"
#import <CoreLocation/CoreLocation.h>
#import "DataManager.h"
#import "AssetData.h"

@interface AddAuditViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate>{
    CLLocation* currentLocation;
    CLLocationManager* locationManager;
    NSMutableArray* auditContentArr;

    
    AuditData* auditObj;
    NSMutableArray * auditDataArr;
    NSMutableArray* auditTypeArr;
    
    
    BOOL isMoreButtonTapped;
    
    int auditTypeCount;
    int lastPageAuditTypeCount;
    int numberOfPages;
    int currentPage;

}

@property (weak, nonatomic) IBOutlet UIImageView *equipmentImgView;
@property (weak, nonatomic) IBOutlet UIImageView *tagImgView;
@property (weak, nonatomic) IBOutlet UIImageView *nameplateImgView;

@property (strong, nonatomic) AssetData* assetObj;
@property BOOL isAssetToBeUpdated;

@property NSString* currentAssetId;
@property NSString* currentAssetName;

@property (strong, nonatomic) IBOutlet UIView *equipmentCountView;
@property (strong, nonatomic) IBOutlet UIView *tagCountView;
@property (strong, nonatomic) IBOutlet UIView *nameplateCountView;
- (IBAction)onDoneAudit:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *equipmentCountLbl;
@property (strong, nonatomic) IBOutlet UILabel *tagCoutnLbl;
@property (strong, nonatomic) IBOutlet UILabel *nameplateCountLbl;
- (IBAction)backButtonTapped:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *internetStatusImgView;
- (IBAction)moreButtonTapped:(id)sender;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *equipmentHeightContraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tagHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *nameplateHeightConstraint;

@property BOOL isMoreAuditAdded;

@property (weak, nonatomic) IBOutlet UILabel *equipmentNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *tagNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *nameplateNameLbl;

@property (strong, nonatomic) NSMutableArray * tmpAuditDataArr;
@end
