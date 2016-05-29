//
//  PreSettingsViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 29/09/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreSettingsViewController : UIViewController<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>{
    NSMutableArray* downloadedPlantContent;
    NSString* errMsg;
    NSString* status;
    
    UIPickerView *picker;
    NSString* selectedPickerContent;
    NSMutableArray* typeContentArr;
    
    UIPickerView *connectionPicker;
    NSString* connectionSelectedPickerContent;
    NSMutableArray* connectionContentArr;
    
    NSMutableArray* conditionArr;
    
}
@property (weak, nonatomic) IBOutlet UILabel *plantStatusLabel;
- (IBAction)editButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *environmentTextField;
@property (weak, nonatomic) IBOutlet UISlider *imgQualitySlider;
@property (weak, nonatomic) IBOutlet UITextField *typeTxtField;
@property (weak, nonatomic) IBOutlet UILabel *imgQualityLabel;
- (IBAction)sliderValueChanged:(id)sender;

@property (strong, nonatomic) IBOutlet UITextField *connectionComboBox;

- (IBAction)saveButtonTapped:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *plantEditButton;
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;
- (IBAction)backButtonTapped:(id)sender;


@end
