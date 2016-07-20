//
//  AssetCodingValueViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 21/04/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import "AssetCodingValueViewController.h"
#import "DataManager.h"
#import "PreviewAuditViewController.h"
#import "AddAuditViewController.h"
#import "SVProgressHUD.h"
#import "AFViewController.h"

@interface AssetCodingValueViewController ()

@end

@implementation AssetCodingValueViewController

@synthesize isAssetToBeUpdated,isAuditToBePreviewed,conditionTxtField,operatorClassTxtField,operatorSubclassTxtField,operatorTypeTxtField,assetToUpdate,unableToLocate,categoryTxtField,typeTxtField,isDoneTodayPreview;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    selectedPickerContent3 = [[NSMutableDictionary alloc] init];
    selectedPickerContent4 = [[NSMutableDictionary alloc] init];
    selectedPickerContent5 = [[NSMutableDictionary alloc] init];
    
    self.navigationController.navigationBarHidden = true;
    
    selectedOperatorClassId = @"";
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard:)];
    [self.contentScrollView addGestureRecognizer:gestureRecognizer];
    
    if (isAssetToBeUpdated) {
        
        conditionTxtField.text = assetToUpdate.condition;
        operatorTypeTxtField.text = assetToUpdate.operatorType;
        operatorClassTxtField.text = assetToUpdate.operatorClass;
        operatorSubclassTxtField.text = assetToUpdate.operatorSubclass;
        categoryTxtField.text = assetToUpdate.category;
        typeTxtField.text = assetToUpdate.type;
        
        [self setupValuesForClassIDifAssetUpdated];
        
        if ([[DataManager sharedManager] getLockRecordsDetails]) {
            
//            [operatorTypeTxtField setUserInteractionEnabled:false];
//            [operatorClassTxtField setUserInteractionEnabled:false];
//            [operatorSubclassTxtField setUserInteractionEnabled:false];
            
        }
        
    }
    
    if (isAuditToBePreviewed) {
        //[self.addAuditButton setTitle:@"Preview Audits" forState:UIControlStateNormal] ;
        [self.saveButton setHidden:true];
    }
    else {
        //[self.addAuditButton setTitle:@"Add Audits" forState:UIControlStateNormal] ;
        [self.internerStatusImgView setHidden:YES];
    }
    
    [self setupAssetCodingData];
    
    NSMutableArray* tmpArr = [[NSMutableArray alloc] init];
    tmpArr = [[DataManager sharedManager] getAssetCodingOptions];
    
    if([[tmpArr objectAtIndex:0] boolValue] == false) {
        [conditionTxtField setHidden:true];
        [self.conditionLabel setHidden:true];
    }
    if([[tmpArr objectAtIndex:1] boolValue] == false) {
        [operatorTypeTxtField setHidden:true];
        [self.operatorTypeLabel setHidden:true];
    }
    if([[tmpArr objectAtIndex:2] boolValue] == false) {
        [operatorClassTxtField setHidden:true];
        [self.operatorClassLabel setHidden:true];
        //[operatorSubclassTxtField setHidden:true];
        //[self.operatorSubclassLabel setHidden:true];
    }
    if([[tmpArr objectAtIndex:3] boolValue] == false) {
        [operatorSubclassTxtField setHidden:true];
        [self.operatorSubclassLabel setHidden:true];
    }
    if([[tmpArr objectAtIndex:4] boolValue] == false) {
        [categoryTxtField setHidden:true];
        [self.categoryLabel setHidden:true];
        //[operatorClassTxtField setHidden:true];
        //[self.operatorClassLabel setHidden:true];
        //[operatorSubclassTxtField setHidden:true];
        //[self.operatorSubclassLabel setHidden:true];
    }
    if([[tmpArr objectAtIndex:5] boolValue] == false) {
        [typeTxtField setHidden:true];
        [self.typeLabel setHidden:true];
    }
    
    viewCenter = self.view.center;
    showKeyboardAnimation = true;
    
    conditionTxtField.delegate = self;
    operatorClassTxtField.delegate = self;
    operatorSubclassTxtField.delegate = self;
    operatorTypeTxtField.delegate = self;
    categoryTxtField.delegate = self;
    typeTxtField.delegate = self;
    
    
    if ([[DataManager sharedManager] isInternetConnectionAvailable] && [self checkIfConneectionValid]) {
        NSLog(@"Internet available");
        self.internerStatusImgView.image = [UIImage imageNamed:@"connect-icon.png"];
    }
    else{
        NSLog(@"Internet not available");
        self.internerStatusImgView.image = [UIImage imageNamed:@"disconnect-icon.png"];
    }

    
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    conditionTxtField.leftView = paddingView;
    conditionTxtField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    categoryTxtField.leftView = paddingView1;
    categoryTxtField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    operatorClassTxtField.leftView = paddingView2;
    operatorClassTxtField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    operatorSubclassTxtField.leftView = paddingView3;
    operatorSubclassTxtField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingView4 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    operatorTypeTxtField.leftView = paddingView4;
    operatorTypeTxtField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingView5 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    typeTxtField.leftView = paddingView5;
    typeTxtField.leftViewMode = UITextFieldViewModeAlways;
    
    [self setupInitialView];
    
    
}

