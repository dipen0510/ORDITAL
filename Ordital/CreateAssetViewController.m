//
//  CreateAssetViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 20/09/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "CreateAssetViewController.h"
#import "AddAuditViewController.h"
#import "PreviewAuditViewController.h"
#import "AddNoteViewController.h"
#import "ChildrenListViewController.h"
#import "FindAssetViewController.h"
#import "DataManager.h"
#import "AuditData.h"
#import "SVProgressHUD.h"
#import "AssetCodingValueViewController.h"
#import "AssetsListViewController.h"
#import "AFViewController.h"
#import "LocationMapViewController.h"

@interface CreateAssetViewController ()

@end

@implementation CreateAssetViewController{
    BOOL showKeyboardAnimation;
    CGPoint viewCenter;
}

@synthesize assetNameTxtField,parentTxtField,plantNameTxtField,descriptionTxtField,tagTxtField,isAssetToBeUpdated,assetToUpdate,isAuditToBePreviewed,typeTxtField,currentAssetViewType,currentScrollAssetIndex,scrollContentArr,currentInternetStatus,isNewChildAsset,parentLabel,isDoneTodayPreview;

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

    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 580);
    [self.scrollView setDelegate:self];
    
    assetObj = [[AssetData alloc] init];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    assetNameTxtField.leftView = paddingView;
    assetNameTxtField.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    parentTxtField.leftView = paddingView1;
    parentTxtField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    tagTxtField.leftView = paddingView3;
    tagTxtField.leftViewMode = UITextFieldViewModeAlways;
    
    self.saveButton.layer.cornerRadius = 5.0;
    self.addAuditButton.layer.cornerRadius = 5.0;
    
    self.unableToLocateSwitch.layer.cornerRadius = 16.0;
    
    if (isAssetToBeUpdated) {
        assetObj.assetId = assetToUpdate.assetId;
        assetObj.assetName = assetToUpdate.assetName;
        assetObj.plantName = assetToUpdate.plantName;
        assetObj.plantId = assetToUpdate.plantId;
        assetObj.description = assetToUpdate.description;
        assetObj.tag = assetToUpdate.tag;
        assetObj.parent = assetToUpdate.parent;
        assetObj.type = assetToUpdate.type;
        assetObj.parentId = assetToUpdate.parentId;
        assetObj.unableToLocate = assetToUpdate.unableToLocate;
        assetObj.condition = assetToUpdate.condition;
        assetObj.operatorClass = assetToUpdate.operatorClass;
        assetObj.operatorSubclass = assetToUpdate.operatorSubclass;
        assetObj.category = assetToUpdate.category;
        assetObj.operatorType = assetToUpdate.operatorType;
        assetObj.operatorClassId = assetToUpdate.operatorClassId;
        assetObj.operatorSubclassId = assetToUpdate.operatorSubclassId;
        assetObj.categoryId = assetToUpdate.categoryId;
        assetObj.latitude = assetToUpdate.latitude;
        assetObj.longitude = assetToUpdate.longitude;
        
        
        descriptionTxtField.text = assetObj.description;
        tagTxtField.text = assetObj.tag;
        parentTxtField.text = assetObj.parent;
        typeTxtField.text = assetObj.type;
        
        
        assetObj.isNewAsset = assetToUpdate.isNewAsset;
        
        
        [self.circleImgView setHidden:NO];
        [self.editAssetCountLbl setHidden:NO];
        
        _homeButton.hidden = NO;
        _mapButton.hidden = NO;
        NSMutableArray* tmpArr = [[NSMutableArray alloc] init];
        tmpArr = [[DataManager sharedManager] getAuditDataForAssetId:assetObj.assetId];
        
        [self.editAssetCountLbl setText:[NSString stringWithFormat:@"%lu",(unsigned long)[tmpArr count]]];
        
        
        if (isAuditToBePreviewed) {
            [self.unableToLocateSwitch setHidden:YES];
            [self.unableToLocateLabel setHidden:YES];
            _mapButton.hidden = YES;
           // [self.saveButton setHidden:YES];
            
        }
        else {
            [self.unableToLocateSwitch setHidden:NO];
            [self.unableToLocateLabel setHidden:NO];
            [self.unableToLocateSwitch setOn:assetObj.unableToLocate];
            
        }
        
        if (isNewChildAsset) {
            assetObj.isNewAsset = isNewChildAsset;
        }
        
        navigation = [[UIBarButtonItem alloc]
                      initWithTitle:@"Back to Home"
                      style:UIBarButtonItemStyleBordered
                      target:self
                      action:@selector(backToHome:)];
        
        
        self.navigationItem.rightBarButtonItem = navigation;
        [self.navigationItem setTitle:@"Edit Asset"];
        [self.createAssetNavLbl setText:@"Asset Detail"];
        
        
        if ([[DataManager sharedManager] getLockRecordsDetails]) {
            
            [assetNameTxtField setUserInteractionEnabled:false];
            [descriptionTxtField setUserInteractionEnabled:false];
            [tagTxtField setUserInteractionEnabled:false];
            [parentTxtField setUserInteractionEnabled:false];
            [self.downArrowButton setUserInteractionEnabled:false];
            [self.upArrowButton setUserInteractionEnabled:false];
            [self.addChildAssetButton setUserInteractionEnabled:false];
            [self.searchParentAssetButton setUserInteractionEnabled:false];
            
        }
        
        
    }
    else {
        assetObj.assetId = [[NSUUID UUID] UUIDString];
        assetObj.assetName = [self generateAssetName];
        assetObj.plantName = [[[DataManager sharedManager] selectedPlantSettings] valueForKey:@"Name"];
        assetObj.plantId = [[[DataManager sharedManager] selectedPlantSettings] valueForKey:@"Id"];
        assetObj.isNewAsset = !isAssetToBeUpdated;
        assetObj.type = [[DataManager sharedManager] selectedTypeSettings];
        assetObj.parentId = @"";
        
        assetObj.condition = @"";
        assetObj.operatorType = @"";
        assetObj.operatorClass = @"";
        assetObj.operatorSubclass = @"";
        assetObj.category = @"";
        assetObj.operatorClassId = @"";
        assetObj.operatorSubclassId = @"";
        assetObj.categoryId = @"";
        
        [self.unableToLocateSwitch setHidden:YES];
        [self.unableToLocateLabel setHidden:YES];
        typeTxtField.text = assetObj.type;
        [self.navigationItem setTitle:@"Create Asset"];
        [self.createAssetNavLbl setText:@"Create Asset"];
        
        [parentTxtField setHidden:YES];
        [parentLabel setHidden:YES];
        _homeButton.hidden = YES;
        _mapButton.hidden = YES;
        
        self.assetCodingTopConstraint.constant = -93.0;
        self.assetCodingRightArrowTopCOnstrain.constant = -100.0;
        self.addPhotoTopConstraint.constant = 85.0;
        self.assetNameTxtFieldTrailConstraint.constant = -90.0;
        
        self.internetStatusImgView.hidden = true;
        
        [self.circleImgView setHidden:YES];
        [self.editAssetCountLbl setHidden:YES];
        
    }
    
    typeContentArr = [NSMutableArray arrayWithObjects:@"ASSET",@"LOCATION",@"EQUIPMENT", nil];
    selectedPickerContent = [typeContentArr objectAtIndex: 0];
    
    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 480, 320, 270)];
    //picker.delegate = self;
    //picker.dataSource = self;
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
    
    assetNameTxtField.text = assetObj.assetName;
    plantNameTxtField.text = assetObj.plantName;
    
    showKeyboardAnimation = true;
    viewCenter = self.view.center;
    
    assetNameTxtField.delegate = self;
    plantNameTxtField.delegate = self;
    descriptionTxtField.delegate = self;
    tagTxtField.delegate = self;
    parentTxtField.delegate = self;
    typeTxtField.delegate = self;
    
    /*if (isAuditToBePreviewed) {
        [self.addAuditButton setTitle:@"Preview Audits" forState:UIControlStateNormal] ;
    }
    else {
        [self.addAuditButton setTitle:@"Add Audits" forState:UIControlStateNormal] ;
    }*/
    
    if (currentAssetViewType==0) {
        [self.upArrowButton setHidden:YES];
        [self.downArrowButton setHidden:YES];
        [self.addChildAssetButton setHidden:YES];
        [self.searchParentAssetButton setHidden:YES];
        [self.unableToLocateSwitch setHidden:YES];
        [self.unableToLocateLabel setHidden:YES];
    }
    
    childrenContentArr = [[NSMutableArray alloc] init];
    parentContent = [[NSMutableDictionary alloc] init];
    
    self.view.userInteractionEnabled = YES;
    
    swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightButtonTapped:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeRight];
    
    swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftButtonTapped:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeLeft];
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard:)];
    [self.scrollView addGestureRecognizer:gestureRecognizer];
    
    if (![self checkIfConneectionValid]) {
        
        //[self.assetCodingLabel setHidden:YES];
        //[self.assetCodingRightArrowButton setHidden:YES];
    }
    
    [self setupInitialView];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBarHidden = true;
    
    if ([[DataManager sharedManager] tmpParentId] && !([[[DataManager sharedManager] tmpParentId] isEqualToString:@""])) {
        assetObj.parent = [[DataManager sharedManager] tmpParentName];
        assetObj.parentId = [[DataManager sharedManager] tmpParentId];
        parentTxtField.text = assetObj.parent;
        [[DataManager sharedManager] setTmpParentId:@""];
        [[DataManager sharedManager] setTmpParentName:@""];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
    
    if ([[DataManager sharedManager] isInternetConnectionAvailable] && [self checkIfConneectionValid]) {
        NSLog(@"Internet available");
        self.internetStatusImgView.image = [UIImage imageNamed:@"connect-icon.png"];
    }
    else{
        NSLog(@"Internet not available");
        self.internetStatusImgView.image = [UIImage imageNamed:@"disconnect-icon.png"];
    }
    
    
    
    //[self.scrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}

- (void) setupInitialView {
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    dict  = [[DataManager sharedManager] getAllDynamicLabelValues];
    
    if (dict.count > 0) {
        
        NSString* assetNameStr = [dict valueForKey:@"ASSET_NAME"];
        NSString* tagStr = [dict valueForKey:@"TAG"];
        NSString* unableToLocateStr = [dict valueForKey:@"UNABLE_TO_LOCATE"];
        NSString* assetCodingStr = [dict valueForKey:@"ASSET_CODING"];
        
        if (![assetNameStr isEqual:[NSNull null]]) {
            self.assetNameLabel.text = assetNameStr;
        }
        if (![tagStr isEqual:[NSNull null]]) {
            self.tagLabel.text = tagStr;
        }
        if (![unableToLocateStr isEqual:[NSNull null]]) {
            self.unableToLocateLabel.text = unableToLocateStr;
        }
        if (![assetCodingStr isEqual:[NSNull null]]) {
            self.assetCodingLabel.text = assetCodingStr;
        }
        
    }
    
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    //[self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 580)];
    
//    // Adjust frame for iPhone 4s
//    if (self.view.bounds.size.height == 480) {
//        self.scrollView.frame = CGRectMake(0, 0, 320, 436); // 436 allows 44 for navBar
//    }
}

-(IBAction) viewChilds:(id) sender {
    
    
    //if ([self checkIfConneectionValid]) {
        
        if (currentInternetStatus) {
            if ([[DataManager sharedManager] isInternetConnectionAvailable] && [[DataManager sharedManager] isLoggedIn]) {
                
                [SVProgressHUD showWithStatus:@"Downloading Child Data" maskType:SVProgressHUDMaskTypeGradient];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    NSString* status;
                    NSString* errMsg;
                    
                    NSURL *theURL;
                    if ([[DataManager sharedManager] restEnv]) {
                        theURL = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=getchildassets&instance_url=%@&access_token=%@&assetid=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[assetObj.assetId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                    }
                    else  {
                        theURL = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=getchildassets&instance_url=%@&access_token=%@&assetid=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[assetObj.assetId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                    }
                    
                    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                    
                    [theRequest setValue:HEADER_REQUEST_VALUE forHTTPHeaderField:HEADER_REQUEST_KEY];
                    NSData *returnData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];
                    //NSString *listFile = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                    NSError *error;
                    NSDictionary* responseData = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers error:&error];
                    status = [responseData valueForKey:@"status"];
                    if (!error && !status) {
                        childrenContentArr = [responseData valueForKey:@"assets"];
                    }
                    else {
                        if (status) {
                            errMsg = [responseData valueForKey:@"msg"];
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                        if (!status) {
                            if ([childrenContentArr count]>0) {
                                [self performSegueWithIdentifier:@"pushChlidrenListSegue" sender:nil];
                            }
                        }
                        else {
                            if (errMsg) {
                                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",errMsg]];
                            }
                            else{
                                [SVProgressHUD showErrorWithStatus:@"Downloading child failed"];
                            }
                            //status = nil;
                        }
                        
                    });
                });
            }
            else{
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connectivity" message:@"Please login to app after turning on internet settings to view this section" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else {
            [SVProgressHUD showWithStatus:@"Fetching Children Data" maskType:SVProgressHUDMaskTypeGradient];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                childrenContentArr = [[DataManager sharedManager] getAllChildrenForAssetId:assetObj.assetId];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    if ([childrenContentArr count]>0) {
                        [self performSegueWithIdentifier:@"pushChlidrenListSegue" sender:nil];
                    }
                    else {
                        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"No Records found in Database"]];
                        
                        //status = nil;
                    }
                    
                });
            });
        }

        
