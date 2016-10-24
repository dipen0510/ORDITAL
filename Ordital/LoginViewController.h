//
//  LoginViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 24/09/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UIWebViewDelegate,UIAlertViewDelegate> {
    
    NSString* status;
    NSString* errMsg;
    
}

@property (weak, nonatomic) IBOutlet UIWebView *loginWebView;

- (void)loadRequestFromString:(NSString*)urlString;
- (IBAction)backButtonTapped:(id)sender;

@end