- (void) setupInitialView {
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    dict  = [[DataManager sharedManager] getAllDynamicLabelValues];
    
    if (dict.count > 0) {
        
        NSString* conditionStr = [dict valueForKey:@"CONDITION"];
        NSString* operatoryTypeStr = [dict valueForKey:@"OPERATOR_TYPE"];
        
        if (![conditionStr isEqual:[NSNull null]]) {
            self.conditionLabel.text = conditionStr;
        }
        if (![operatoryTypeStr isEqual:[NSNull null]]) {
            self.operatorTypeLabel.text = operatoryTypeStr;
        }        
    }
    
}


-(void) setupValuesForClassIDifAssetUpdated {
    
    
    if (![assetToUpdate.operatorSubclassId isEqualToString:@""]) {
        selectedOperatorClassId = assetToUpdate.operatorSubclassId;
    }
    else if (![assetToUpdate.operatorClassId isEqualToString:@""]) {
        selectedOperatorClassId = assetToUpdate.operatorClassId;
    }
    else {
        selectedOperatorClassId = assetToUpdate.categoryId;
    }
    
    
    
    /*NSMutableArray* categoryTmpArr = [[NSMutableArray alloc] init];
    NSMutableArray* classTmpArr = [[NSMutableArray alloc] init];
    NSMutableArray* subclassTmpArr = [[NSMutableArray alloc] init];
    
    categoryTmpArr = [[DataManager sharedManager] getCategoryDetails];
    classTmpArr = [[DataManager sharedManager] getOperatorClassDetails];
    subclassTmpArr = [[DataManager sharedManager] getOperatorSubclassDetails];
    
    if ([[subclassTmpArr valueForKey:@"id"] containsObject:classId]) {
        
        NSMutableDictionary* subclassDict = [[NSMutableDictionary alloc] init];
        subclassDict = [subclassTmpArr objectAtIndex:[[subclassTmpArr valueForKey:@"id"] indexOfObject:classId]];
        operatorSubclassTxtField.text = [subclassDict valueForKey:@"value"];
        
        NSMutableDictionary* classDict = [[NSMutableDictionary alloc] init];
        classDict = [classTmpArr objectAtIndex:[[classTmpArr valueForKey:@"class"] indexOfObject:[subclassDict valueForKey:@"description"]]];
        
        NSMutableDictionary* categoryDict = [[NSMutableDictionary alloc] init];
        
        if ([classDict count] > 0) {
            
            operatorClassTxtField.text = [classDict valueForKey:@"value"];
            
            categoryDict = [categoryTmpArr objectAtIndex:[[categoryTmpArr valueForKey:@"category"] indexOfObject:[classDict valueForKey:@"description"]]];
            
            if ([categoryDict count] > 0) {
                categoryTxtField.text = [categoryDict valueForKey:@"value"];
            }
            
        }
        
    }
    else if ([[classTmpArr valueForKey:@"id"] containsObject:classId]) {
        
        operatorSubclassTxtField.text = @"";
        
        NSMutableDictionary* classDict = [[NSMutableDictionary alloc] init];
        classDict = [classTmpArr objectAtIndex:[[classTmpArr valueForKey:@"id"] indexOfObject:classId]];
        
        NSMutableDictionary* categoryDict = [[NSMutableDictionary alloc] init];
        
            operatorClassTxtField.text = [classDict valueForKey:@"value"];
            
            categoryDict = [categoryTmpArr objectAtIndex:[[categoryTmpArr valueForKey:@"category"] indexOfObject:[classDict valueForKey:@"description"]]];
            
            if ([categoryDict count] > 0) {
                categoryTxtField.text = [categoryDict valueForKey:@"value"];
            }
            
    

        
    }
    else if ([[categoryTmpArr valueForKey:@"id"] containsObject:classId]) {
        
        operatorSubclassTxtField.text = @"";
        operatorClassTxtField.text = @"";
        
        NSMutableDictionary* categoryDict = [[NSMutableDictionary alloc] init];
        categoryDict = [categoryTmpArr objectAtIndex:[[categoryTmpArr valueForKey:@"id"] indexOfObject:classId]];
        
        categoryTxtField.text = [categoryDict valueForKey:@"value"];
        
        
        
        
        
    }*/
    
}


-(BOOL) checkIfConneectionValid {
    
    if ([[[DataManager sharedManager] selectedConnectionSettings] isEqualToString:@"STANDALONE"]) {
        return false;
    }
    
    return true;
    
}