//    }
//    else {
//        
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Standalone Mode" message:@"This section is not available in Standalone mode." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//        
//    }
    
}

-(void) backToHome:(id) sender {
    
    if (isAuditToBePreviewed) {
        
        assetObj.assetName=assetNameTxtField.text;
        assetObj.description = descriptionTxtField.text;
        assetObj.tag = tagTxtField.text;
        assetObj.parent = parentTxtField.text;
        assetObj.unableToLocate = [self.unableToLocateSwitch isOn];
        
        [self saveAssedDataInOfflineMode];
        
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void) backToParent:(id) sender {

    NSMutableArray *newStack = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    [newStack removeLastObject];
    [newStack removeLastObject];
    [newStack removeLastObject];
    [self.navigationController setViewControllers:newStack animated:YES];
}




-(void)pickerViewDoneButtonTapped:(id)sender{
    NSLog(@"Done tapped");
    typeTxtField.text = selectedPickerContent;
    [typeTxtField resignFirstResponder];
}


- (NSString*)GetCurrentTimeStamp
{
    NSDateFormatter *objDateformat = [[NSDateFormatter alloc] init];
    [objDateformat setDateFormat:@"yyyyMMdd_hhmmssSSS"];
    NSString    *strTime = [objDateformat stringFromDate:[NSDate date]];
    NSLog(@"The Timestamp is = %@",strTime);
    return strTime;
}


-(NSString*)generateAssetName
{
    return [NSString stringWithFormat:@"ASSET_%@",[self GetCurrentTimeStamp]];
}

-(NSString*)generateChildAssetName
{
    NSArray* tmpArr = [assetObj.assetName componentsSeparatedByString:@"ASSET"];
    
    if ([tmpArr count] > 2) {
        return [NSString stringWithFormat:@"ASSET%@-%@",[tmpArr lastObject],[self generateAssetName]];
    }
    
    return [assetObj.assetName stringByAppendingString:[NSString stringWithFormat:@"-%@",[self generateAssetName]]];
}




                                             
  
                                             

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    assetObj.assetName=assetNameTxtField.text;
    assetObj.description = descriptionTxtField.text;
    assetObj.tag = tagTxtField.text;
    assetObj.parent = parentTxtField.text;
    assetObj.unableToLocate = [self.unableToLocateSwitch isOn];
    
    if ([[segue identifier] isEqualToString:@"previewAuditSegue"]) {
        //[[DataManager sharedManager] saveOnlyAssetData:assetObj];
        
        AFViewController* controller = [segue destinationViewController];
        controller.currentAssetId = assetObj.assetId;
        controller.assetObj = assetObj;
        controller.isDoneTodayPreview = isDoneTodayPreview;
        
    }
    else if ([[segue identifier] isEqualToString:@"addAuditSegue"]){
        AddAuditViewController* auditController = [segue destinationViewController];
        auditController.currentAssetId = assetObj.assetId;
        auditController.currentAssetName = assetObj.assetName;
        auditController.assetObj = assetObj;
        auditController.isAssetToBeUpdated = isAssetToBeUpdated;
    }
    else if ([[segue identifier] isEqualToString:@"noteSegue"]){
        AddNoteViewController* auditController = [segue destinationViewController];
        auditController.currentAssetId = assetObj.assetId;
    }
    else if ([[segue identifier] isEqualToString:@"pushChlidrenListSegue"]){
        ChildrenListViewController* auditController = [segue destinationViewController];
        auditController.searchContentArr = childrenContentArr;
        auditController.isInternetActive = currentInternetStatus;
    }
    else if ([[segue identifier] isEqualToString:@"AssetCodingValuePushSegue"]) {
        
        AssetCodingValueViewController* codingController = [segue destinationViewController];
        codingController.assetToUpdate = assetObj;
        codingController.isAssetToBeUpdated = isAssetToBeUpdated;
        codingController.isAuditToBePreviewed = isAuditToBePreviewed;
        codingController.unableToLocate = [self.unableToLocateSwitch isOn];
        
    }
    else if ([[segue identifier] isEqualToString:@"showMapSegue"]) {
        
        LocationMapViewController* codingController = [segue destinationViewController];
        codingController.assetToUpdate = assetObj;
        if ([[UIApplication sharedApplication] canOpenURL:
             [NSURL URLWithString:@"comgooglemaps://"]]) {
            codingController.shouldOpenGMaps = YES;
        }
        
    }
    NSLog(@"Segue enter");
    

    // Make sure your segue name in storyboard is the same as this line
    /*if ([[segue identifier] isEqualToString:@"YOUR_SEGUE_NAME_HERE"])
     {
     // Get reference to the destination view controller
     YourViewController *vc = [segue destinationViewController];
     
     // Pass any objects to the view controller here, like...
     [vc setMyObjectHere:object];
     }*/
}

