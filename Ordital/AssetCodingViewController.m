//
//  AssetCodingViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 19/04/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import "AssetCodingViewController.h"
#import "DataManager.h"

@interface AssetCodingViewController ()

@end

@implementation AssetCodingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSMutableArray* tmpArr = [[NSMutableArray alloc] init];
    tmpArr = [[DataManager sharedManager] getAssetCodingOptions];
    
    if([[tmpArr objectAtIndex:0] boolValue] == false) {
        [self.conditionSwitch setOn:false];
    }
    if([[tmpArr objectAtIndex:1] boolValue] == false) {
        [self.operatorTypeSwitch setOn:false];
    }
    if([[tmpArr objectAtIndex:2] boolValue] == false) {
        [self.operatorClassSwitch setOn:false];
    }
    if([[tmpArr objectAtIndex:3] boolValue] == false) {
        [self.operatorSubclassSwitch setOn:false];
    }
    if([[tmpArr objectAtIndex:4] boolValue] == false) {
        [self.categorySwitch setOn:false];
    }
    if([[tmpArr objectAtIndex:5] boolValue] == false) {
        [self.typeSwitch setOn:false];
    }
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
    
    
    self.conditionSwitch.layer.cornerRadius = 16.0;
    self.operatorClassSwitch.layer.cornerRadius = 16.0;
    self.operatorSubclassSwitch.layer.cornerRadius = 16.0;
    self.operatorTypeSwitch.layer.cornerRadius = 16.0;
    self.typeSwitch.layer.cornerRadius = 16.0;
    self.categorySwitch.layer.cornerRadius = 16.0;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)saveButtonTapped:(id)sender {
    
    [SVProgressHUD showSuccessWithStatus:@"Saved Successfully"];
    
    [[DataManager sharedManager] saveAssetCodingOptionsForCondition:self.conditionSwitch.isOn andOperatorType:self.operatorTypeSwitch.isOn andOperatorClass:self.operatorClassSwitch.isOn andOperatorSubclass:self.operatorSubclassSwitch.isOn andCategory:self.categorySwitch.isOn andType:self.typeSwitch.isOn];
    
    [self.navigationController popViewControllerAnimated:true];
    
}

- (IBAction)backButtonTapped:(id)sender {
    
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        
        MainViewController* controller = (MainViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"mainViewController"];
        
        [self.revealViewController setFrontViewController:controller animated:YES];
        
        //[self.navigationController pushViewController:controller animated:YES];
    
}
@end
