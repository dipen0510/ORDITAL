//
//  AssetCodingViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 19/04/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssetCodingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch *conditionSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *operatorClassSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *operatorSubclassSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *operatorTypeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *typeSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *categorySwitch;

- (IBAction)saveButtonTapped:(id)sender;
- (IBAction)backButtonTapped:(id)sender;


@end
