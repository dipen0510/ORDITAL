//
//  settingsViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria  on 9/27/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "settingsViewController.h"
#import "SVProgressHUD.h"
#import "DataManager.h"

@interface settingsViewController ()

@end

@implementation settingsViewController

@synthesize plantContentArr,plantTxtLabel;

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
    
    selectedPickerContent = [[plantContentArr objectAtIndex: 0] objectAtIndex:0];
    
    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 480, 320, 270)];
    picker.delegate = self;
    picker.dataSource = self;
    picker.showsSelectionIndicator = YES;
    
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton.frame = CGRectMake(0, 0, 60, 33);
    [customButton addTarget:self action:@selector(pickerViewDoneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    customButton.showsTouchWhenHighlighted = YES;
    //[customButton setTitle:@"Done" forState:UIControlStateNormal];
    [customButton setImage:[UIImage imageNamed:@"checkbox-selected.png"] forState:UIControlStateNormal];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 33)];
    [lbl setText:@"Choose an Option"];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setFont:[UIFont systemFontOfSize:14.0]];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:lbl];
    
    UIBarButtonItem *barCustomButton =[[UIBarButtonItem alloc] initWithCustomView:customButton];
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolBar.items = [[NSArray alloc] initWithObjects:item,flexibleSpace,barCustomButton,nil];
    //[picker addSubview:toolBar];
    
    plantTxtLabel.inputView = picker;
    plantTxtLabel.inputAccessoryView = toolBar;
    plantTxtLabel.delegate = self;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    plantTxtLabel.leftView = paddingView;
    plantTxtLabel.leftViewMode = UITextFieldViewModeAlways;
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
    
    conditionArr = [[NSMutableArray alloc] init];
    operatorClassArr = [[NSMutableArray alloc] init];
    operatorSubclassArr = [[NSMutableArray alloc] init];
    operatorTypeArr = [[NSMutableArray alloc] init];
    categoryArr = [[NSMutableArray alloc] init];
    
    [self setupInitialView];
}

- (void) setupInitialView {
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    dict  = [[DataManager sharedManager] getAllDynamicLabelValues];
    
    if (dict.count > 0) {
        
        NSString* plantStr = [dict valueForKey:@"PLANT"];
        
        if (![plantStr isEqual:[NSNull null]]) {
            self.selectPlantLabel.text = [NSString stringWithFormat:@"Select %@",plantStr];
            self.plantHeaderTitle.title = plantStr;
        }
        
    }
    
}

-(void)pickerViewDoneButtonTapped:(id)sender{
    NSLog(@"Done tapped");
    plantTxtLabel.text = [selectedPickerContent valueForKey:@"Name"];
    [plantTxtLabel resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//animate the picker out of view
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [plantTxtLabel becomeFirstResponder];
}

- (UIView*)pickerView:(UIPickerView *)thePickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    
    
    UIView* v = [[UIView alloc] init];
    [thePickerView setBackgroundColor:[UIColor whiteColor]];
    
    CGSize rowSize = [thePickerView rowSizeForComponent:component];
    CGRect labelRect = CGRectMake (0, 0, rowSize.width, rowSize.height);
    
    UILabel* l1 = [[UILabel alloc] initWithFrame:labelRect];
    l1.font = [UIFont systemFontOfSize:14.0]; // choose desired size
    [l1 setTextAlignment:NSTextAlignmentCenter];
    [v addSubview: l1];
    
    [v sizeToFit];
    
    NSDictionary* currentSet = [[plantContentArr objectAtIndex: 0] objectAtIndex:row];
    [l1 setText: [currentSet valueForKey:@"Name"]];
    
    if([thePickerView selectedRowInComponent:component] == row) //this is the selected one, change its color
    {
        [l1 setBackgroundColor:[UIColor colorWithRed:1 green:0.37 blue:0 alpha:1.0]];
    }
    else {
        [l1 setBackgroundColor:[UIColor whiteColor]];
    }
    
    return v;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [[plantContentArr objectAtIndex:0] count];
}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSDictionary* currentSet = [[plantContentArr objectAtIndex: 0] objectAtIndex:row];
    return [currentSet valueForKey:@"Name"];
}

// Do something with the selected row.
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"You selected this: %@", [[[plantContentArr objectAtIndex: 0] objectAtIndex:row] valueForKey:@"Name"]);
    selectedPickerContent = [[plantContentArr objectAtIndex: 0] objectAtIndex:row];
    [pickerView reloadComponent:component];
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
    
    if ([plantTxtLabel.text isEqualToString:@""]) {
        
        [SVProgressHUD showErrorWithStatus:@"Select a plant to proceed"];
        
    }
    else {
        
        [SVProgressHUD showWithStatus:@"Saving Settings" maskType:SVProgressHUDMaskTypeGradient];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString* opUnitName = [selectedPickerContent valueForKey:@"Operating_unit_Name"] ;
            
            if (!opUnitName || [opUnitName isKindOfClass:[NSNull class]]) {
                opUnitName = @"";
            }
            
            [[DataManager sharedManager] savePlantDetailsWithId:[selectedPickerContent valueForKey:@"Id"] withName:[selectedPickerContent valueForKey:@"Name"] andOperatingUnit:opUnitName];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self getAssetCodingData];
            });
        });
        
    }
    
}


