//
//  AddNoteViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria  on 10/6/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddNoteViewController : UIViewController<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    UIPickerView *picker;
    NSString* selectedPickerContent;
}

@property (weak, nonatomic) IBOutlet UITextField *noteTextField;
- (IBAction)addNoteButtonTapped:(id)sender;
@property (strong, nonatomic) NSMutableArray *noteContentArr;
@property (strong, nonatomic) NSString *currentAssetId;

@end
