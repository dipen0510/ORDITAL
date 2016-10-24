//
//  AddAuditViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 21/09/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "AddAuditViewController.h"
#import "AssetData.h"
#import "FindAssetViewController.h"
#import "AssetsListViewController.h"
#import "SVProgressHUD.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface AddAuditViewController ()

@end

@implementation AddAuditViewController{
    int tappedAuditTag;
}

@synthesize currentAssetId,currentAssetName,assetObj,isAssetToBeUpdated,isMoreAuditAdded,tmpAuditDataArr;
@synthesize equipmentImgView,tagImgView,nameplateImgView;

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
    
    
    
    currentLocation = [[CLLocation alloc] init];
    locationManager = [[CLLocationManager alloc] init];

    if (!isMoreAuditAdded) {
        auditDataArr = [[NSMutableArray alloc] init];
    }
    else {
        [self loadDataSourceIfMoreAuditAdded];
    }
    
    auditTypeArr = [[NSMutableArray alloc] init];
    
    auditTypeArr = [[DataManager sharedManager] getAllAuditTypes];
    
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingLocation];
    
    [self addTapGestureToAuditImage];
    
    if ([[DataManager sharedManager] isInternetConnectionAvailable] && [self checkIfConneectionValid]) {
        NSLog(@"Internet available");
        self.internetStatusImgView.image = [UIImage imageNamed:@"connect-icon.png"];
    }
    else{
        NSLog(@"Internet not available");
        self.internetStatusImgView.image = [UIImage imageNamed:@"disconnect-icon.png"];
    }
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
    
    
    if (isMoreAuditAdded) {
        isMoreButtonTapped = true;
        [self moreButtonTapped:nil];
    }
    
    
    
    [self initializePageParameters];
    [self setupUI];
    
    
}


- (void) loadDataSourceIfMoreAuditAdded {
    
    auditDataArr = [[NSMutableArray alloc] init];
    NSMutableArray* audArr = [[NSMutableArray alloc] initWithArray: [[DataManager sharedManager] getAuditDataForAssetId:currentAssetId]];
    
    for (int i = 0; i<audArr.count; i++) {
        
        NSMutableArray* tmpArr = [[NSMutableArray alloc] init];
        int tmpIndex=  (int)[auditDataArr count];
        
        AuditData* audObj = [audArr objectAtIndex:i];
        if ([[auditDataArr valueForKey:@"Name"] containsObject:audObj.auditType]) {
            
            tmpIndex = (int)[[auditDataArr valueForKey:@"Name"] indexOfObject:audObj.auditType];
            tmpArr = [[auditDataArr objectAtIndex:tmpIndex] valueForKey:@"AuditArr"];
            
        }
        
        [tmpArr addObject:audObj];
        
        if (tmpIndex < [auditDataArr count]) {
            [auditDataArr removeObjectAtIndex:tmpIndex];
        }
        
        NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
        [tmpDict setObject:audObj.auditType forKey:@"Name"];
        [tmpDict setObject:tmpArr forKey:@"AuditArr"];
        
        [auditDataArr addObject:tmpDict];
        
    }

    
}

#pragma mark - SETUP CUSTOM AUDIT TYPE

- (void) initializePageParameters {
    
    auditTypeCount = (int)[auditTypeArr count];
    currentPage  = 0;
    lastPageAuditTypeCount = auditTypeCount % 3;
    
    numberOfPages = (int) auditTypeCount / 3;
    
    if (lastPageAuditTypeCount != 0) {
        numberOfPages++;
    }
    
    
    
}


