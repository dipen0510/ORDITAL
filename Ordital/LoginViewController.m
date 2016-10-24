//
//  LoginViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 24/09/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "LoginViewController.h"
#import "DataManager.h"
#import "SVProgressHUD.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = false;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.loginWebView.delegate = self;
    NSString* connection = [[DataManager sharedManager] selectedEnvironmentSettings];
    NSString *theURL;
    
    
    if ([[[DataManager sharedManager] selectedConnectionSettings] isEqualToString:@"ENTERPRISE"]) {
        connection = @"ordital.force.com";
    }
    
    if (connection && !([connection isEqualToString:@""])) {
        if ([[DataManager sharedManager] restEnv]) {
            theURL = [NSString stringWithFormat:@"%@%@&%@=%@",PRODUCTION_LOGIN_URL,[connection stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],HEADER_REQUEST_KEY,HEADER_REQUEST_VALUE];
        }
        else {
            theURL = [NSString stringWithFormat:@"%@%@&%@=%@",SANDOBOX_LOGIN_URL,[connection stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],HEADER_REQUEST_KEY,HEADER_REQUEST_VALUE];
        }
        
    }
    else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Connection Missing" message:@"Please enter Connection in Settings to proceed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    [self loadRequestFromString:theURL];
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
}

- (void)loadRequestFromString:(NSString*)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.loginWebView loadRequest:urlRequest];
}

- (IBAction)backButtonTapped:(id)sender {
    
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        
        MainViewController* controller = (MainViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"mainViewController"];
        
        [self.revealViewController setFrontViewController:controller animated:YES];
        
        //[self.navigationController pushViewController:controller animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString *url = webView.request.URL.absoluteString;
    if (!([url rangeOfString:@"oauth_callback.php?code="].location == NSNotFound)) {
        NSString  *htmlContent = [webView stringByEvaluatingJavaScriptFromString: @"document.body.innerHTML"];
        
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData: [htmlContent dataUsingEncoding:NSUTF8StringEncoding]
                                        options: NSJSONReadingMutableContainers
                                          error: nil];
        
        [[DataManager sharedManager] saveAuthToken:[dict valueForKey:@"token"] withInstanceURL:[dict valueForKey:@"instance_url"] withIdentity:[dict valueForKey:@"identity"] withBucket:[dict valueForKey:@"bucket"] andUsername:[dict valueForKey:@"user_name"]];
        
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
        [self startDynamicLabelAPI];
        
        
        
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void) startDynamicLabelAPI {
    
    if ([[DataManager sharedManager] isInternetConnectionAvailable] && [[DataManager sharedManager] isLoggedIn]) {
        
        [SVProgressHUD showWithStatus:@"Updating Local Settings" maskType:SVProgressHUDMaskTypeGradient];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSURL *theURL;
            if ([[DataManager sharedManager] restEnv]) {
                theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=getDynamicLable&instance_url=%@&access_token=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken]]];
            }
            else {
                theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=getDynamicLable&instance_url=%@&access_token=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken]]];
            }
            NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
            [theRequest setValue:HEADER_REQUEST_VALUE forHTTPHeaderField:HEADER_REQUEST_KEY];
            NSData *returnData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];
            NSError *error;
            NSDictionary* responseData = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers error:&error];
            status = [responseData valueForKey:@"status"];
            if (!error && !status) {
                [[DataManager sharedManager] saveDynamicLabelValues:[responseData valueForKey:@"key_lable"]];
            }
            else {
                if (status) {
                    errMsg = [responseData valueForKey:@"msg"];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                if (!status) {
                    
                    [SVProgressHUD showSuccessWithStatus:@"I am successfully logged in"];
                    
                    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                    MainViewController* controller = (MainViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"mainViewController"];
                    [self.revealViewController setFrontViewController:controller animated:YES];
                    
                    
                }
                else {
                    if (errMsg) {
                        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",errMsg]];
                    }
                    else{
                        [SVProgressHUD showErrorWithStatus:@"Downloading settings failed"];
                    }
                    status = nil;
                }
                
            });
        });
    }
    else{
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No Login Credentials Found" message:@"Please login to app after turning on internet settings to view this section" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
