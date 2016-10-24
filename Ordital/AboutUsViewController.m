//
//  AboutUsViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 30/10/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "DataManager.h"
#import "AboutUsViewController.h"

@interface AboutUsViewController ()

@end

@implementation AboutUsViewController

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
    
    [[self.view viewWithTag:7] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"orangeBG"]]];
    
    NSString *version=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [self.versionInfoLabel setText:[NSString stringWithFormat:@"Version - %@",version]];
    
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

- (IBAction)backButtonTapped:(id)sender {
    
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        
        MainViewController* controller = (MainViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"mainViewController"];
        
        [self.revealViewController setFrontViewController:controller animated:YES];
        
        //[self.navigationController pushViewController:controller animated:YES];
    
}
@end
