//
//  syncRecordsActionViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 11/11/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface syncRecordsActionViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISwitch *syncRecordSwitch;
- (IBAction)saveButtonTapped:(id)sender;
- (IBAction)backButtonTapped:(id)sender;
@property (strong, nonatomic) IBOutlet UISwitch *forceOfflineModeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *lockExistingRecordSwitch;


@end
