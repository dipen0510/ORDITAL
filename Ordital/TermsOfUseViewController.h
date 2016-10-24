//
//  TermsOfUseViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 04/01/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TermsOfUseViewController : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)backButtonTapped:(id)sender;

@end