//TEXT FIELD DELEGATES
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 10) {
        [typeTxtField becomeFirstResponder];
    }
    else {
        if (textField.center.y>200 && showKeyboardAnimation) {
            CGPoint MyPoint = self.view.center;
            
            [UIView animateWithDuration:0.3
                             animations:^{
                                 
                                 self.view.center = CGPointMake(MyPoint.x, MyPoint.y - textField.center.y + 240);
                             }];
            
            showKeyboardAnimation=false;
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (!(textField.tag == 10)) {
        if (showKeyboardAnimation) {
            //CGPoint MyPoint = self.view.center;
            
            [UIView animateWithDuration:0.3
                             animations:^{
                                 
                                 self.view.center = CGPointMake(viewCenter.x, viewCenter.y);
                             }];
            
        }
    }
}

#define MAXLENGTH 79

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.tag == 1) {
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        
        return newLength <= MAXLENGTH || returnKey;
    }
    
    return YES;
    
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    showKeyboardAnimation = true;
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    showKeyboardAnimation = true;
    [self.view endEditing:YES];
    [textField resignFirstResponder];
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    showKeyboardAnimation = true;
    [self.view endEditing:YES];
    
}

-(void) hideKeyBoard:(id) sender
{
    // Do whatever such as hiding the keyboard
    showKeyboardAnimation = true;
    [self.view endEditing:YES];
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

- (IBAction)addAuditButtonTapped:(id)sender {
    
    
    if ([self checkIfConneectionValid]) {
        
        if (assetObj.plantId && !([assetObj.plantId isEqualToString:@""])) {
            if (isAuditToBePreviewed || isDoneTodayPreview) {
                [self performSegueWithIdentifier:@"previewAuditSegue" sender:nil];
            }
            else {
                [self performSegueWithIdentifier:@"addAuditSegue" sender:nil];
            }
        }
        else {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Plant Missing" message:@"Please select plant details from Settings to proceed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil , nil];
            [alert show];
        }
        
    }
    else {
        
        if (isAuditToBePreviewed || isDoneTodayPreview) {
            [self performSegueWithIdentifier:@"previewAuditSegue" sender:nil];
        }
        else {
            [self performSegueWithIdentifier:@"addAuditSegue" sender:nil];
        }
        
    }
    
    
    
}
/*- (IBAction)unableToLocateSwitchTapped:(id)sender {
    
   // [SVProgressHUD showWithStatus:@"Adding Notes" maskType:SVProgressHUDMaskTypeGradient];
    
  //  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if ([sender isOn]) {
            NSString* noteType;
            
            noteType = [NSString stringWithFormat:@"%d",(int)[sender isOn] ];
            [[DataManager sharedManager] saveNoteTypeDetailsWithId:assetObj.assetId withNote:noteType];
            
            //NSString* noteType = [[DataManager sharedManager] getNoteTypeForAssetId:currentAssetId];
            if ([[DataManager sharedManager] isInternetConnectionAvailable] && [[DataManager sharedManager] isLoggedIn]) {
                
                BOOL isUploadedSuccess = true;
                BOOL sessionExpired = false;
                
                NSString *post = [[DataManager sharedManager] getJsonStringForSyncNotesWithId:assetObj.assetId andNote:noteType];
                NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
                
                NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
                
                NSURL *theURL;
                if ([[[DataManager sharedManager] selectedEnvironmentSettings] isEqualToString:@"Production"]) {
                 theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=bulkdataupload&instance_url=%@&access_token=%@&plant_id=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[[[DataManager sharedManager] selectedPlantSettings] valueForKey:@"Id"]]];
                 }
                 else {
                theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=AddNote&instance_url=%@&access_token=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken]]];
                //}
                
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                [request setURL:theURL];
                [request setHTTPMethod:@"POST"];
                [request setTimeoutInterval:60.0];
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [request setHTTPBody:postData];
                
                NSError *error = nil;
                NSHTTPURLResponse *responseCode = nil;
                
                NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
                
                NSString* responseDataConv = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                
                NSLog(@"%@",responseDataConv);
                //NSString* responseStatus = [responseDataConv valueForKey:@"status"];
                if (!([responseDataConv rangeOfString:@"\"status\":true"].location == NSNotFound)) {
                    [[DataManager sharedManager] deleteNoteWithId:assetObj.assetId];
                }
                else {
                    if (!([responseDataConv rangeOfString:@"Session expired or invalid"].location == NSNotFound)) {
                        sessionExpired = true;
                    }
                    isUploadedSuccess = false;
                    //[[DataManager sharedManager] saveNoteTypeDetailsWithId:currentAssetId withNote:noteType];
                }
                
            }
        
        
        else {
            [[DataManager sharedManager] deleteNoteWithId:assetObj.assetId];
        }
        
        
      }
        else {
            [[DataManager sharedManager] deleteNoteWithId:assetObj.assetId];
        }
        
     dispatch_async(dispatch_get_main_queue(), ^{
            
            [SVProgressHUD dismiss];
            
        });
    });
}*/


