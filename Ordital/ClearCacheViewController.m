//
//  ClearCacheViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 30/10/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "ClearCacheViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DataManager.h"
#import "SVProgressHUD.h"
#import "ClearCacheTableViewCell.h"

@interface ClearCacheViewController ()

@end

@implementation ClearCacheViewController

@synthesize cacheOptionsTableView;

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
    
    cellSelected = [[NSMutableArray alloc] init];
    
    //cacheOptionsTableView.layer.borderWidth = 1.0f;
    //cacheOptionsTableView.layer.borderColor = [UIColor grayColor].CGColor;
    cacheFieldArr = [NSArray arrayWithObjects:@"Downloaded Assets",@"Created Assets",@"Session Info",@"Setting Data", nil];
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
    
    self.cacheOptionsTableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
//    /* Create custom view to display section header... */
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, tableView.frame.size.width, 18)];
//    [label setFont:[UIFont boldSystemFontOfSize:15.0]];
//    [label setTextColor:[UIColor darkGrayColor]];
//    
//    
//    /* Section header is in 0th index... */
//    [label setText:@"SELECT CACHE OPTIONS"];
//    [view addSubview:label];
//    [view setBackgroundColor:[UIColor whiteColor]]; //your background color...
//    return view;
//}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 45.0;
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [cacheFieldArr count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 65.0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CacheFieldCell";
    
    ClearCacheTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib=[[NSBundle mainBundle] loadNibNamed:@"ClearCacheTableViewCell" owner:self options:nil];
        cell=[nib objectAtIndex:0];
    }
    
    
    // Configure the cell...
   
    cell.cacheLbl.text = [cacheFieldArr objectAtIndex:indexPath.row];
    
    if ([cellSelected containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])
    {
        cell.cacheImgView.image = [UIImage imageNamed:@"checkbox-selected.png"];
    }
    else
    {
        cell.cacheImgView.image = [UIImage imageNamed:@"checkbox-normal.png"];
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //if you want only one cell to be selected use a local NSIndexPath property instead of array. and use the code below
    //self.selectedIndexPath = indexPath;
    
    //the below code will allow multiple selection
    if ([cellSelected containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])
    {
        [cellSelected removeObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    }
    else
    {
        [cellSelected addObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    }
    [tableView reloadData];
    
}

- (IBAction)clearCacheButtonTapped:(id)sender {
    [SVProgressHUD showWithStatus:@"Clearing Cache" maskType:SVProgressHUDMaskTypeGradient];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if ([cellSelected containsObject:@"0"]) {
            [[DataManager sharedManager] deleteAllDownloadsData];
        }
        if ([cellSelected containsObject:@"1"]) {
            [[DataManager sharedManager] deleteAllAssetsAndAudits];
        }
        if ([cellSelected containsObject:@"2"]) {
            [[DataManager sharedManager] deleteAuthToken];
            [[DataManager sharedManager] setIsLoggedIn:false];
        }
        if ([cellSelected containsObject:@"3"]) {
            
            [[DataManager sharedManager] deleteAuthToken];
            [[DataManager sharedManager] deleteAllDownloadsData];
            [[DataManager sharedManager] deleteAllAssetsAndAudits];
            [[DataManager sharedManager] deletePlantDetails];
            
            [[DataManager sharedManager] saveEnvironmentDetailsWithName:@""];
            [[DataManager sharedManager] setIsLoggedIn:false];
            [[DataManager sharedManager] setSelectedPlantSettings:nil];
            [[DataManager sharedManager] setSelectedEnvironmentSettings:@""];
            [[DataManager sharedManager] saveTypeDetailsWithName:@"ASSET"];
            [[DataManager sharedManager] saveImQualityWithValue:@"2.0"];
            
            
            [[DataManager sharedManager] savePlantSectionDetailsWithName:@""];
            [[DataManager sharedManager] saveSystemDetailsWithName:@""];
            [[DataManager sharedManager] saveCriticalityDetailsWithName:@""];
            [[DataManager sharedManager] saveSourceDocsDetailsWithName:@""];
            //[[DataManager sharedManager] saveIACDetailsWithName:@"False"];
            [[DataManager sharedManager] saveIsSearchOnSetWithValue:NO];
            
            [[DataManager sharedManager] savePlantDetailsWithId:@"" withName:@"" andOperatingUnit:@""];
            [[DataManager sharedManager] saveSelectedSetDetailsWithName:@"" andSetId:@""];
            
            [[DataManager sharedManager] saveSyncRecordsWithValue:YES];
            
            [[DataManager sharedManager] deleteConditionsDetails];
            [[DataManager sharedManager] deleteOperatorTypeDetails];
            [[DataManager sharedManager] deleteOperatorClassDetails];
            [[DataManager sharedManager] deleteOperatorSubclassDetails];
            [[DataManager sharedManager] deleteCategoryDetails];
            
            [[DataManager sharedManager] deleteTodayDetails];
            
            [[DataManager sharedManager] deleteAuditTypeDetails];
            [[DataManager sharedManager] addDefaultAuditTypeValuesToDB];
            
            [[DataManager sharedManager] saveAssetCodingOptionsForCondition:true andOperatorType:true andOperatorClass:true andOperatorSubclass:true andCategory:true andType:true];
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Cache Cleared"];
            [self.navigationController popViewControllerAnimated:YES];
        });
    });
   
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
