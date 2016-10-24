//
//  settingsViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria  on 9/27/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface settingsViewController : UIViewController<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    UIPickerView *picker;
    NSMutableDictionary* selectedPickerContent;
    
    NSString* errMsg;
    NSString* status;
    
    NSMutableArray* conditionArr;
    NSMutableArray* operatorClassArr;
    NSMutableArray* operatorSubclassArr;
    NSMutableArray* operatorTypeArr;
    NSMutableArray* categoryArr;
    
}

@property (weak, nonatomic) IBOutlet UITextField *plantTxtLabel;
- (IBAction)saveButtonTapped:(id)sender;
@property (strong, nonatomic) NSMutableArray *plantContentArr;
@property (weak, nonatomic) IBOutlet UINavigationItem *plantHeaderTitle;
@property (weak, nonatomic) IBOutlet UILabel *selectPlantLabel;

@end
