//
//  LogsViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 16/12/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *logsTxtView;
- (IBAction)backButtonTapped:(id)sender;

@end