- (void) setupUI {
    
    int currentType = currentPage * 3;
    
    self.equipmentCountLbl.text = @"00";
    self.tagCoutnLbl.text = @"00";
    self.nameplateCountLbl.text = @"00";
    
    if (currentPage == numberOfPages - 1) {
        
        if (lastPageAuditTypeCount == 0) {
            
            self.nameplateNameLbl.text = [[auditTypeArr objectAtIndex:currentType] valueForKey:@"Name"];
            currentType++;
            self.tagNameLbl.text = [[auditTypeArr objectAtIndex:currentType] valueForKey:@"Name"];
            currentType++;
            self.equipmentNameLbl.text = [[auditTypeArr objectAtIndex:currentType] valueForKey:@"Name"];
            
            equipmentImgView.hidden = NO;
            tagImgView.hidden = NO;
            nameplateImgView.hidden = NO;
            self.equipmentNameLbl.hidden = NO;
            self.tagNameLbl.hidden = NO;
            self.nameplateNameLbl.hidden = NO;
            self.equipmentCountView.hidden = NO;
            self.nameplateCountView.hidden = NO;
            self.tagCountView.hidden = NO;
            
            NSMutableArray* arr = [[NSMutableArray alloc] init];
            arr = [auditDataArr valueForKey:@"Name"];
            
            if ([arr containsObject:self.equipmentNameLbl.text]) {
                
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                NSMutableArray* subArr = [[NSMutableArray alloc] init];
                dict = [auditDataArr objectAtIndex:[arr indexOfObject:self.equipmentNameLbl.text]];
                subArr = [dict valueForKey:@"AuditArr"];
                
                if (subArr.count>9) {
                    self.equipmentCountLbl.text = [NSString stringWithFormat:@"%lu",(unsigned long)subArr.count];
                }
                else {
                    self.equipmentCountLbl.text = [NSString stringWithFormat:@"0%lu",(unsigned long)subArr.count];
                }
                
            }
            if ([arr containsObject:self.tagNameLbl.text]) {
                
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                NSMutableArray* subArr = [[NSMutableArray alloc] init];
                dict = [auditDataArr objectAtIndex:[arr indexOfObject:self.tagNameLbl.text]];
                subArr = [dict valueForKey:@"AuditArr"];
                
                if (subArr.count>9) {
                    self.tagCoutnLbl.text = [NSString stringWithFormat:@"%lu",(unsigned long)subArr.count];
                }
                else {
                    self.tagCoutnLbl.text = [NSString stringWithFormat:@"0%lu",(unsigned long)subArr.count];
                }
                
            }
            if ([arr containsObject:self.nameplateNameLbl.text]) {
                
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                NSMutableArray* subArr = [[NSMutableArray alloc] init];
                dict = [auditDataArr objectAtIndex:[arr indexOfObject:self.nameplateNameLbl.text]];
                subArr = [dict valueForKey:@"AuditArr"];
                
                if (subArr.count>9) {
                    self.nameplateCountLbl.text = [NSString stringWithFormat:@"%lu",(unsigned long)subArr.count];
                }
                else {
                    self.nameplateCountLbl.text = [NSString stringWithFormat:@"0%lu",(unsigned long)subArr.count];
                }
                
            }
            
        }
        else if (lastPageAuditTypeCount == 1) {
            
            self.nameplateNameLbl.text = [[auditTypeArr objectAtIndex:currentType] valueForKey:@"Name"];
            
            equipmentImgView.hidden = YES;
            tagImgView.hidden = YES;
            nameplateImgView.hidden = NO;
            self.equipmentNameLbl.hidden = YES;
            self.tagNameLbl.hidden = YES;
            self.nameplateNameLbl.hidden = NO;
            self.equipmentCountView.hidden = YES;
            self.nameplateCountView.hidden = NO;
            self.tagCountView.hidden = YES;
            
            NSMutableArray* arr = [[NSMutableArray alloc] init];
            arr = [auditDataArr valueForKey:@"Name"];
            
            if ([arr containsObject:self.nameplateNameLbl.text]) {
                
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                NSMutableArray* subArr = [[NSMutableArray alloc] init];
                dict = [auditDataArr objectAtIndex:[arr indexOfObject:self.nameplateNameLbl.text]];
                subArr = [dict valueForKey:@"AuditArr"];
                
                if (subArr.count>9) {
                    self.nameplateCountLbl.text = [NSString stringWithFormat:@"%lu",(unsigned long)subArr.count];
                }
                else {
                    self.nameplateCountLbl.text = [NSString stringWithFormat:@"0%lu",(unsigned long)subArr.count];
                }
                
            }
            
        }
        else {
            
            self.tagNameLbl.text = [[auditTypeArr objectAtIndex:currentType] valueForKey:@"Name"];
            currentType++;
            self.nameplateNameLbl.text = [[auditTypeArr objectAtIndex:currentType] valueForKey:@"Name"];
            
            equipmentImgView.hidden = YES;
            tagImgView.hidden = NO;
            nameplateImgView.hidden = NO;
            self.equipmentNameLbl.hidden = YES;
            self.tagNameLbl.hidden = NO;
            self.nameplateNameLbl.hidden = NO;
            self.equipmentCountView.hidden = YES;
            self.nameplateCountView.hidden = NO;
            self.tagCountView.hidden = NO;
            
            NSMutableArray* arr = [[NSMutableArray alloc] init];
            arr = [auditDataArr valueForKey:@"Name"];
            
            if ([arr containsObject:self.tagNameLbl.text]) {
                
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                NSMutableArray* subArr = [[NSMutableArray alloc] init];
                dict = [auditDataArr objectAtIndex:[arr indexOfObject:self.tagNameLbl.text]];
                subArr = [dict valueForKey:@"AuditArr"];
                
                if (subArr.count>9) {
                    self.tagCoutnLbl.text = [NSString stringWithFormat:@"%lu",(unsigned long)subArr.count];
                }
                else {
                    self.tagCoutnLbl.text = [NSString stringWithFormat:@"0%lu",(unsigned long)subArr.count];
                }
                
            }
            if ([arr containsObject:self.nameplateNameLbl.text]) {
                
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                NSMutableArray* subArr = [[NSMutableArray alloc] init];
                dict = [auditDataArr objectAtIndex:[arr indexOfObject:self.nameplateNameLbl.text]];
                subArr = [dict valueForKey:@"AuditArr"];
                
                if (subArr.count>9) {
                    self.nameplateCountLbl.text = [NSString stringWithFormat:@"%lu",(unsigned long)subArr.count];
                }
                else {
                    self.nameplateCountLbl.text = [NSString stringWithFormat:@"0%lu",(unsigned long)subArr.count];
                }
                
            }
        }
        
    }
    else {
        
        self.nameplateNameLbl.text = [[auditTypeArr objectAtIndex:currentType] valueForKey:@"Name"];
        currentType++;
        self.tagNameLbl.text = [[auditTypeArr objectAtIndex:currentType] valueForKey:@"Name"];
        currentType++;
        self.equipmentNameLbl.text = [[auditTypeArr objectAtIndex:currentType] valueForKey:@"Name"];
        
        equipmentImgView.hidden = NO;
        tagImgView.hidden = NO;
        nameplateImgView.hidden = NO;
        self.equipmentNameLbl.hidden = NO;
        self.tagNameLbl.hidden = NO;
        self.nameplateNameLbl.hidden = NO;
        self.equipmentCountView.hidden = NO;
        self.nameplateCountView.hidden = NO;
        self.tagCountView.hidden = NO;
        
        
        
        NSMutableArray* arr = [[NSMutableArray alloc] init];
        arr = [auditDataArr valueForKey:@"Name"];
        
        if ([arr containsObject:self.equipmentNameLbl.text]) {
            
            NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
            NSMutableArray* subArr = [[NSMutableArray alloc] init];
            dict = [auditDataArr objectAtIndex:[arr indexOfObject:self.equipmentNameLbl.text]];
            subArr = [dict valueForKey:@"AuditArr"];
            
            if (subArr.count>9) {
                self.equipmentCountLbl.text = [NSString stringWithFormat:@"%lu",(unsigned long)subArr.count];
            }
            else {
                self.equipmentCountLbl.text = [NSString stringWithFormat:@"0%lu",(unsigned long)subArr.count];
            }
            
        }
        if ([arr containsObject:self.tagNameLbl.text]) {
            
            NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
            NSMutableArray* subArr = [[NSMutableArray alloc] init];
            dict = [auditDataArr objectAtIndex:[arr indexOfObject:self.tagNameLbl.text]];
            subArr = [dict valueForKey:@"AuditArr"];
            
            if (subArr.count>9) {
                self.tagCoutnLbl.text = [NSString stringWithFormat:@"%lu",(unsigned long)subArr.count];
            }
            else {
                self.tagCoutnLbl.text = [NSString stringWithFormat:@"0%lu",(unsigned long)subArr.count];
            }
            
        }
        if ([arr containsObject:self.nameplateNameLbl.text]) {
            
            NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
            NSMutableArray* subArr = [[NSMutableArray alloc] init];
            dict = [auditDataArr objectAtIndex:[arr indexOfObject:self.nameplateNameLbl.text]];
            subArr = [dict valueForKey:@"AuditArr"];
            
            if (subArr.count>9) {
                self.nameplateCountLbl.text = [NSString stringWithFormat:@"%lu",(unsigned long)subArr.count];
            }
            else {
                self.nameplateCountLbl.text = [NSString stringWithFormat:@"0%lu",(unsigned long)subArr.count];
            }
            
        }
        
    }
    
    
}



