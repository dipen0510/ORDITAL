//
//  FiltersViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 30/10/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "FiltersViewController.h"
#import "DataManager.h"
#import "SVProgressHUD.h"
#import "DefaultSetViewController.h"

@interface FiltersViewController ()

@end

@implementation FiltersViewController

@synthesize systemTxtField,plantSectionTxtField,defaultSetLabel,criticalityTextField,sourceDocsTxtField;

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
    
    
    
    plantSectionTxtField.text = [[DataManager sharedManager] getSelectedPlantSectionDetails];
    plantSectionTxtField.delegate = self;
    
    
    systemTxtField.text = [[DataManager sharedManager] getSelectedSystemDetails];
    systemTxtField.delegate = self;
    
    criticalityTextField.text = [[DataManager sharedManager] getSelectedCriticalityDetails];
    criticalityTextField.delegate = self;
    
    sourceDocsTxtField.text = [[DataManager sharedManager] getSelectedSourceDocsDetails];
    sourceDocsTxtField.delegate = self;
    
    viewCenter = self.view.center;
    showKeyboardAnimation = true;
    
    //iacValue = [[DataManager sharedManager] getSelectedIACDetails];
    
    /*if ([iacValue isEqualToString:@"True"]) {
        [self.iacSwitch setOn:YES];
    }
    else {
        [self.iacSwitch setOn:NO];
    }*/
    
    
    
    isSearchOnSet = [[DataManager sharedManager] getIsSearchOnSetDetails];
    [self.isSearchOnSetSwitch setOn:isSearchOnSet];
    
    if ([[[[DataManager sharedManager] getSelectedSetDetails] valueForKey:@"Id"] isEqualToString:@""]) {
        defaultSetValue = @"No List Selected";
    }
    else {
        defaultSetValue = [NSString stringWithFormat:@"Selected List - %@",[[[DataManager sharedManager] getSelectedSetDetails] valueForKey:@"Name"]];
    }
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
    
    self.isSearchOnSetSwitch.layer.cornerRadius = 16.0;
    self.isSearchOnPushListItemSwitch.layer.cornerRadius = 16.0;
    
    UIView *paddingView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    systemTxtField.leftView = paddingView1;
    systemTxtField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    plantSectionTxtField.leftView = paddingView2;
    plantSectionTxtField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    criticalityTextField.leftView = paddingView3;
    criticalityTextField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingView4 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    sourceDocsTxtField.leftView = paddingView4;
    sourceDocsTxtField.leftViewMode = UITextFieldViewModeAlways;
    
    [self.isSearchOnPushListItemSwitch setOn:[[DataManager sharedManager] getPunchListDetails]];
    
    [self setupInitialView];
}

