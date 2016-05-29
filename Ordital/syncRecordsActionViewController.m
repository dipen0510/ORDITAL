//
//  syncRecordsActionViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 11/11/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "syncRecordsActionViewController.h"
#import "DataManager.h"
#import "SVProgressHUD.h"

@interface syncRecordsActionViewController ()

@end

@implementation syncRecordsActionViewController

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
    [self.syncRecordSwitch setOn:[[DataManager sharedManager] getSyncRecordsDetails]];
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
    self.syncRecordSwitch.layer.cornerRadius = 16.0;
    self.forceOfflineModeSwitch.layer.cornerRadius = 16.0;
    self.lockExistingRecordSwitch.layer.cornerRadius = 16.0;
    
    [self.lockExistingRecordSwitch setOn:[[DataManager sharedManager] getLockRecordsDetails]];
    [self.forceOfflineModeSwitch setOn:[[DataManager sharedManager] getForceOfflineDetails]];
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

- (IBAction)saveButtonTapped:(id)sender {
    [SVProgressHUD showWithStatus:@"Saving Action" maskType:SVProgressHUDMaskTypeGradient];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[DataManager sharedManager] saveSyncRecordsWithValue:self.syncRecordSwitch.isOn];
        [[DataManager sharedManager] saveLockRecordsWithValue:self.lockExistingRecordSwitch.isOn];
        [[DataManager sharedManager] saveForceOfflineWithValue:self.forceOfflineModeSwitch.isOn];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Action Saved"];
            [self.navigationController popViewControllerAnimated:YES];
        });
    });
}

- (IBAction)backButtonTapped:(id)sender {
    
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        
        MainViewController* controller = (MainViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"mainViewController"];
        
        [self.revealViewController setFrontViewController:controller animated:YES];
        
        //[self.navigationController pushViewController:controller animated:YES];
    
}
@end