-(void) setupAssetCodingData {
    
    
    
    //CONDITION
    
    conditionArr = [[NSMutableArray alloc] init];
    conditionArr = [[DataManager sharedManager] getConditionsDetails];
    
    picker1 = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 480, 320, 270)];
    picker1.delegate = self;
    picker1.dataSource = self;
    picker1.showsSelectionIndicator = YES;
    picker1.tag = 101;
    
    UIToolbar *toolBar1= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    [toolBar1 setBarStyle:UIBarStyleBlackOpaque];
    UIButton *customButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton1.frame = CGRectMake(0, 0, 60, 33);
    [customButton1 addTarget:self action:@selector(conditionPickerViewDoneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
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
    
    if (conditionArr.count>0) {
        conditionTxtField.inputView = picker1;
        conditionTxtField.inputAccessoryView = toolBar1;
        selectedPickerContent1 = [NSString stringWithFormat:@"%@, %@",[[conditionArr objectAtIndex:0] valueForKey:@"value"],[[conditionArr objectAtIndex:0] valueForKey:@"description"]];
        
        if (isAssetToBeUpdated) {
            
            NSMutableArray* tmpArr = [[NSMutableArray alloc] init];
            tmpArr = [conditionArr valueForKey:@"value"];
            
            if ([tmpArr containsObject:conditionTxtField.text]) {
                
                conditionTxtField.text = [NSString stringWithFormat:@"%@, %@",[[conditionArr objectAtIndex:[tmpArr indexOfObject:conditionTxtField.text]] valueForKey:@"value"],[[conditionArr objectAtIndex:[tmpArr indexOfObject:conditionTxtField.text]] valueForKey:@"description"]];
                
            }
            
        }
        
        
    }
    else {
        conditionTxtField.tag = 0;
    }
    
    //OPERTAOR_TYPE
    
    operatorTypeArr = [[NSMutableArray alloc] init];
    operatorTypeArr = [[DataManager sharedManager] getSelectedOpearatorTypeDetails];
    
    picker2 = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 480, 320, 270)];
    picker2.delegate = self;
    picker2.dataSource = self;
    picker2.showsSelectionIndicator = YES;
    picker2.tag = 102;
    
    UIToolbar *toolBar2= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    [toolBar2 setBarStyle:UIBarStyleBlackOpaque];
    UIButton *customButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton2.frame = CGRectMake(0, 0, 60, 33);
    [customButton2 addTarget:self action:@selector(operatorTypePickerViewDoneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    customButton2.showsTouchWhenHighlighted = YES;
    //[customButton setTitle:@"Done" forState:UIControlStateNormal];
    [customButton2 setImage:[UIImage imageNamed:@"checkbox-selected.png"] forState:UIControlStateNormal];
    
    UILabel *lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 33)];
    [lbl2 setText:@"Choose an Option"];
    [lbl2 setTextColor:[UIColor whiteColor]];
    [lbl2 setFont:[UIFont systemFontOfSize:14.0]];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:lbl2];
    
    UIBarButtonItem *barCustomButton2 =[[UIBarButtonItem alloc] initWithCustomView:customButton2];
    UIBarButtonItem* flexibleSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolBar2.items = [[NSArray alloc] initWithObjects:item2,flexibleSpace2,barCustomButton2,nil];
    
    if (operatorTypeArr.count>0) {
        operatorTypeTxtField.inputView = picker2;
        operatorTypeTxtField.inputAccessoryView = toolBar2;
        selectedPickerContent2 = [NSString stringWithFormat:@"%@, %@",[[operatorTypeArr objectAtIndex:0] valueForKey:@"value"],[[operatorTypeArr objectAtIndex:0] valueForKey:@"description"]];
        
        if (isAssetToBeUpdated) {
            
            NSMutableArray* tmpArr = [[NSMutableArray alloc] init];
            tmpArr = [operatorTypeArr valueForKey:@"value"];
            
            if ([tmpArr containsObject:operatorTypeTxtField.text]) {
                
                operatorTypeTxtField.text = [NSString stringWithFormat:@"%@, %@",[[operatorTypeArr objectAtIndex:[tmpArr indexOfObject:operatorTypeTxtField.text]] valueForKey:@"value"],[[operatorTypeArr objectAtIndex:[tmpArr indexOfObject:operatorTypeTxtField.text]] valueForKey:@"description"]];
                
            }
            
        }
        
        
    }
    else {
        operatorTypeTxtField.tag = 0;
    }
    
    //OPERATOR_CLASS
    
    operatorClassArr = [[NSMutableArray alloc] init];
    operatorClassArr = [[DataManager sharedManager] getOperatorClassDetails];
    
    picker3 = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 480, 320, 270)];
    picker3.delegate = self;
    picker3.dataSource = self;
    picker3.showsSelectionIndicator = YES;
    picker3.tag = 103;
    
    //if(![categoryTxtField.text isEqualToString:@""]) {
        [self setupOperatorClassDataForParentClass];
    //}
    
    
    //OPERATOR_SUBCLASS
    
    operatorSubclassArr = [[NSMutableArray alloc] init];
    operatorSubclassArr = [[DataManager sharedManager] getOperatorSubclassDetails];
    
    picker4 = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 480, 320, 270)];
    picker4.delegate = self;
    picker4.dataSource = self;
    picker4.showsSelectionIndicator = YES;
    picker4.tag = 104;
    
    //if(![operatorClassTxtField.text isEqualToString:@""]) {
        [self setupOperatorSubclassDataForParentClass];
    //}
    
    
    
    //CATEGORY
    
    categoryArr = [[NSMutableArray alloc] init];
    categoryArr = [[DataManager sharedManager] getCategoryDetails];
    
    picker5 = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 480, 320, 270)];
    picker5.delegate = self;
    picker5.dataSource = self;
    picker5.showsSelectionIndicator = YES;
    picker5.tag = 105;
    
    UIToolbar *toolBar5= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    [toolBar5 setBarStyle:UIBarStyleBlackOpaque];
    UIButton *customButton5 = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton5.frame = CGRectMake(0, 0, 60, 33);
    [customButton5 addTarget:self action:@selector(categoryPickerViewDoneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    customButton5.showsTouchWhenHighlighted = YES;
    //[customButton setTitle:@"Done" forState:UIControlStateNormal];
    [customButton5 setImage:[UIImage imageNamed:@"checkbox-selected.png"] forState:UIControlStateNormal];
    
    UILabel *lbl5 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 33)];
    [lbl5 setText:@"Choose an Option"];
    [lbl5 setTextColor:[UIColor whiteColor]];
    [lbl5 setFont:[UIFont systemFontOfSize:14.0]];
    UIBarButtonItem *item5 = [[UIBarButtonItem alloc] initWithCustomView:lbl5];
    
    UIBarButtonItem *barCustomButton5 =[[UIBarButtonItem alloc] initWithCustomView:customButton5];
    UIBarButtonItem* flexibleSpace5 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolBar5.items = [[NSArray alloc] initWithObjects:item5,flexibleSpace5,barCustomButton5,nil];
    
    if (categoryArr.count>0) {
        categoryTxtField.inputView = picker5;
        categoryTxtField.inputAccessoryView = toolBar5;
        selectedPickerContent5 = [categoryArr objectAtIndex:0];
        
        if (isAssetToBeUpdated) {
            
            NSMutableArray* tmpArr = [[NSMutableArray alloc] init];
            tmpArr = [categoryArr valueForKey:@"value"];
            
            if ([tmpArr containsObject:[[categoryTxtField.text componentsSeparatedByString:@","] objectAtIndex:0]]) {
                
                categoryTxtField.text = [NSString stringWithFormat:@"%@,%@",[[categoryArr objectAtIndex:[tmpArr indexOfObject:categoryTxtField.text]] valueForKey:@"value"],[[categoryArr objectAtIndex:[tmpArr indexOfObject:categoryTxtField.text]] valueForKey:@"designation"]];
                
            }
            
        }
        
        
    }
    else {
        categoryTxtField.tag = 0;
    }
    
    
    //TYPE
    
    
    typeArr = [NSMutableArray arrayWithObjects:@"ASSET",@"LOCATION",@"EQUIPMENT",@"SPARE",@"TOOL",@"COMPONENT", nil];
    
    picker6 = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 480, 320, 270)];
    picker6.delegate = self;
    picker6.dataSource = self;
    picker6.showsSelectionIndicator = YES;
    picker6.tag = 106;
    
    UIToolbar *toolBar6= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    [toolBar6 setBarStyle:UIBarStyleBlackOpaque];
    UIButton *customButton6 = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton6.frame = CGRectMake(0, 0, 60, 33);
    [customButton6 addTarget:self action:@selector(typePickerViewDoneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    customButton6.showsTouchWhenHighlighted = YES;
    //[customButton setTitle:@"Done" forState:UIControlStateNormal];
    [customButton6 setImage:[UIImage imageNamed:@"checkbox-selected.png"] forState:UIControlStateNormal];
    
    UILabel *lbl6 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 33)];
    [lbl6 setText:@"Choose an Option"];
    [lbl6 setTextColor:[UIColor whiteColor]];
    [lbl6 setFont:[UIFont systemFontOfSize:14.0]];
    UIBarButtonItem *item6 = [[UIBarButtonItem alloc] initWithCustomView:lbl6];
    
    UIBarButtonItem *barCustomButton6 =[[UIBarButtonItem alloc] initWithCustomView:customButton6];
    UIBarButtonItem* flexibleSpace6 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolBar6.items = [[NSArray alloc] initWithObjects:item6,flexibleSpace6,barCustomButton6,nil];
    
    if (typeArr.count>0) {
        typeTxtField.inputView = picker6;
        typeTxtField.inputAccessoryView = toolBar6;
        selectedPickerContent6 = [typeArr objectAtIndex:0];
        
        if (!isAssetToBeUpdated) {
            typeTxtField.text = selectedPickerContent6;
        }
    
    }
    else {
        typeTxtField.tag = 0;
    }

    
    
}