- (void)rightButtonTapped:(id)sender {
    
    /*CGRect frame = self.view.frame;
     
     // I don't know how far you want to move the grid view.
     // This moves it off screen.
     // Adjust this to move it the appropriate amount for your desired UI
     
     frame.origin.x += self.view.bounds.size.width;
     
     // Now animate the changing of the frame
     
     [UIView animateWithDuration:0.5
     animations:^{
     self.view.frame = frame;
     }];*/
    if ([scrollContentArr count]>0) {
        if (currentScrollAssetIndex!=([scrollContentArr count]-1)) {
            
            CGRect frame = [self.view viewWithTag:1000].frame;
            frame1 = [self.view viewWithTag:1000].frame;
            frame2 = [self.view viewWithTag:1000].frame;
            
            // I don't know how far you want to move the grid view.
            // This moves it off screen.
            // Adjust this to move it the appropriate amount for your desired UI
            
            frame.origin.x -= self.view.bounds.size.width;
            frame1.origin.x += self.view.bounds.size.width;
            
            // Now animate the changing of the frame
            
            [UIView animateWithDuration:0.15
                             animations:^{
                                 [self.view viewWithTag:1000].frame = frame;
                                 
                             }];
            [self performSelector:@selector(animateAfterDelayForRight) withObject:nil afterDelay:0.15];
            
        }
    }
    
}

