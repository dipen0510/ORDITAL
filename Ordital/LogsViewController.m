//
//  LogsViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 16/12/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "LogsViewController.h"
#import "DataManager.h"

@interface LogsViewController ()

@end

@implementation LogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.logsTxtView.text = [[DataManager sharedManager] logsString];
    
    UIBarButtonItem* navigation = [[UIBarButtonItem alloc]
                  initWithTitle:@"Clear Logs"
                  style:UIBarButtonItemStyleBordered
                  target:self
                  action:@selector(clearLogs:)];
    
    self.navigationItem.rightBarButtonItem = navigation;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
}

-(void) clearLogs:(id) sender {
    [[DataManager sharedManager] setLogsString:@""];
    self.logsTxtView.text = [[DataManager sharedManager] logsString];
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

- (IBAction)backButtonTapped:(id)sender {
    
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        
        MainViewController* controller = (MainViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"mainViewController"];
        
        [self.revealViewController setFrontViewController:controller animated:YES];
        
        //[self.navigationController pushViewController:controller animated:YES];
    
}
@end