-(BOOL) checkIfConneectionValid {
    
    if ([[[DataManager sharedManager] selectedConnectionSettings] isEqualToString:@"STANDALONE"]) {
        return false;
    }
    
    return true;
    
}

-(void)addTapGestureToAuditImage{
    UITapGestureRecognizer *tapped1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAuditImageTap:)];
    UITapGestureRecognizer *tapped2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAuditImageTap:)];
    UITapGestureRecognizer *tapped3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAuditImageTap:)];
    tapped1.numberOfTapsRequired = 1;
    tapped2.numberOfTapsRequired = 1;
    tapped3.numberOfTapsRequired = 1;
    [equipmentImgView addGestureRecognizer:tapped1];
    [tagImgView addGestureRecognizer:tapped2];
    [nameplateImgView addGestureRecognizer:tapped3];
}

-(void)onAuditImageTap:(UITapGestureRecognizer*)gesture{
    tappedAuditTag = (int)gesture.view.tag;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        //[self presentModalViewController:imagePicker animated:YES];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    currentLocation = newLocation;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    long count = 0;
    
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    //UIImage* thumbImg = [self resizeUploadImage:image withScalingFactor:10.0];
    NSDictionary* infoDir = [NSDictionary dictionaryWithDictionary:[info valueForKey:UIImagePickerControllerMediaMetadata]];
    NSString* auditDateTime = [[infoDir objectForKey:@"{TIFF}"] valueForKey:@"DateTime"];
    NSArray* tmparr = [auditDateTime componentsSeparatedByString:@":"];
    auditDateTime = [NSString stringWithFormat:@"%@-%@-%@: %@: %@",[tmparr objectAtIndex:0],[tmparr objectAtIndex:1],[tmparr objectAtIndex:2],[tmparr objectAtIndex:3],[tmparr objectAtIndex:4]];
    
    
    [self setupAuditWithImage:[self resizeUploadImage:image withScalingFactor:[[[DataManager sharedManager] getSelectedImgQuality] floatValue]] andDateTime:auditDateTime];
    

    // You have the image. You can use this to present the image in the next view like you require in `#3`.
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)setupAuditWithImage:(UIImage*)img andDateTime:(NSString*)dateTime{
    
    int realTappedAuditTag = tappedAuditTag;
    
    if (realTappedAuditTag == 3) {
        realTappedAuditTag = 1;
    }
    else if (realTappedAuditTag == 1) {
        realTappedAuditTag = 3;
    }
    
    int auditTypeTappedIndex = (currentPage * 3) + realTappedAuditTag - 1;
    NSString* auditTypeTappedName = [[auditTypeArr objectAtIndex:auditTypeTappedIndex] valueForKey:@"Name"];
    NSMutableArray* tempArr = [[NSMutableArray alloc] init];
    int tempIndex = (int)[auditDataArr count];
    
    
    if ([[auditDataArr valueForKey:@"Name"] containsObject:auditTypeTappedName]) {
        
        tempIndex = (int)[[auditDataArr valueForKey:@"Name"] indexOfObject:auditTypeTappedName];
        tempArr = [[auditDataArr objectAtIndex:tempIndex] valueForKey:@"AuditArr"];
        
    }
    
    
//    for (int i = 0; i<auditDataArr.count; i++) {
//        
//        if ([[[auditDataArr objectAtIndex:i] valueForKey:@"Name"] isEqualToString:auditTypeTappedName]) {
//            
//            tempArr = [[auditDataArr objectAtIndex:i] valueForKey:@"AuditArr"];
//            tempIndex = i;
//            
//            break;
//            
//        }
//        
//    }
    
    
    AuditData* audit = [[AuditData alloc] init];
    
    audit = [[AuditData alloc] init];
    audit.auditId = [[NSUUID UUID] UUIDString];
    audit.assetId = currentAssetId;
    audit.assetName = currentAssetName;
    audit.auditType = auditTypeTappedName;
    audit.dateTime = dateTime;
    audit.latitude = currentLocation.coordinate.latitude;
    audit.longitude = currentLocation.coordinate.longitude;
    audit.altitude = [currentLocation altitude];
    audit.imgURL = [[[DataManager sharedManager] auditImagePath] stringByAppendingPathComponent:[self generateAuditImageNameForType:audit.auditType WithIndex:([tempArr count])]];
    audit.auditImg = img;
    
    [tempArr addObject:audit];
    
    if (tempIndex < [auditDataArr count]) {
        [auditDataArr removeObjectAtIndex:tempIndex];
    }
    
    NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
    [tmpDict setObject:auditTypeTappedName forKey:@"Name"];
    [tmpDict setObject:tempArr forKey:@"AuditArr"];
    
    [auditDataArr addObject:tmpDict];
    
    if (tappedAuditTag == 1) {
        
        if (tempArr.count>9) {
            self.equipmentCountLbl.text = [NSString stringWithFormat:@"%lu",(unsigned long)tempArr.count];
        }
        else {
            self.equipmentCountLbl.text = [NSString stringWithFormat:@"0%lu",(unsigned long)tempArr.count];
        }
        
    }
    else if (tappedAuditTag == 2) {
        
        if (tempArr.count>9) {
            self.tagCoutnLbl.text = [NSString stringWithFormat:@"%lu",(unsigned long)tempArr.count];
        }
        else {
            self.tagCoutnLbl.text = [NSString stringWithFormat:@"0%lu",(unsigned long)tempArr.count];
        }
        
    }
    else {
        
        if (tempArr.count>9) {
            self.nameplateCountLbl.text = [NSString stringWithFormat:@"%lu",(unsigned long)tempArr.count];
        }
        else {
            self.nameplateCountLbl.text = [NSString stringWithFormat:@"0%lu",(unsigned long)tempArr.count];
        }
        
    }
    
}