- (void)leftButtonTapped:(id)sender {
    
    //    [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
    //
    //        [self.view viewWithTag:1000].frame = frame2;
    //
    //    } completion:nil];
    
    
    if ([scrollContentArr count]>0) {
        if (currentScrollAssetIndex!=0) {
            
            CGRect frame = [self.view viewWithTag:1000].frame;
            frame1 = [self.view viewWithTag:1000].frame;
            frame2 = [self.view viewWithTag:1000].frame;
            
            // I don't know how far you want to move the grid view.
            // This moves it off screen.
            // Adjust this to move it the appropriate amount for your desired UI
            
            frame.origin.x += self.view.bounds.size.width;
            frame1.origin.x -= self.view.bounds.size.width;
            
            // Now animate the changing of the frame
            
            [UIView animateWithDuration:0.15
                             animations:^{
                                 [self.view viewWithTag:1000].frame = frame;
                                 
                             }];
            [self performSelector:@selector(animateAfterDelayForLeft) withObject:nil afterDelay:0.15];
            
            
        }
    }
}

-(void) animateAfterDelayForRight {
    [self.view viewWithTag:1000].frame = frame1;
    [UIView animateWithDuration:0.15
                     animations:^{
                         
                         [self.view viewWithTag:1000].frame = frame2;
                         
                         assetObj = [[AssetData alloc] init];
                         NSDictionary *tmpDict = [scrollContentArr objectAtIndex:(currentScrollAssetIndex+1)];
                         
                         assetObj.assetId = [tmpDict valueForKey:@"Id"];
                         assetObj.assetName = [tmpDict valueForKey:@"Name"];
                         assetObj.plantName = [tmpDict valueForKey:@"Plant__name"];
                         assetObj.plantId = [tmpDict valueForKey:@"Plant__id"];
                         assetObj.description = [tmpDict valueForKey:@"Short_description__c"];
                         assetObj.tag = [tmpDict valueForKey:@"Tag__c"];
                         assetObj.parent = [tmpDict valueForKey:@"PARENT_ASSET__Name"];
                         assetObj.type = [tmpDict valueForKey:@"TYPE__c"];
                         assetObj.unableToLocate = [[tmpDict valueForKey:@"UNABLE_TO_LOCATE__c"] boolValue];
                         
                         assetObj.operatorClass = [tmpDict valueForKey:@"Class__name"];
                         assetObj.operatorType = [tmpDict valueForKey:@"OPERATOR_TYPE__c"];
                         assetObj.operatorClassId = [tmpDict valueForKey:@"Class__id"];
                         assetObj.operatorSubclass = [tmpDict valueForKey:@"SubClass__name"];
                         assetObj.operatorSubclassId = [tmpDict valueForKey:@"SubClass__id"];
                         assetObj.category = [tmpDict valueForKey:@"Category__name"];
                         assetObj.categoryId = [tmpDict valueForKey:@"Category__id"];
                         
                         NSString* tmpIsNewAsset = [tmpDict valueForKey:@"isNewAsset"];
                         if (tmpIsNewAsset && ![tmpIsNewAsset isEqualToString:@""]) {
                             
                             assetObj.isNewAsset = [tmpIsNewAsset boolValue];
                             
                         }
                         
                         descriptionTxtField.text = assetObj.description;
                         tagTxtField.text = assetObj.tag;
                         parentTxtField.text = assetObj.parent;
                         typeTxtField.text = assetObj.type;
                         assetNameTxtField.text = assetObj.assetName;
                         plantNameTxtField.text = assetObj.plantName;
                         
                         [self.unableToLocateSwitch setOn:assetObj.unableToLocate];
                         
                         assetObj.isNewAsset = !isAssetToBeUpdated;
                         
                         currentScrollAssetIndex++;
                     }];
}

-(void) animateAfterDelayForLeft {
    [self.view viewWithTag:1000].frame = frame1;
    [UIView animateWithDuration:0.15
                     animations:^{
                         
                         [self.view viewWithTag:1000].frame = frame2;
                         
                         assetObj = [[AssetData alloc] init];
                         NSDictionary *tmpDict = [scrollContentArr objectAtIndex:(currentScrollAssetIndex-1)];
                         
                         assetObj.assetId = [tmpDict valueForKey:@"Id"];
                         assetObj.assetName = [tmpDict valueForKey:@"Name"];
                         assetObj.plantName = [tmpDict valueForKey:@"Plant__name"];
                         assetObj.plantId = [tmpDict valueForKey:@"Plant__id"];
                         assetObj.description = [tmpDict valueForKey:@"Short_description__c"];
                         assetObj.tag = [tmpDict valueForKey:@"Tag__c"];
                         assetObj.parent = [tmpDict valueForKey:@"PARENT_ASSET__Name"];
                         assetObj.type = [tmpDict valueForKey:@"TYPE__c"];
                         assetObj.unableToLocate = [[tmpDict valueForKey:@"UNABLE_TO_LOCATE__c"] boolValue];
                         
                         assetObj.operatorClass = [tmpDict valueForKey:@"Class__name"];
                         assetObj.operatorType = [tmpDict valueForKey:@"OPERATOR_TYPE__c"];
                         assetObj.operatorClassId = [tmpDict valueForKey:@"Class__id"];
                         assetObj.operatorSubclass = [tmpDict valueForKey:@"SubClass__name"];
                         assetObj.operatorSubclassId = [tmpDict valueForKey:@"SubClass__id"];
                         assetObj.category = [tmpDict valueForKey:@"Category__name"];
                         assetObj.categoryId = [tmpDict valueForKey:@"Category__id"];
                         
                         NSString* tmpIsNewAsset = [tmpDict valueForKey:@"isNewAsset"];
                         if (tmpIsNewAsset && ![tmpIsNewAsset isEqualToString:@""]) {
                             
                             assetObj.isNewAsset = [tmpIsNewAsset boolValue];
                             
                         }
                         
                         descriptionTxtField.text = assetObj.description;
                         tagTxtField.text = assetObj.tag;
                         parentTxtField.text = assetObj.parent;
                         typeTxtField.text = assetObj.type;
                         assetNameTxtField.text = assetObj.assetName;
                         plantNameTxtField.text = assetObj.plantName;
                         
                         [self.unableToLocateSwitch setOn:assetObj.unableToLocate];
                         
                         assetObj.isNewAsset = !isAssetToBeUpdated;
                         
                         currentScrollAssetIndex--;
                     }];
}