-(void) setupOperatorClassDataForParentClass {
    
    operatorClassSlaveArr = [[NSMutableArray alloc] init];
    
    //if([selectedPickerContent5 componentsSeparatedByString:@","].count > 1) {
        
    NSString* parentVal = [selectedPickerContent5 valueForKey:@"category"] ;
    
        for(int i = 0 ; i<operatorClassArr.count ; i++) {
            
            NSDictionary* dict = [operatorClassArr objectAtIndex:i];
            
            if ([[[[DataManager sharedManager] getAssetCodingOptions] objectAtIndex:4] boolValue] == false || ([categoryTxtField.text isEqualToString:@""])) {
                
                [operatorClassSlaveArr addObject:dict];
                
            }
            else {
                
                if([[dict valueForKey:@"description"] isEqualToString:parentVal]) {
                    [operatorClassSlaveArr addObject:dict];
                }
                
            }
            
        }
        
    //}
    
    UIToolbar *toolBar3= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    [toolBar3 setBarStyle:UIBarStyleBlackOpaque];
    UIButton *customButton3 = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton3.frame = CGRectMake(0, 0, 60, 33);
    [customButton3 addTarget:self action:@selector(operatorClassPickerViewDoneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    customButton3.showsTouchWhenHighlighted = YES;
    //[customButton setTitle:@"Done" forState:UIControlStateNormal];
    [customButton3 setImage:[UIImage imageNamed:@"checkbox-selected.png"] forState:UIControlStateNormal];
    
    UILabel *lbl3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 33)];
    [lbl3 setText:@"Choose an Option"];
    [lbl3 setTextColor:[UIColor whiteColor]];
    [lbl3 setFont:[UIFont systemFontOfSize:14.0]];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithCustomView:lbl3];
    
    UIBarButtonItem *barCustomButton3 =[[UIBarButtonItem alloc] initWithCustomView:customButton3];
    UIBarButtonItem* flexibleSpace3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolBar3.items = [[NSArray alloc] initWithObjects:item3,flexibleSpace3,barCustomButton3,nil];
    
    if (operatorClassSlaveArr.count>0) {
        operatorClassTxtField.inputView = picker3;
        operatorClassTxtField.inputAccessoryView = toolBar3;
        selectedPickerContent3 = [operatorClassSlaveArr objectAtIndex:0];
        
        [picker3 reloadAllComponents];
        
        if (isAssetToBeUpdated) {
            
            NSMutableArray* tmpArr = [[NSMutableArray alloc] init];
            tmpArr = [operatorClassSlaveArr valueForKey:@"value"];
            
            if ([tmpArr containsObject:[[operatorClassTxtField.text componentsSeparatedByString:@","] objectAtIndex:0]]) {
                
                operatorClassTxtField.text = [NSString stringWithFormat:@"%@, %@,%@",[[operatorClassSlaveArr objectAtIndex:[tmpArr indexOfObject:operatorClassTxtField.text]] valueForKey:@"value"],[[operatorClassSlaveArr objectAtIndex:[tmpArr indexOfObject:operatorClassTxtField.text]] valueForKey:@"description"],[[operatorClassSlaveArr objectAtIndex:[tmpArr indexOfObject:operatorClassTxtField.text]] valueForKey:@"designation"]];
                
            }
            
        }
    }
    else {
        operatorClassTxtField.inputView = nil;
        operatorClassTxtField.inputAccessoryView = nil;
        operatorClassTxtField.tag = 0;
    }
    
}