-(NSString *)generateAuditImageNameForType:(NSString *)type WithIndex:(NSInteger)i{
    
    i++;    //To start counter from 1 instead of 0
    
    NSString* str = [[NSString alloc] initWithString:currentAssetName] ;
    NSString* countStr = @"";
    if (i<10) {
        countStr = [NSString stringWithFormat:@"00%ld",i];
    }
    else if (i<100) {
        countStr = [NSString stringWithFormat:@"0%ld",i];
    }
    else {
        countStr = [NSString stringWithFormat:@"%ld",i];
    }
    
    return [str stringByAppendingString:[NSString stringWithFormat:@"_%@_%@.jpg",[type uppercaseString],countStr]];
}

- (NSString*)GetCurrentTimeStamp
{
    NSDateFormatter *objDateformat = [[NSDateFormatter alloc] init];
    [objDateformat setDateFormat:@"yyyyMMdd_hhmmssSSS"];
    NSString    *strTime = [objDateformat stringFromDate:[NSDate date]];
    NSLog(@"The Timestamp is = %@",strTime);
    return strTime;
}

- (IBAction)onDoneAudit:(id)sender {
    
    [SVProgressHUD showWithStatus:@"Saving Audits" maskType:SVProgressHUDMaskTypeGradient];
    
    [locationManager stopUpdatingLocation];
    locationManager = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        [[DataManager sharedManager] saveAssetData:assetObj withUpdate:isAssetToBeUpdated];
        
        
        for (int i = 0; i<auditDataArr.count; i++) {
            
            NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
            NSMutableArray* tmpArr = [[NSMutableArray alloc] init];
            tmpDict = [auditDataArr objectAtIndex:i];
            tmpArr = [tmpDict valueForKey:@"AuditArr"];
            
            for (int j = 0; j<tmpArr.count; j++) {
                
                AuditData* audit = [tmpArr objectAtIndex:j];
                [[DataManager sharedManager] saveAuditData:audit];
                [[DataManager sharedManager] saveAuditImage:audit.auditImg withName:[[audit.imgURL componentsSeparatedByString:@"/"] lastObject]];
                
            }
            
        }
        

        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self backToParent];
        });
    });
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

-(UIImage*) resizeUploadImage:(UIImage*) image withScalingFactor:(float)factor
{
    CGSize imgViewSize = CGSizeMake(image.size.width/factor, image.size.height/factor);
    float oldWidth = image.size.width;
    float scaleFactor = imgViewSize.width / oldWidth;
    
    float newHeight = image.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [image drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}*/



- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)moreButtonTapped:(id)sender {
    
    currentPage++;
    
    if (currentPage == numberOfPages) {
        currentPage = 0;
    }
    
    [self setupUI];
    
}



@end