- (IBAction)addChildAssetButtonTapped:(id)sender {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    CreateAssetViewController* controller = (CreateAssetViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"createassetcontroller"];
    
    AssetData* asset = [[AssetData alloc] init];
    
    asset.assetName = [self generateChildAssetName];
    asset.assetId = [[NSUUID UUID] UUIDString];
    asset.parent = assetObj.assetName;
    asset.plantId = [[[DataManager sharedManager] selectedPlantSettings] valueForKey:@"Id"];
    asset.plantName = [[[DataManager sharedManager] selectedPlantSettings] valueForKey:@"Name"];
    asset.type = [[DataManager sharedManager] selectedTypeSettings];
    
    asset.condition = @"";
    asset.operatorType = @"";
    asset.operatorClass = @"";
    //asset.operatorSubclass = @"";
    asset.category = @"";
    asset.operatorClassId = @"";
    
    
    [controller setIsAssetToBeUpdated:true];
    [controller setAssetToUpdate:asset];
    
    asset.parentId = assetObj.assetId;
    
    [controller setIsNewChildAsset:YES];
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)searchParentAssetButtonTapped:(id)sender {
    //[[DataManager sharedManager] setIsFindAssetToBeOpened:1];
    //[self.navigationController popToRootViewControllerAnimated:NO];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    FindAssetViewController* controller = (FindAssetViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"findassetcontroller"];
    
    [controller setIsSearchedContentToBeSelected:YES];
    
    [self.navigationController pushViewController:controller animated:YES];
    
    
}


-(BOOL) checkIfConneectionValid {
    
    if ([[[DataManager sharedManager] selectedConnectionSettings] isEqualToString:@"STANDALONE"]) {
        return false;
    }
    
    return true;
    
}


- (IBAction)saveAssetButtonTapped:(id)sender
{
    assetObj.assetName=assetNameTxtField.text;
    assetObj.description = descriptionTxtField.text;
    assetObj.tag = tagTxtField.text;
    assetObj.parent = parentTxtField.text;
    assetObj.unableToLocate = [self.unableToLocateSwitch isOn];
    
    if ([self checkIfConneectionValid]) {
        
        if (assetObj.plantId && !([assetObj.plantId isEqualToString:@""])) {
            if ([[DataManager sharedManager] isInternetConnectionAvailable] && [[DataManager sharedManager] isLoggedIn]) {
                
                [SVProgressHUD showWithStatus:@"Uploading Asset" maskType:SVProgressHUDMaskTypeGradient];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    //[self uploadAuditImageToServer];
                    
                    
                    BOOL isUploadedSuccess = true;
                    BOOL sessionExpired = false;
                    
                    
                    
                    NSString *post = [[DataManager sharedManager] getJsonStringForSyncUpdatesWithAsset:assetObj];//[self getJsonStringForSingleSyncUpdatesWithAsset];
                    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
                    
                    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
                    
                    NSURL *theURL;
//                    if ([[DataManager sharedManager] restEnv]) {
//                        theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=createAsset&instance_url=%@&access_token=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken]]];
//                    }
//                    else {
//                        theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=createAsset&instance_url=%@&access_token=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken]]];
//                    }
 
                    
                    if ([[DataManager sharedManager] restEnv]) {
                        theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=bulkdataupload&instance_url=%@&access_token=%@&identity=%@&bucket=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[[DataManager sharedManager] getIdentity],[[DataManager sharedManager] getBucket]]];
                    }
                    else {
                        theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=bulkdataupload&instance_url=%@&access_token=%@&identity=%@&bucket=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[[DataManager sharedManager] getIdentity],[[DataManager sharedManager] getBucket]]];
                    }
                    
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                    [request setURL:theURL];
                    [request setHTTPMethod:@"POST"];
                    [request setTimeoutInterval:60.0];
                    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    [request setValue:HEADER_REQUEST_VALUE forHTTPHeaderField:HEADER_REQUEST_KEY];
                    [request setHTTPBody:postData];
                    
                    NSError *error = nil;
                    NSHTTPURLResponse *responseCode = nil;
                    
                    NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
                    
                    if (responseData) {
                        NSString* responseDataConv = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                        NSLog(@"%@",responseDataConv);
                        //NSString* responseStatus = [responseDataConv valueForKey:@"status"];
                        if (!([responseDataConv rangeOfString:@"\"status\":true"].location == NSNotFound)) {
                            [[DataManager sharedManager] deleteNoteWithId:assetObj.assetId];
                            [[DataManager sharedManager] deleteOnlyAssetWithId:assetObj.assetId];
                            
                            NSMutableDictionary* responseData1 = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
                            
                            if (![[responseData1 valueForKey:@"id"] isEqual:[NSNull null]]) {
                                assetObj.assetId = [responseData1 valueForKey:@"id"];
                                assetObj.isNewAsset = false;
                            }
                            
                            
                            
                        }
                        else {
                            if (!([responseDataConv rangeOfString:@"Session expired or invalid"].location == NSNotFound)) {
                                sessionExpired = true;
                            }
                            isUploadedSuccess = false;
                            [[DataManager sharedManager] saveAssetData:assetObj withUpdate:isAssetToBeUpdated];
                            
                            if ([self.unableToLocateSwitch isOn]) {
                                NSString* noteType;
                                noteType = [NSString stringWithFormat:@"%d",(int)[self.unableToLocateSwitch isOn] ];
                                [[DataManager sharedManager] saveNoteTypeDetailsWithId:assetObj.assetId withNote:noteType];
                            }
                            else {
                                [[DataManager sharedManager] deleteNoteWithId:assetObj.assetId];
                            }
                        }
                    }
                    else {
                        isUploadedSuccess = false;
                        [self saveAssedDataInOfflineMode];
                    }
                    
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                        if (isUploadedSuccess) {
                            //[self.syncUpdateButton setHidden:true];
                            
                            [SVProgressHUD showSuccessWithStatus:@"Uploaded Successfully"];
                            //[self.navigationController popToRootViewControllerAnimated:YES];
                            [self backToParent];
                            
                        }
                        else{
                            if (sessionExpired) {
                                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Session Expired" message:@"Please sign out and sign in again to synchronize data" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                [alertView show];
                            }
                            else {
                                [SVProgressHUD showErrorWithStatus:@"Upload Failed"];
                            }
                            
                        }
                    });
                });
            }
            else{
                if ([[DataManager sharedManager] isLoggedIn]) {
                    
                    [self saveAssedDataInOfflineMode];
                    [SVProgressHUD showSuccessWithStatus:@"Asset saved locally due to no internet connectivity"];
                    [self backToParent];
                }
                else {
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No Login Credentials Found" message:@"Signing in after turning on internet settings will enable synchronization of data" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }
                
            }
        }
        else {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Plant Missing" message:@"Please select plant details from Settings to proceed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil , nil];
            [alert show];
        }
        
    }
    else {
        
        [self saveAssedDataInOfflineMode];
        [SVProgressHUD showSuccessWithStatus:@"Asset saved locally as you are working in Standalone mode"];
        [self backToParent];
        
    }
    
    
}

