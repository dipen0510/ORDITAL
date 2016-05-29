//
//  UploadInfoViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 01/01/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import "UploadInfoViewController.h"
#import "DataManager.h"
#import "SVProgressHUD.h"

@interface UploadInfoViewController ()

@end

@implementation UploadInfoViewController

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
    
    self.assetCountLabel.text = [NSString stringWithFormat:@"%d",[[DataManager sharedManager] getAssetDataCount]];
    self.auditCountLabel.text = [NSString stringWithFormat:@"%d",[[DataManager sharedManager] getAuditDataCount]];
    
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