-(void) getAssetCodingData {
    
    conditionArr = [[NSMutableArray alloc] init];
    
    if ([[DataManager sharedManager] isInternetConnectionAvailable] && [[DataManager sharedManager] isLoggedIn]) {
        
        [SVProgressHUD showWithStatus:@"Saving" maskType:SVProgressHUDMaskTypeGradient];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSURL *theURL;
            if ([[DataManager sharedManager] restEnv]) {
                theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=setconditions&instance_url=%@&access_token=%@&id=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken], [[[DataManager sharedManager] getSelectedPlantDetails] valueForKey:@"Id"]]];
            }
            else {
                theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=setconditions&instance_url=%@&access_token=%@&id=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken], [[[DataManager sharedManager] getSelectedPlantDetails] valueForKey:@"Id"]]];
            }
            NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
            [theRequest setValue:HEADER_REQUEST_VALUE forHTTPHeaderField:HEADER_REQUEST_KEY];
            NSData *returnData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];
            NSError *error;
            NSDictionary* responseData = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers error:&error];
            status = [responseData valueForKey:@"status"];
            
            if ([responseData count]>0) {
                
                if (!error && !status) {
                    conditionArr = [responseData valueForKey:@"condition__c"];
                    operatorTypeArr = [responseData valueForKey:@"Operator_type__c"];
                    operatorSubclassArr = [responseData valueForKey:@"subclass"];
                    operatorClassArr = [responseData valueForKey:@"class"];
                    categoryArr = [responseData valueForKey:@"category"];
                }
                else {
                    if (status) {
                        errMsg = [responseData valueForKey:@"msg"];
                    }
                }
                
            }
            else {
                errMsg = @"Invalid Response from server";
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                if (!status) {
                    
                    [[DataManager sharedManager] deleteConditionsDetails];
                    [[DataManager sharedManager] deleteOperatorTypeDetails];
                    [[DataManager sharedManager] deleteOperatorClassDetails];
                    [[DataManager sharedManager] deleteOperatorSubclassDetails];
                    [[DataManager sharedManager] deleteCategoryDetails];
                    
                    
                    if ([conditionArr count] > 0) {
                        [self addConditionsDataToDB];
                    }
                    
                    if ([operatorTypeArr count] > 0) {
                        [self addOperatorTypeDataToDB];
                    }
                    
                    if ([operatorClassArr count] > 0) {
                        [self addOperatorClassDataToDB];
                    }
                    
                    if ([operatorSubclassArr count] > 0) {
                        [self addOperatorSubclassDataToDB];
                    }
                    
                    if ([categoryArr count] > 0) {
                        [self addCategoryDataToDB];
                    }
                    
                }
                else {
                    if (errMsg) {
                        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",errMsg]];
                    }
                    else{
                        [SVProgressHUD showErrorWithStatus:@"Downloading asset coding data failed"];
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
    
    [[self navigationController] popViewControllerAnimated:YES];
    
}


-(void) addConditionsDataToDB {
    
    for (int i = 0; i<conditionArr.count; i++) {
        
        NSDictionary* dict = [conditionArr objectAtIndex:i];
        [[DataManager sharedManager] saveConditionsWithValue:[dict valueForKey:@"value"] andDescription:[dict valueForKey:@"Description"]];
        
    }
    
}

-(void) addOperatorTypeDataToDB {
    
    for (int i = 0; i<operatorTypeArr.count; i++) {
        
        NSDictionary* dict = [operatorTypeArr objectAtIndex:i];
        [[DataManager sharedManager] saveOperatorTypeDetailsWithValue:[dict valueForKey:@"value"] andDescription:[dict valueForKey:@"Description"]];
        
    }
    
}

-(void) addOperatorClassDataToDB {
    
    for (int i = 0; i<operatorClassArr.count; i++) {
        
        NSDictionary* dict = [operatorClassArr objectAtIndex:i];
        [[DataManager sharedManager] saveOperatorClassWithValue:[dict valueForKey:@"Name"] andDescription:[dict valueForKey:@"catgory"] andID:[dict valueForKey:@"id"] andClass:[dict valueForKey:@"class"]];
        
    }
    
}

-(void) addOperatorSubclassDataToDB {
    
    for (int i = 0; i<operatorSubclassArr.count; i++) {
        
        NSDictionary* dict = [operatorSubclassArr objectAtIndex:i];
        [[DataManager sharedManager] saveOperatorSubclassWithValue:[dict valueForKey:@"Name"] andDescription:[dict valueForKey:@"class"] andId:[dict valueForKey:@"id"]];
        
    }
    
}

-(void) addCategoryDataToDB {
    
    for (int i = 0; i<categoryArr.count; i++) {
        
        NSDictionary* dict = [categoryArr objectAtIndex:i];
        [[DataManager sharedManager] saveCategoryWithValue:[dict valueForKey:@"Name"] andId:[dict valueForKey:@"id"] andCategory:[dict valueForKey:@"catgory"]];
        
    }
    
}

@end