-(void) saveAssedDataInOfflineMode {
    
    [[DataManager sharedManager] saveAssetData:assetObj withUpdate:isAssetToBeUpdated];
    if ([self.unableToLocateSwitch isOn]) {
        NSString* noteType;
        noteType = [NSString stringWithFormat:@"%d",(int)[self.unableToLocateSwitch isOn] ];
        [[DataManager sharedManager] saveNoteTypeDetailsWithId:assetObj.assetId withNote:noteType];
    }
    else {
        [[DataManager sharedManager] deleteNoteWithId:assetObj.assetId];
    }
    
}

-(NSString*)getJsonStringForSingleSyncUpdatesWithAsset{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self prepareDictonaryForSingleSyncUpdatesWithAsset:assetObj] options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(NSDictionary *)prepareDictonaryForSingleSyncUpdatesWithAsset:(AssetData *)asset {
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:asset.assetName forKey:@"name"];
    [dict setObject:asset.plantId forKey:@"Plant__c"];
    
    if (asset.isNewAsset) {
        [dict setObject:@"" forKey:@"Asset_id"];
    }
    else {
        [dict setObject:asset.assetId forKey:@"Asset_id"];
    }
    
    [dict setObject:asset.description forKey:@"Short_description__c"];
    [dict setObject:asset.tag forKey:@"Tag__c"];
    [dict setObject:asset.parentId forKey:@"Parent_Asset__c"];
    [dict setObject:asset.condition forKey:@"CONDITION__c"];
    [dict setObject:asset.operatorClassId forKey:@"classname"];
    //[dict setObject:asset.operatorSubclass forKey:@"OPERATOR_SUB_CLASS__c"];
    [dict setObject:asset.operatorType forKey:@"OPERATOR_TYPE__c"];
    [dict setObject:asset.type forKey:@"Type__c"];
    
    if ([self.unableToLocateSwitch isOn]) {
        [dict setObject:@"true" forKey:@"UNABLE_TO_LOCATE__c"];
    }
    else {
        [dict setObject:@"false" forKey:@"UNABLE_TO_LOCATE__c"];
    }
    
    return dict;
}
- (IBAction)upArrowButtonTapped:(id)sender {
    
    //if ([self checkIfConneectionValid]) {
        
        if (currentInternetStatus) {
            if ([[DataManager sharedManager] isInternetConnectionAvailable] && [[DataManager sharedManager] isLoggedIn]) {
                
                [SVProgressHUD showWithStatus:@"Downloading Parent Data" maskType:SVProgressHUDMaskTypeGradient];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    NSString* status;
                    NSString* errMsg;
                    
                    NSURL *theURL;
                    if ([[DataManager sharedManager] restEnv]) {
                        theURL = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=getparentassets&instance_url=%@&access_token=%@&assetid=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[assetObj.assetId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                    }
                    else  {
                        theURL = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=getparentassets&instance_url=%@&access_token=%@&assetid=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[assetObj.assetId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                    }
                    
                    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                    
                    [theRequest setValue:HEADER_REQUEST_VALUE forHTTPHeaderField:HEADER_REQUEST_KEY];
                    NSData *returnData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];
                    //NSString *listFile = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                    NSError *error;
                    NSDictionary* responseData = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers error:&error];
                    status = [responseData valueForKey:@"status"];
                    if (!error && !status) {
                        parentContent = [responseData valueForKey:@"assets"];
                    }
                    else {
                        if (status) {
                            errMsg = [responseData valueForKey:@"msg"];
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                        if (!status) {
                            if ([parentContent count]>0) {
                                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                                
                                CreateAssetViewController* controller = (CreateAssetViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"createassetcontroller"];
                                
                                AssetData* asset = [[AssetData alloc] init];
                                
                                asset.assetName = [parentContent valueForKey:@"Name"];
                                asset.assetId = [parentContent valueForKey:@"Id"];
                                asset.parent = [parentContent valueForKey:@"PARENT_ASSET__Name"];
                                asset.plantId = [parentContent valueForKey:@"Plant__id"];;
                                asset.plantName = [parentContent valueForKey:@"Plant__name"];;
                                asset.type = [parentContent valueForKey:@"TYPE__c"];
                                asset.tag = [parentContent valueForKey:@"Tag__c"];
                                asset.description = [parentContent valueForKey:@"Short_description__c"];
                                asset.unableToLocate = [[parentContent valueForKey:@"UNABLE_TO_LOCATE__c"] boolValue];
                                asset.condition = [parentContent valueForKey:@"CONDITION__c"];
                                asset.operatorClass = [parentContent valueForKey:@"Class__name"];
                                asset.operatorType = [parentContent valueForKey:@"OPERATOR_TYPE__c"];
                                asset.operatorClassId = [parentContent valueForKey:@"Class__id"];
                                asset.operatorSubclass = [parentContent valueForKey:@"SubClass__name"];
                                asset.operatorSubclassId = [parentContent valueForKey:@"SubClass__id"];
                                asset.category = [parentContent valueForKey:@"Category__name"];
                                asset.categoryId = [parentContent valueForKey:@"Category__id"];
                                
                                [controller setIsAssetToBeUpdated:true];
                                [controller setAssetToUpdate:asset];
                                
                                asset.parentId = [parentContent valueForKey:@"PARENT_ASSET__c"];
                                
                                [controller setCurrentInternetStatus:currentInternetStatus];
                                [controller setCurrentAssetViewType:1];
                                
                                [self.navigationController pushViewController:controller animated:YES];
                            }
                        }
                        else {
                            if (errMsg) {
                                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",errMsg]];
                            }
                            else{
                                [SVProgressHUD showErrorWithStatus:@"Downloading child failed"];
                            }
                            //status = nil;
                        }
                        
                    });
                });
            }
            else{
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connectivity" message:@"Please login to app after turning on internet settings to view this section" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else {
            [SVProgressHUD showWithStatus:@"Fetching Parent Data" maskType:SVProgressHUDMaskTypeGradient];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                parentContent = [[DataManager sharedManager] getAllParentForAssetId:assetObj.parentId];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    if ([parentContent count]>0) {
                        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                        
                        CreateAssetViewController* controller = (CreateAssetViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"createassetcontroller"];
                        
                        AssetData* asset = [[AssetData alloc] init];
                        
                        asset.assetName = [parentContent valueForKey:@"Name"];
                        asset.assetId = [parentContent valueForKey:@"Id"];
                        asset.parent = [parentContent valueForKey:@"PARENT_ASSET__Name"];
                        asset.plantId = [parentContent valueForKey:@"Plant__id"];;
                        asset.plantName = [parentContent valueForKey:@"Plant__name"];;
                        asset.type = [parentContent valueForKey:@"TYPE__c"];
                        asset.tag = [parentContent valueForKey:@"Tag__c"];
                        asset.description = [parentContent valueForKey:@"Short_description__c"];
                        asset.unableToLocate = [[parentContent valueForKey:@"UNABLE_TO_LOCATE__c"] boolValue];
                        asset.condition = [parentContent valueForKey:@"CONDITION__c"];
                        asset.operatorClass = [parentContent valueForKey:@"Class__name"];
                        asset.operatorType = [parentContent valueForKey:@"OPERATOR_TYPE__c"];
                        asset.operatorClassId = [parentContent valueForKey:@"Class__id"];
                        asset.operatorSubclass = [parentContent valueForKey:@"SubClass__name"];
                        asset.operatorSubclassId = [parentContent valueForKey:@"SubClass__id"];
                        asset.category = [parentContent valueForKey:@"Category__name"];
                        asset.categoryId = [parentContent valueForKey:@"Category__id"];
                        
                        [controller setIsAssetToBeUpdated:true];
                        [controller setAssetToUpdate:asset];
                        
                        asset.parentId = [parentContent valueForKey:@"PARENT_ASSET__c"];
                        
                        [controller setCurrentInternetStatus:currentInternetStatus];
                        [controller setCurrentAssetViewType:1];
                        
                        [self.navigationController pushViewController:controller animated:YES];
                    }
                    else {
                        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"No Records found in Database"]];
                        
                        //status = nil;
                    }
                    
                });
            });
        }
        