-(void) setupOperatorSubclassDataForParentClass {
    
    operatorSubclassSlaveArr = [[NSMutableArray alloc] init];
    
    //if([selectedPickerContent3 componentsSeparatedByString:@","].count > 1) {
        
        NSString* parentVal = [selectedPickerContent3 valueForKey:@"class"];
        
        for(int i = 0 ; i<operatorSubclassArr.count ; i++) {
            
            NSDictionary* dict = [operatorSubclassArr objectAtIndex:i];
            
            if ([[[[DataManager sharedManager] getAssetCodingOptions] objectAtIndex:2] boolValue] == false || ([operatorClassTxtField.text isEqualToString:@""])) {
                
                [operatorSubclassSlaveArr addObject:dict];
                
            }
            else {
                
                if([[dict valueForKey:@"description"] isEqualToString:parentVal]) {
                    [operatorSubclassSlaveArr addObject:dict];
                }
                
            }
            
        }
        
    //}
    
    UIToolbar *toolBar4= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    [toolBar4 setBarStyle:UIBarStyleBlackOpaque];
    UIButton *customButton4 = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton4.frame = CGRectMake(0, 0, 60, 33);
    [customButton4 addTarget:self action:@selector(operatorSubclassPickerViewDoneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    customButton4.showsTouchWhenHighlighted = YES;
    //[customButton setTitle:@"Done" forState:UIControlStateNormal];
    [customButton4 setImage:[UIImage imageNamed:@"checkbox-selected.png"] forState:UIControlStateNormal];
    
    UILabel *lbl4 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 33)];
    [lbl4 setText:@"Choose an Option"];
    [lbl4 setTextColor:[UIColor whiteColor]];
    [lbl4 setFont:[UIFont systemFontOfSize:14.0]];
    UIBarButtonItem *item4 = [[UIBarButtonItem alloc] initWithCustomView:lbl4];
    
    UIBarButtonItem *barCustomButton4 =[[UIBarButtonItem alloc] initWithCustomView:customButton4];
    UIBarButtonItem* flexibleSpace4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolBar4.items = [[NSArray alloc] initWithObjects:item4,flexibleSpace4,barCustomButton4,nil];
    
    if (operatorSubclassSlaveArr.count>0) {
        operatorSubclassTxtField.inputView = picker4;
        operatorSubclassTxtField.inputAccessoryView = toolBar4;
        selectedPickerContent4 = [operatorSubclassSlaveArr objectAtIndex:0];
        
        [picker4 reloadAllComponents];
        
        if (isAssetToBeUpdated) {
            
            NSMutableArray* tmpArr = [[NSMutableArray alloc] init];
            tmpArr = [operatorSubclassSlaveArr valueForKey:@"value"];
            
            if ([tmpArr containsObject:[[operatorSubclassTxtField.text componentsSeparatedByString:@","] objectAtIndex:0]]) {
                
                operatorSubclassTxtField.text = [NSString stringWithFormat:@"%@, %@,%@",[[operatorSubclassSlaveArr objectAtIndex:[tmpArr indexOfObject:operatorSubclassTxtField.text]] valueForKey:@"value"],[[operatorSubclassSlaveArr objectAtIndex:[tmpArr indexOfObject:operatorSubclassTxtField.text]] valueForKey:@"description"],[[operatorSubclassSlaveArr objectAtIndex:[tmpArr indexOfObject:operatorSubclassTxtField.text]] valueForKey:@"designation"]];
                
            }
            
        }
    }
    else {
        operatorSubclassTxtField.inputView = nil;
        operatorSubclassTxtField.inputAccessoryView = nil;
        operatorSubclassTxtField.tag = 0;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) updateAssetData {
    
    if (conditionTxtField.tag==0) {
        assetToUpdate.condition = conditionTxtField.text;
    }
    else {
        assetToUpdate.condition = [[conditionTxtField.text componentsSeparatedByString:@","] firstObject];
    }
    if (operatorTypeTxtField.tag==0) {
        assetToUpdate.operatorType = operatorTypeTxtField.text;
    }
    else {
        assetToUpdate.operatorType = [[operatorTypeTxtField.text componentsSeparatedByString:@","] firstObject];
    }
    if (operatorClassTxtField.tag==0) {
        assetToUpdate.operatorClass = [[operatorClassTxtField.text componentsSeparatedByString:@","] firstObject];
    }
    else {
        assetToUpdate.operatorClass = [[operatorClassTxtField.text componentsSeparatedByString:@","] firstObject];
        //assetToUpdate.operatorClassId = [[operatorClassSlaveArr objectAtIndex:[[operatorClassSlaveArr valueForKey:@"value"] indexOfObject:operatorClassTxtField.text]] valueForKey:@"id"];
        
        
    }
    if (operatorSubclassTxtField.tag==0) {
        assetToUpdate.operatorSubclass = [[operatorSubclassTxtField.text componentsSeparatedByString:@","] firstObject];
    }
    else {
        assetToUpdate.operatorSubclass = [[operatorSubclassTxtField.text componentsSeparatedByString:@","] firstObject];
        //assetToUpdate.operatorSubclassId = [[operatorSubclassSlaveArr objectAtIndex:[[operatorSubclassSlaveArr valueForKey:@"value"] indexOfObject:operatorSubclassTxtField.text]] valueForKey:@"id"];
    }
    if (categoryTxtField.tag==0) {
        assetToUpdate.category = [[categoryTxtField.text componentsSeparatedByString:@","] objectAtIndex:0];
    }
    else {
        assetToUpdate.category = [[categoryTxtField.text componentsSeparatedByString:@","] objectAtIndex:0];
        //assetToUpdate.categoryId = [[categoryArr objectAtIndex:[[categoryArr valueForKey:@"value"] indexOfObject:categoryTxtField.text]] valueForKey:@"id"];
    }
    
    assetToUpdate.type = typeTxtField.text;
    assetToUpdate.operatorClassId = selectedOperatorClassId;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    [self updateAssetData];
    
    if ([[segue identifier] isEqualToString:@"previewAuditSegue"]) {
        [[DataManager sharedManager] saveOnlyAssetData:assetToUpdate];
        
        AFViewController* controller = [segue destinationViewController];
        controller.currentAssetId = assetToUpdate.assetId;
        controller.assetObj = assetToUpdate;
        controller.isDoneTodayPreview = isDoneTodayPreview;
        
    }
    else if ([[segue identifier] isEqualToString:@"addAuditSegue"]){
        AddAuditViewController* auditController = [segue destinationViewController];
        auditController.currentAssetId = assetToUpdate.assetId;
        auditController.currentAssetName = assetToUpdate.assetName;
        auditController.assetObj = assetToUpdate;
        auditController.isAssetToBeUpdated = isAssetToBeUpdated;
    }
    
}


- (IBAction)saveButtonTapped:(id)sender {
    
    [self updateAssetData];
    
    if (assetToUpdate.plantId && !([assetToUpdate.plantId isEqualToString:@""])) {
        if ([[DataManager sharedManager] isInternetConnectionAvailable] && [[DataManager sharedManager] isLoggedIn]) {
            
            [SVProgressHUD showWithStatus:@"Uploading Asset" maskType:SVProgressHUDMaskTypeGradient];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                //[self uploadAuditImageToServer];
                
                
                BOOL isUploadedSuccess = true;
                BOOL sessionExpired = false;
                
                
                
                NSString *post = [[DataManager sharedManager] getJsonStringForSyncUpdatesWithAsset:assetToUpdate];//[self getJsonStringForSingleSyncUpdatesWithAsset];
                NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
                
                NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
                
                NSURL *theURL;
//                if ([[DataManager sharedManager] restEnv]) {
//                    theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=createAsset&instance_url=%@&access_token=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken]]];
//                }
//                else {
//                    theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=createAsset&instance_url=%@&access_token=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken]]];
//                }
                
                
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
                        [[DataManager sharedManager] deleteNoteWithId:assetToUpdate.assetId];
                        //[[DataManager sharedManager] deleteOnlyAssetWithId:assetToUpdate.assetId];
                        
                        NSMutableDictionary* responseData1 = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
                        
                        if (![[responseData1 valueForKey:@"id"] isEqual:[NSNull null]]) {
                            assetToUpdate.assetId = [responseData1 valueForKey:@"id"];
                            assetToUpdate.isNewAsset = false;
                        }
                        
                    }
                    else {
                        if (!([responseDataConv rangeOfString:@"Session expired or invalid"].location == NSNotFound)) {
                            sessionExpired = true;
                        }
                        isUploadedSuccess = false;
                        [[DataManager sharedManager] saveAssetData:assetToUpdate withUpdate:isAssetToBeUpdated];
                        
                        if (unableToLocate) {
                            NSString* noteType;
                            noteType = [NSString stringWithFormat:@"%d",(int)unableToLocate ];
                            [[DataManager sharedManager] saveNoteTypeDetailsWithId:assetToUpdate.assetId withNote:noteType];
                        }
                        else {
                            [[DataManager sharedManager] deleteNoteWithId:assetToUpdate.assetId];
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

-(void) saveAssedDataInOfflineMode {
    
    [[DataManager sharedManager] saveAssetData:assetToUpdate withUpdate:isAssetToBeUpdated];
    if (unableToLocate) {
        NSString* noteType;
        noteType = [NSString stringWithFormat:@"%d",(int)unableToLocate ];
        [[DataManager sharedManager] saveNoteTypeDetailsWithId:assetToUpdate.assetId withNote:noteType];
    }
    else {
        [[DataManager sharedManager] deleteNoteWithId:assetToUpdate.assetId];
    }
    
}

-(NSString*)getJsonStringForSingleSyncUpdatesWithAsset{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self prepareDictonaryForSingleSyncUpdatesWithAsset:assetToUpdate] options:NSJSONWritingPrettyPrinted error:&error];
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
    
    if (unableToLocate) {
        [dict setObject:@"true" forKey:@"UNABLE_TO_LOCATE__c"];
    }
    else {
        [dict setObject:@"false" forKey:@"UNABLE_TO_LOCATE__c"];
    }
    
    return dict;
}

- (IBAction)addAuditButtonTapped:(id)sender {
    
    if ([self checkIfConneectionValid]) {
        
        if (assetToUpdate.plantId && !([assetToUpdate.plantId isEqualToString:@""])) {
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
    
    if (thePickerView.tag == 101) {
        [l1 setText: [NSString stringWithFormat:@"%@, %@",[[conditionArr objectAtIndex:row] valueForKey:@"value"],[[conditionArr objectAtIndex:row] valueForKey:@"description"]]];
    }
    if (thePickerView.tag == 102) {
        [l1 setText: [NSString stringWithFormat:@"%@, %@",[[operatorTypeArr objectAtIndex:row] valueForKey:@"value"],[[operatorTypeArr objectAtIndex:row] valueForKey:@"description"]]];
    }
    if (thePickerView.tag == 103) {
        [l1 setText: [[operatorClassSlaveArr objectAtIndex:row] valueForKey:@"value"]];
    }
    if (thePickerView.tag == 104) {
        [l1 setText: [[operatorSubclassSlaveArr objectAtIndex:row] valueForKey:@"value"]];
    }
    if (thePickerView.tag == 106) {
        [l1 setText: [typeArr objectAtIndex:row]];
    }
    if (thePickerView.tag == 105) {
        [l1 setText: [NSString stringWithFormat:@"%@",[[categoryArr objectAtIndex:row] valueForKey:@"value"]]];
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
    
    if (pickerView.tag == 101) {
        return [conditionArr count];
    }
    if (pickerView.tag == 102) {
        return [operatorTypeArr count];
    }
    if (pickerView.tag == 103) {
        return [operatorClassSlaveArr count];
    }
    if (pickerView.tag == 104) {
         return [operatorSubclassSlaveArr count];
    }
    if (pickerView.tag == 106) {
        return [typeArr count];
    }
    return [categoryArr count];

}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if (pickerView.tag == 101) {
        return [NSString stringWithFormat:@"%@, %@",[[conditionArr objectAtIndex:row] valueForKey:@"value"],[[conditionArr objectAtIndex:row] valueForKey:@"description"]];
    }
    if (pickerView.tag == 102) {
        return [NSString stringWithFormat:@"%@, %@",[[operatorTypeArr objectAtIndex:row] valueForKey:@"value"],[[operatorTypeArr objectAtIndex:row] valueForKey:@"description"]];
    }
    if (pickerView.tag == 103) {
        return [[operatorClassSlaveArr objectAtIndex:row] valueForKey:@"value"];
    }
    if (pickerView.tag == 104) {
        return [[operatorSubclassSlaveArr objectAtIndex:row] valueForKey:@"value"];
    }
    if (pickerView.tag == 106) {
        return [typeArr objectAtIndex:row];
    }
    return [NSString stringWithFormat:@"%@",[[categoryArr objectAtIndex:row] valueForKey:@"value"]];
    
}

// Do something with the selected row.
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (pickerView.tag == 101) {
        NSLog(@"You selected this: %@", [[conditionArr objectAtIndex:row] valueForKey:@"description"]);
        selectedPickerContent1 = [NSString stringWithFormat:@"%@, %@",[[conditionArr objectAtIndex:row] valueForKey:@"value"],[[conditionArr objectAtIndex:row] valueForKey:@"description"]];
    }
    if (pickerView.tag == 102) {
        NSLog(@"You selected this: %@", [[operatorTypeArr objectAtIndex:row] valueForKey:@"description"]);
        selectedPickerContent2 = [NSString stringWithFormat:@"%@, %@",[[operatorTypeArr objectAtIndex:row] valueForKey:@"value"],[[operatorTypeArr objectAtIndex:row] valueForKey:@"description"]];
    }
    if (pickerView.tag == 103) {
        NSLog(@"You selected this: %@", [[operatorClassArr objectAtIndex:row] valueForKey:@"description"]);
        selectedPickerContent3 = [operatorClassSlaveArr objectAtIndex:row];
        selectedOperatorClassId = [[operatorClassSlaveArr objectAtIndex:row] valueForKey:@"id"];
    }
    if (pickerView.tag == 104) {
        NSLog(@"You selected this: %@", [[operatorSubclassArr objectAtIndex:row] valueForKey:@"description"]);
        selectedPickerContent4 = [operatorSubclassSlaveArr objectAtIndex:row];
        selectedOperatorClassId = [[operatorSubclassSlaveArr objectAtIndex:row] valueForKey:@"id"];
    }
    if (pickerView.tag == 105) {
        NSLog(@"You selected this: %@", [[categoryArr objectAtIndex:row] valueForKey:@"value"]);
        selectedPickerContent5 = [categoryArr objectAtIndex:row];
        selectedOperatorClassId = [[categoryArr objectAtIndex:row] valueForKey:@"id"];
    }
    if (pickerView.tag == 106) {
        selectedPickerContent6 = [typeArr objectAtIndex:row];
    }
    [pickerView reloadComponent:component];
    
}


-(void) conditionPickerViewDoneButtonTapped:(id)sender {
    
    showKeyboardAnimation = true;
    
    conditionTxtField.text = selectedPickerContent1;
    [conditionTxtField resignFirstResponder];
    
}

-(void) typePickerViewDoneButtonTapped:(id)sender {
    
    showKeyboardAnimation = true;
    
    typeTxtField.text = selectedPickerContent6;
    [typeTxtField resignFirstResponder];
    
}

-(void) operatorTypePickerViewDoneButtonTapped:(id)sender {
    
    showKeyboardAnimation = true;
    
    operatorTypeTxtField.text = selectedPickerContent2;
    [operatorTypeTxtField resignFirstResponder];
    
}



-(void) categoryPickerViewDoneButtonTapped:(id)sender {
    
    showKeyboardAnimation = true;
    
    categoryTxtField.text = [NSString stringWithFormat:@"%@,%@",[selectedPickerContent5 valueForKey:@"value"],[selectedPickerContent5 valueForKey:@"designation"]];
    //categoryTxtField.text = @"";
    
    selectedOperatorClassId = [selectedPickerContent5 valueForKey:@"id"];
    
    [self setupOperatorClassDataForParentClass];
    
    [categoryTxtField resignFirstResponder];
    
}

-(void) operatorClassPickerViewDoneButtonTapped:(id)sender {
    
    showKeyboardAnimation = true;
    
    operatorClassTxtField.text = [NSString stringWithFormat:@"%@,%@",[selectedPickerContent3 valueForKey:@"value"],[selectedPickerContent3 valueForKey:@"designation"]];
    operatorSubclassTxtField.text = @"";
    
    selectedOperatorClassId = [selectedPickerContent3 valueForKey:@"id"];
    
    [self setupOperatorSubclassDataForParentClass];
    
    [operatorClassTxtField resignFirstResponder];
    
}



-(void) operatorSubclassPickerViewDoneButtonTapped:(id)sender {
    
    showKeyboardAnimation = true;
    
    operatorSubclassTxtField.text = [NSString stringWithFormat:@"%@,%@",[selectedPickerContent4 valueForKey:@"value"],[selectedPickerContent4 valueForKey:@"designation"]];
    selectedOperatorClassId = [selectedPickerContent4 valueForKey:@"id"];
    [operatorSubclassTxtField resignFirstResponder];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    showKeyboardAnimation = true;
    [textField endEditing:YES];
    return true;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    showKeyboardAnimation = true;
    [self.view endEditing:YES];
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

-(void) hideKeyBoard:(id) sender
{
    // Do whatever such as hiding the keyboard
    showKeyboardAnimation = true;
    [self.view endEditing:YES];
}

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
