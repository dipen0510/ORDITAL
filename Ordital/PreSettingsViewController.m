//
//  PreSettingsViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 29/09/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "PreSettingsViewController.h"
#import "DataManager.h"
#import "SVProgressHUD.h"
#import "settingsViewController.h"
#import "DefaultSetViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MainViewController.h"

@interface PreSettingsViewController ()

@end

@implementation PreSettingsViewController
@synthesize environmentTextField,typeTxtField,connectionComboBox;



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
    [[UISlider appearance] setThumbImage:[UIImage imageNamed:@"slider-handle.png"]
                                forState:UIControlStateNormal];
    
    UIImage *sliderLeftTrackImage = [UIImage imageNamed: @"slider-orange.png"];
    sliderLeftTrackImage = [sliderLeftTrackImage resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
    UIImage *sliderRightTrackImage = [UIImage imageNamed: @"slider-gray.png"];
    sliderRightTrackImage = [sliderRightTrackImage resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
    [self.imgQualitySlider setMinimumTrackImage:sliderLeftTrackImage forState:UIControlStateNormal];
    [self.imgQualitySlider setMaximumTrackImage:sliderRightTrackImage forState:UIControlStateNormal];
    
    connectionComboBox.layer.borderColor = [[UIColor clearColor] CGColor];
    environmentTextField.layer.borderColor = [[UIColor clearColor] CGColor];
    typeTxtField.layer.borderColor = [[UIColor clearColor] CGColor];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    connectionComboBox.leftView = paddingView;
    connectionComboBox.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    environmentTextField.leftView = paddingView1;
    environmentTextField.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    typeTxtField.leftView = paddingView2;
    typeTxtField.leftViewMode = UITextFieldViewModeAlways;
    
    downloadedPlantContent = [[NSMutableArray alloc] init];
    
    typeContentArr = [NSMutableArray arrayWithObjects:@"ASSET",@"LOCATION",@"EQUIPMENT",@"SPARE",@"TOOL",@"COMPONENT", nil];
    typeTxtField.text = [[DataManager sharedManager] selectedTypeSettings];
    
    
    connectionContentArr = [NSMutableArray arrayWithObjects:@"STANDALONE",@"ENTERPRISE",@"TEST", nil];
    connectionComboBox.text = [[DataManager sharedManager] selectedConnectionSettings];
    
    
    /*if ([[[DataManager sharedManager] selectedTypeSettings] isEqualToString:[typeContentArr objectAtIndex:0]]) {
        typeTxtField.text = [typeContentArr objectAtIndex:0];
    }
    else if ([[[DataManager sharedManager] selectedTypeSettings] isEqualToString:[typeContentArr objectAtIndex:1]]){
        typeTxtField.text = [typeContentArr objectAtIndex:1];
    }
    else if ([[[DataManager sharedManager] selectedTypeSettings] isEqualToString:[typeContentArr objectAtIndex:2]]){
        typeTxtField.text = [typeContentArr objectAtIndex:2];
    }*/
    
    selectedPickerContent = [typeContentArr objectAtIndex: 0];
    
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
    
    typeTxtField.inputView = picker;
    typeTxtField.inputAccessoryView = toolBar;
    typeTxtField.delegate = self;
    
    
    
    
    connectionSelectedPickerContent = [connectionContentArr objectAtIndex: 0];
    
    connectionPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 480, 320, 270)];
    connectionPicker.delegate = self;
    connectionPicker.dataSource = self;
    connectionPicker.showsSelectionIndicator = YES;
    
    UIToolbar *toolBar1= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    [toolBar1 setBarStyle:UIBarStyleBlackOpaque];
    UIButton *customButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton1.frame = CGRectMake(0, 0, 60, 33);
    [customButton1 addTarget:self action:@selector(connectionPickerViewDoneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    customButton1.showsTouchWhenHighlighted = YES;
    //[customButton setTitle:@"Done" forState:UIControlStateNormal];
    [customButton1 setImage:[UIImage imageNamed:@"checkbox-selected.png"] forState:UIControlStateNormal];
    
    UILabel *lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 33)];
    [lbl1 setText:@"Choose an Option"];
    [lbl1 setTextColor:[UIColor whiteColor]];
    [lbl1 setFont:[UIFont systemFontOfSize:14.0]];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:lbl1];
    
    UIBarButtonItem *barCustomButton1 =[[UIBarButtonItem alloc] initWithCustomView:customButton1];
    UIBarButtonItem* flexibleSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolBar1.items = [[NSArray alloc] initWithObjects:item1,flexibleSpace1,barCustomButton1,nil];
    
    connectionComboBox.inputView = connectionPicker;
    connectionComboBox.inputAccessoryView = toolBar1;
    connectionComboBox.delegate = self;
    
    
    environmentTextField.text = [[DataManager sharedManager] selectedEnvironmentSettings];
    environmentTextField.delegate = self;
    
    
    self.imgQualitySlider.value = (1.0/[[[DataManager sharedManager] getSelectedImgQuality] floatValue]);
    self.imgQualityLabel.text = [NSString stringWithFormat:@"%.0f%%",(self.imgQualitySlider.value * 100)];
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
    
    
    [self changeUIonConnectionChange:[[DataManager sharedManager] selectedConnectionSettings]];
    
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    NSString* selectedPlantName = [[[DataManager sharedManager] selectedPlantSettings] valueForKey:@"Name"];
    if (![selectedPlantName isEqualToString:@""] && selectedPlantName) {
        
        self.plantStatusLabel.text = [NSString stringWithFormat:@"Selected Plant - %@",selectedPlantName];
        
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        dict  = [[DataManager sharedManager] getAllDynamicLabelValues];
        
        if (dict.count > 0) {
            
            NSString* plantStr = [dict valueForKey:@"PLANT"];
            
            if (![plantStr isEqual:[NSNull null]]) {
                self.plantStatusLabel.text = [NSString stringWithFormat:@"Selected %@ - %@",plantStr,selectedPlantName];
            }
            
        }
        
        
    }
    else {
        self.plantStatusLabel.text = @"No Plant Selected";
        
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        dict  = [[DataManager sharedManager] getAllDynamicLabelValues];
        
        if (dict.count > 0) {
            
            NSString* plantStr = [dict valueForKey:@"PLANT"];
            
            if (![plantStr isEqual:[NSNull null]]) {
                self.plantStatusLabel.text = [NSString stringWithFormat:@"No %@ Selected",plantStr];
            }
            
        }
        
    }
    
    self.navigationController.navigationBarHidden = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
}