//    }
//    else {
//        
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Standalone Mode" message:@"This section is not available in Standalone mode." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//        
//    }
    
    
}
- (IBAction)assetCodingButtonTapped:(id)sender {
    
    assetObj.assetName=assetNameTxtField.text;
    assetObj.description = descriptionTxtField.text;
    assetObj.tag = tagTxtField.text;
    assetObj.parent = parentTxtField.text;
    assetObj.unableToLocate = [self.unableToLocateSwitch isOn];
    
    [self performSegueWithIdentifier:@"AssetCodingValuePushSegue" sender:nil];
    
}

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) backToParent {
    
    int flag = 0;
    NSMutableArray *newStack = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (id controller in newStack) {
        if ([controller isKindOfClass:[FindAssetViewController class]] || [controller isKindOfClass:[AssetsListViewController class]])
        {
            flag = 1;
            break;
        }
    }
    if (!flag) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        int tmpBreak = 0;
        while (!tmpBreak) {
            [newStack removeLastObject];
            if ([[newStack lastObject] isKindOfClass:[FindAssetViewController class]] || [[newStack lastObject] isKindOfClass:[AssetsListViewController class]]) {
                tmpBreak=1;
            }
        }
        [self.navigationController setViewControllers:newStack animated:YES];
    }
    
}

- (IBAction)homeButtonTapped:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)mapButtonTapped:(id)sender {
}
@end
