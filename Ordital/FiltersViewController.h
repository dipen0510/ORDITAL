//
//  FiltersViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 30/10/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FiltersViewController : UIViewController<UITextFieldDelegate> {
    NSString* errMsg;
    NSString* status;
    //NSString* iacValue;
    BOOL isSearchOnSet;
    NSString* defaultSetValue;
    
    BOOL showKeyboardAnimation;
    CGPoint viewCenter;
}

@property (strong, nonatomic) IBOutlet UITextField *plantSectionTxtField;
@property (strong, nonatomic) IBOutlet UITextField *systemTxtField;
@property (strong, nonatomic) IBOutlet UILabel *defaultSetLabel;

//- (IBAction)iacSwitchTapped:(id)sender;
- (IBAction)searchOnSetSwitchTapped:(id)sender;
//@property (weak, nonatomic) IBOutlet UISwitch *iacSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *isSearchOnSetSwitch;
@property (weak, nonatomic) IBOutlet UITextField *criticalityTextField;
@property (weak, nonatomic) IBOutlet UITextField *sourceDocsTxtField;
- (IBAction)saveAndDownloadButtonTapped:(id)sender;
- (IBAction)backButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UISwitch *isSearchOnPushListItemSwitch;
@property (weak, nonatomic) IBOutlet UILabel *plantSectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *systemLabel;
@property (weak, nonatomic) IBOutlet UILabel *criticalityLabel;
@property (weak, nonatomic) IBOutlet UILabel *sourceDocumentLabel;
@property (weak, nonatomic) IBOutlet UILabel *searchOnlyInListLabel;

@end