- (void) setupInitialView {
    
    
    
}


-(void) changeUIonConnectionChange:(NSString *)tmpStr {
    
    if ([tmpStr isEqualToString:@"STANDALONE"]) {
        
        [self.plantStatusLabel setHidden:YES];
        [self.plantEditButton setHidden:YES];
        [self.typeTxtField setHidden:YES];
        [self.typeLabel setHidden:YES];
        [environmentTextField setHidden:YES];
        
    }
    else if ([tmpStr isEqualToString:@"ENTERPRISE"]) {
        
        [self.plantStatusLabel setHidden:NO];
        [self.plantEditButton setHidden:NO];
        [self.typeTxtField setHidden:NO];
        [self.typeLabel setHidden:NO];
        environmentTextField.text = kEnvironmentURL;
        [environmentTextField setHidden:YES];
        
    }
    else {
        [self.plantStatusLabel setHidden:NO];
        [self.plantEditButton setHidden:NO];
        [self.typeTxtField setHidden:NO];
        [self.typeLabel setHidden:NO];
        
        if (![[DataManager sharedManager] selectedEnvironmentSettings]) {
            environmentTextField.text = kEnvironmentURL;
        }
        else {
            environmentTextField.text = [[DataManager sharedManager] selectedEnvironmentSettings];
        }
        
        
        [environmentTextField setHidden:NO];
    }
    
}

-(void)pickerViewDoneButtonTapped:(id)sender{
    NSLog(@"Done tapped");
    typeTxtField.text = selectedPickerContent;
    [typeTxtField resignFirstResponder];
}

-(void)connectionPickerViewDoneButtonTapped:(id)sender{
    NSLog(@"Done tapped");
    connectionComboBox.text = connectionSelectedPickerContent;
    [self changeUIonConnectionChange:connectionSelectedPickerContent];
    [connectionComboBox resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//animate the picker out of view
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag==2) {
        [typeTxtField becomeFirstResponder];
    }
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
    
    if (thePickerView ==picker) {
        
        [l1 setText:[typeContentArr objectAtIndex:row]];
        
    }
    if (thePickerView ==connectionPicker) {
        
        [l1 setText:[connectionContentArr objectAtIndex:row]];
        
    }
    
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
    if (pickerView == connectionPicker) {
        return [connectionContentArr count];
    }
    return [typeContentArr count];
}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (pickerView == connectionPicker) {
        return [connectionContentArr objectAtIndex:row];
    }
    return [typeContentArr objectAtIndex:row];
}