-(void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBarHidden = true;
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    dict  = [[DataManager sharedManager] getAllDynamicLabelValues];
    
    NSString* listStr = @"List";
    
    if (dict.count > 0) {
        
        listStr = [dict valueForKey:@"LISTS"];
        if ([listStr isEqual:[NSNull null]]) {
            listStr = @"List";
        }
    }
    
    if ([[[[DataManager sharedManager] getSelectedSetDetails] valueForKey:@"Id"] isEqualToString:@""]) {
        defaultSetLabel.text = [NSString stringWithFormat:@"No %@ Selected",listStr];
    }
    else {
        defaultSetLabel.text = [NSString stringWithFormat:@"Selected %@ - %@",listStr,[[[DataManager sharedManager] getSelectedSetDetails] valueForKey:@"Name"]];
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
}

- (void) setupInitialView {
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    dict  = [[DataManager sharedManager] getAllDynamicLabelValues];
    
    if (dict.count > 0) {
        
        NSString* plantSectionStr = [dict valueForKey:@"PLANT_SECTION"];
        NSString* systemStr = [dict valueForKey:@"SYSTEM"];
        NSString* criticalityStr = [dict valueForKey:@"CRITICALITY"];
        NSString* sourceDocumentsStr = [dict valueForKey:@"SOURCE_DOCUMENTS"];
        NSString* listStr = [dict valueForKey:@"LISTS"];
        
        if (![plantSectionStr isEqual:[NSNull null]]) {
            self.plantSectionLabel.text = plantSectionStr;
        }
        if (![systemStr isEqual:[NSNull null]]) {
            self.systemLabel.text = systemStr;
        }
        if (![criticalityStr isEqual:[NSNull null]]) {
            self.criticalityLabel.text = criticalityStr;
        }
        if (![sourceDocumentsStr isEqual:[NSNull null]]) {
            self.sourceDocumentLabel.text = sourceDocumentsStr;
        }
        if (![listStr isEqual:[NSNull null]]) {
            self.searchOnlyInListLabel.text = [NSString stringWithFormat:@"Search Only in %@",listStr];
        }
        else {
            self.searchOnlyInListLabel.text = @"Search Only in List";
        }
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)textFieldDidEndEditing:(UITextField *)textField {
//    [textField resignFirstResponder];
//}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    showKeyboardAnimation = true;
    [textField endEditing:YES];
    return true;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    showKeyboardAnimation = true;
    [self.view endEditing:YES];
}

/*- (IBAction)iacSwitchTapped:(id)sender {
    if ([sender isOn]) {
        iacValue = @"True";
    }
    else {
        iacValue = @"False";
    }
}*/

- (IBAction)searchOnSetSwitchTapped:(id)sender {
    if ([sender isOn]) {
        isSearchOnSet = YES;
    }
    else {
        isSearchOnSet = NO;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"selectSetSegue"])
    {
        // Get reference to the destination view controller
        DefaultSetViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        [vc setSetContentArr:downloadedSetContent];
    }
     
}*/


- (IBAction)saveAndDownloadButtonTapped:(id)sender {
    [SVProgressHUD showWithStatus:@"Saving Filters" maskType:SVProgressHUDMaskTypeGradient];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
        NSLog(@"Done tapped");
        if (![plantSectionTxtField.text isEqualToString:[[DataManager sharedManager] getSelectedPlantSectionDetails]]) {
                
            [[DataManager sharedManager] savePlantSectionDetailsWithName:plantSectionTxtField.text];
                
        }
        
        if (![systemTxtField.text isEqualToString:[[DataManager sharedManager] getSelectedSystemDetails]]) {
            
            [[DataManager sharedManager] saveSystemDetailsWithName:systemTxtField.text];
            
        }
        
        if (![criticalityTextField.text isEqualToString:[[DataManager sharedManager] getSelectedCriticalityDetails]]) {
            
            [[DataManager sharedManager] saveCriticalityDetailsWithName:criticalityTextField.text];
            
        }
        
        if (![sourceDocsTxtField.text isEqualToString:[[DataManager sharedManager] getSelectedSourceDocsDetails]]) {
            
            [[DataManager sharedManager] saveSourceDocsDetailsWithName:sourceDocsTxtField.text];
            
        }
        
        //[[DataManager sharedManager] saveIACDetailsWithName:iacValue];
        [[DataManager sharedManager] saveIsSearchOnSetWithValue:isSearchOnSet];
        [[DataManager sharedManager] savePunchListWithValue:[self.isSearchOnPushListItemSwitch isOn]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Filters Saved"];
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


//TEXT FIELD DELEGATES
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.center.y>200 && showKeyboardAnimation) {
            CGPoint MyPoint = self.view.center;
            
            [UIView animateWithDuration:0.3
                             animations:^{
                                 
                                 self.view.center = CGPointMake(MyPoint.x, MyPoint.y - textField.center.y + 160);
                             }];
            
            showKeyboardAnimation=false;
    }

}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
        if (showKeyboardAnimation) {
            //CGPoint MyPoint = self.view.center;
            
            [UIView animateWithDuration:0.3
                             animations:^{
                                 
                                 self.view.center = CGPointMake(viewCenter.x, viewCenter.y);
                             }];
            
        }
}

@end
