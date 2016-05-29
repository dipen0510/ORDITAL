//
//  AboutUsViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 30/10/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutUsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *versionInfoLabel;

- (IBAction)backButtonTapped:(id)sender;
@end