// Do something with the selected row.
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (pickerView == connectionPicker) {
        NSLog(@"You selected this: %@", [connectionContentArr objectAtIndex:row]);
        connectionSelectedPickerContent = [connectionContentArr objectAtIndex:row];
    }
    else {
        NSLog(@"You selected this: %@", [typeContentArr objectAtIndex:row]);
        selectedPickerContent = [typeContentArr objectAtIndex:row];
        
    }
    
    [pickerView reloadComponent:component];
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    return true;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (IBAction)editButtonTapped:(id)sender {
    if ([[DataManager sharedManager] isInternetConnectionAvailable] && [[DataManager sharedManager] isLoggedIn]) {
        
        [SVProgressHUD showWithStatus:@"Updating Local Settings" maskType:SVProgressHUDMaskTypeGradient];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSURL *theURL;
            if ([[DataManager sharedManager] restEnv]) {
                theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=getplants&instance_url=%@&access_token=%@&uid=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken], [[DataManager sharedManager] getIdentity]]];
            }
            else {
                theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=getplants&instance_url=%@&access_token=%@&uid=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken], [[DataManager sharedManager] getIdentity]]];
            }
            NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
            [theRequest setValue:HEADER_REQUEST_VALUE forHTTPHeaderField:HEADER_REQUEST_KEY];
            NSData *returnData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];
            NSError *error;
            NSDictionary* responseData = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers error:&error];
            status = [responseData valueForKey:@"status"];
            if (!error && !status) {
                [downloadedPlantContent addObject:[responseData valueForKey:@"plants"]];
                [self addAllAuditTypeToDB:(NSMutableArray *)[responseData valueForKey:@"photoType"]];
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
                    if ([[downloadedPlantContent objectAtIndex:0] valueForKey:@"Id"]) {
                        [self performSegueWithIdentifier:@"settingsPushSegue" sender:nil];
                    }
                }
                else {
                    if (errMsg) {
                        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",errMsg]];
                    }
                    else{
                        [SVProgressHUD showErrorWithStatus:@"Downloading plants failed"];
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

- (void) addAllAuditTypeToDB:(NSMutableArray *)arr {
    
    [[DataManager sharedManager] deleteAuditTypeDetails];
    
    for (int i = 0; i<arr.count; i++) {
        
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        dict = [arr objectAtIndex:i];
        
        [[DataManager sharedManager] saveAuditTypeForId:[dict valueForKey:@"Id"] andName:[dict valueForKey:@"Name"] andOrder:[dict valueForKey:@"ORDER__c"]];
        
        
    }
    
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"settingsPushSegue"])
    {
        // Get reference to the destination view controller
        settingsViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        [vc setPlantContentArr:downloadedPlantContent];
    }

}

- (IBAction)sliderValueChanged:(id)sender {
    
    NSString* tmpStr = [NSString stringWithFormat:@"%.1f",(self.imgQualitySlider.value+0.1)];
    
    [self.imgQualitySlider setValue:[tmpStr floatValue] animated:YES];
    
    self.imgQualityLabel.text = [NSString stringWithFormat:@"%.0f%%",(self.imgQualitySlider.value * 100)];
}



- (IBAction)saveButtonTapped:(id)sender {
    [SVProgressHUD showWithStatus:@"Saving Configuration" maskType:SVProgressHUDMaskTypeGradient];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        
        
        NSLog(@"Done tapped");
        if (![environmentTextField.text isEqualToString:[[DataManager sharedManager] selectedEnvironmentSettings]] || ![connectionComboBox.text isEqualToString:[[DataManager sharedManager] selectedConnectionSettings]]) {
            [[DataManager sharedManager] deleteAuthToken];
            [[DataManager sharedManager] deleteAllDownloadsData];
            [[DataManager sharedManager] deleteAllAssetsAndAudits];
            [[DataManager sharedManager] deletePlantDetails];
            [[DataManager sharedManager] saveEnvironmentDetailsWithName:environmentTextField.text];
            [[DataManager sharedManager] setIsLoggedIn:false];
            [[DataManager sharedManager] setSelectedPlantSettings:nil];
            [[DataManager sharedManager] setSelectedEnvironmentSettings:environmentTextField.text];
            
            [[DataManager sharedManager] setSelectedConnectionSettings:connectionComboBox.text];
            [[DataManager sharedManager] saveSeletedConnectionDetailsWithName:connectionComboBox.text];
            
            [[DataManager sharedManager] deleteAuditTypeDetails];
            [[DataManager sharedManager] addDefaultAuditTypeValuesToDB];
            
            self.plantStatusLabel.text = @"No Plant Selected";
        }
        
        [[DataManager sharedManager] saveTypeDetailsWithName:typeTxtField.text];
        
        [[DataManager sharedManager] saveImQualityWithValue:[NSString stringWithFormat:@"%f",(1.0/self.imgQualitySlider.value)]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Configuration Saved"];
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
