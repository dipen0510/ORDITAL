//
//  FindAssetViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 24/09/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "FindAssetViewController.h"
#import "DataManager.h"
#import "SVProgressHUD.h"
#import "CreateAssetViewController.h"
#import "AssetsListViewController.h"
#import "AssetData.h"

@interface FindAssetViewController ()

@end

@implementation FindAssetViewController

@synthesize isSearchedContentToBeSelected,internetStatusImg,todoCount,doneCount;

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
    
    self.navigationController.navigationBarHidden = true;
    selectedIndex = -1;
    self.uncompletedView.tag = 0;
    self.completedView.tag = 1;
    
    if ([[DataManager sharedManager] isInternetConnectionAvailable]) {
        internetStatusImg.image = [UIImage imageNamed:@"connect-icon.png"];
        internetStatus = 1;
    }
    else{
        internetStatusImg.image = [UIImage imageNamed:@"disconnect-icon.png"];
        internetStatus = 0;
    }
    
    self.assetSearchBar.delegate  =self;
    
    nameContentArr = [[NSMutableArray alloc] init];
    // Add some data for demo purposes.
    /*[nameContentArr addObject:@"ORDITAL_AU001"];
    [nameContentArr addObject:@"BEIA-ELEC"];
    [nameContentArr addObject:@"BEIA-FLARE"];
    [nameContentArr addObject:@"BEIA-GAS"];*/
    
    descriptionContentArr = [[NSMutableArray alloc] init];
    /*[descriptionContentArr addObject:@"Gate Valve(locked closed)"];
    [descriptionContentArr addObject:@"File general"];
    [descriptionContentArr addObject:@"File general"];
    [descriptionContentArr addObject:@"File general"];*/
    searchContentArr = [[NSMutableArray alloc] init];
    
    parentContentArr = [[NSMutableArray alloc] init];
    childContentArr = [[NSMutableArray alloc] init];
    
    iacValue = @"False";
    isSearchOnSet = [[DataManager sharedManager] getIsSearchOnSetDetails];
    
    assetIdToBeSyncedArr = [[NSMutableArray alloc] init];
    scrollAssetContentArr = [[NSMutableArray alloc] init];
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
    
    if (![self checkIfConneectionValid]) {
        
        internetStatusImg.image = [UIImage imageNamed:@"disconnect-icon.png"];
        internetStatus = 0;
        
        [self.segmentControl setHidden:YES];
        
    }
    else {
        
        [self.uncompletedImg setImage:[UIImage imageNamed:@"to-do-icon-selected.png"]];
        [self.uncompletedLbl setTextColor:[UIColor orangeColor]];
        [self.uncompletedValLbl setTextColor:[UIColor orangeColor]];
        
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeSegment0:)];
        [self.uncompletedView addGestureRecognizer:gestureRecognizer];
        self.uncompletedView.userInteractionEnabled = YES;
        UITapGestureRecognizer *gestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeSegment1:)];
        [self.completedView addGestureRecognizer:gestureRecognizer1];
        self.completedView.userInteractionEnabled = YES;
        
    }
    
    [self.assetSearchBar setImage:[UIImage imageNamed:@"search-icon.png"]
       forSearchBarIcon:UISearchBarIconSearch
                  state:UIControlStateNormal];
    [self.assetSearchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"search-text-field.png"] forState:UIControlStateNormal];
    
    self.assetSearchBar.searchTextPositionAdjustment = UIOffsetMake(10.0f, 0.0f);
    
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = true;
}


-(void) changeSegment0 :(id)sender {
    
    [self.uncompletedImg setImage:[UIImage imageNamed:@"to-do-icon-selected.png"]];
    [self.uncompletedLbl setTextColor:[UIColor orangeColor]];
    [self.uncompletedValLbl setTextColor:[UIColor orangeColor]];
    
    [self.completedImg setImage:[UIImage imageNamed:@"done-icon-normal.png"]];
    [self.completedLbl setTextColor:[UIColor whiteColor]];
    [self.completedValLbl setTextColor:[UIColor whiteColor]];
    
    segmentSelectedIndex = 0;
    [self segmentControlValueChanged:sender];
    
}

-(void) changeSegment1 :(id)sender {
    
    [self.uncompletedImg setImage:[UIImage imageNamed:@"to-do-icon-normal.png"]];
    [self.uncompletedLbl setTextColor:[UIColor whiteColor]];
    [self.uncompletedValLbl setTextColor:[UIColor whiteColor]];
    
    [self.completedImg setImage:[UIImage imageNamed:@"done-icon-selected.png"]];
    [self.completedLbl setTextColor:[UIColor orangeColor]];
    [self.completedValLbl setTextColor:[UIColor orangeColor]];
    
    segmentSelectedIndex = 1;
    [self segmentControlValueChanged:sender];
    
}


-(BOOL) checkIfConneectionValid {
    
    if ([[[DataManager sharedManager] selectedConnectionSettings] isEqualToString:@"STANDALONE"]) {
        return false;
    }
    
    return true;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
//    if (internetStatus) {
        [self.uncompletedValLbl setText:todoCount];
        [self.uncompletedValLbl sizeToFit];
        [self.completedValLbl setText:doneCount];
        [self.completedValLbl sizeToFit];

//    }
//    else {
//        
//        if (segmentSelectedIndex) {
//            [self.completedValLbl setText:[NSString stringWithFormat:@"%ld",[nameContentArr count]]];
//            [self.completedValLbl sizeToFit];
//        }
//        else {
//            [self.uncompletedValLbl setText:[NSString stringWithFormat:@"%ld",[nameContentArr count]]];
//            [self.uncompletedValLbl sizeToFit];
//        }
//
//        
//    }
    
    return [nameContentArr count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"AssetFieldCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
    
    // Configure the cell...
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.text = [nameContentArr objectAtIndex:indexPath.row];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.text = [descriptionContentArr objectAtIndex:indexPath.row];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex = indexPath.row;
    if (isSearchedContentToBeSelected) {
        [[DataManager sharedManager] setTmpParentId:[[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Id"]];
        [[DataManager sharedManager] setTmpParentName:[nameContentArr objectAtIndex:selectedIndex]];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        
        CreateAssetViewController* controller = (CreateAssetViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"createassetcontroller"];
        
        AssetData* asset = [[AssetData alloc] init];
        
        asset.description = [descriptionContentArr objectAtIndex:selectedIndex];
        asset.assetName = [nameContentArr objectAtIndex:selectedIndex];
        
        asset.assetId = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Id"];
        
        asset.parent = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"PARENT_ASSET__Name"];
        asset.plantId = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Plant__id"];
        asset.plantName = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Plant__name"];
        asset.type = [[searchContentArr objectAtIndex:selectedIndex] valueForKeyPath:@"TYPE__c"];
        
        asset.unableToLocate = [[[searchContentArr objectAtIndex:selectedIndex] valueForKeyPath:@"UNABLE_TO_LOCATE__c"] boolValue];
        asset.condition = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"CONDITION__c"];
        asset.operatorType = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"OPERATOR_TYPE__c"];
        asset.operatorClass = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Class__name"];
        asset.operatorClassId = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Class__id"];
        asset.operatorSubclass = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"SubClass__name"];
        asset.operatorSubclassId = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"SubClass__id"];
        asset.category = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Category__name"];
        asset.categoryId = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Category__id"];
        
        if (isSearchOnSet && internetStatus) {
            asset.tag = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"TAG__c"];
            [self replaceOldKeysWithNewKeys:searchContentArr];
        }
        else {
            asset.tag = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Tag__c"];
            scrollAssetContentArr = searchContentArr;
        }
        
        if ([asset.tag isEqualToString:@"(null)"]) {
            asset.tag = @"";
        }
        if ([asset.parent isEqualToString:@"(null)"]) {
            asset.parent = @"";
        }
        
        [controller setIsAssetToBeUpdated:true];
        [controller setAssetToUpdate:asset];
        
        [controller setScrollContentArr:scrollAssetContentArr];
        [controller setCurrentAssetViewType:1];
        [controller setCurrentScrollAssetIndex:selectedIndex];
        [controller setCurrentInternetStatus:internetStatus];
        [controller setIsDoneTodayPreview:YES];
        
        asset.parentId = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"PARENT_ASSET__c"];
        
        if ([asset.parentId isEqualToString:@"(null)"]) {
            asset.parentId = @"";
        }
        
        [self.navigationController pushViewController:controller animated:YES];
        
        //[self.navigationController performSegueWithIdentifier:@"AssetControllerSegue" sender:nil];
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.assetSearchBar resignFirstResponder];
    searchContentArr = [[NSMutableArray alloc] init];
    descriptionContentArr = [[NSMutableArray alloc] init];
    nameContentArr = [[NSMutableArray alloc] init];
    
    if (segmentSelectedIndex) {
        iacValue = @"True";
    }
    else {
        iacValue = @"False";
    }
    
    if ([self checkIfConneectionValid]) {
        
        if ([[DataManager sharedManager] isInternetConnectionAvailable]) {
            [self searchOnlineWithText:searchBar.text];
            internetStatus = 1;
        }
        else {
            [self searchOfflineWithText:searchBar.text];
            internetStatus = 0;
        }

        
    }
    else {
        
        [self searchOfflineInStandaloneWithText:searchBar.text];
        internetStatus = 0;
        
    }
    
}

-(long) getCountForOffline:(NSMutableArray* )arr {
    
    if ([iacValue isEqualToString:@"True"]) {
        assetIdToBeSyncedArr = [[[DataManager sharedManager] getAllAssetsToBeSynced]valueForKey:@"id"];
        for (int i = 0; i<[assetIdToBeSyncedArr count]; i++) {
            if ([[arr valueForKey:@"Id"] containsObject:[assetIdToBeSyncedArr objectAtIndex:i]] ) {
                [arr removeObjectAtIndex:[[arr valueForKey:@"Id"] indexOfObject:[assetIdToBeSyncedArr objectAtIndex:i]]];
            }
        }
    }
    if ([[DataManager sharedManager] getPunchListDetails]) {
        NSMutableArray* tmpArr = [[NSMutableArray alloc] init];
        
        for (int i = 0; i<[arr count]; i++) {
            if ([[[arr objectAtIndex:i] valueForKey:@"PUNCH_LIST__c"] boolValue] ) {
                [tmpArr addObject:[arr objectAtIndex:i]];
            }
        }
        
        arr = tmpArr;
    }
    
    return [arr count];
    
}

-(void)filterAssetsToBeSyncedFromSearch {
    assetIdToBeSyncedArr = [[[DataManager sharedManager] getAllAssetsToBeSynced]valueForKey:@"id"];
    for (int i = 0; i<[assetIdToBeSyncedArr count]; i++) {
        if ([[searchContentArr valueForKey:@"Id"] containsObject:[assetIdToBeSyncedArr objectAtIndex:i]] ) {
            [searchContentArr removeObjectAtIndex:[[searchContentArr valueForKey:@"Id"] indexOfObject:[assetIdToBeSyncedArr objectAtIndex:i]]];
        }
    }
}


-(void)filterAssetsToBeSyncedFromSearchForPunchList {
    
    NSMutableArray* tmpArr = [[NSMutableArray alloc] init];
    
    for (int i = 0; i<[searchContentArr count]; i++) {
        if ([[[searchContentArr objectAtIndex:i] valueForKey:@"PUNCH_LIST__c"] boolValue] ) {
            [tmpArr addObject:[searchContentArr objectAtIndex:i]];
        }
    }
    
    searchContentArr = tmpArr;
}


-(void)searchOnlineWithText:(NSString* )text {
    if ([[DataManager sharedManager] isLoggedIn]) {
        
        [SVProgressHUD showWithStatus:@"Searching Assets online" maskType:SVProgressHUDMaskTypeGradient];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString* punchListParam = @"False";
            if ([[DataManager sharedManager] getPunchListDetails]) {
                punchListParam = @"True";
            }
            
            NSURL *theURL;
            if ([[DataManager sharedManager] restEnv]) {
                if (isSearchOnSet) {
                    NSString* str = [NSString stringWithFormat:@"%@?action_type=SearchWithSet&set_id=%@&short_desc=1&parent=1&make=1&type=1&tag=1&instance_url=%@&access_token=%@&q=%@&iac=%@&plant_section=%@&system=%@&criticality=%@&source_documents=%@&punch_list=%@",PRODUCTION_REST_URL,[[[[DataManager sharedManager] getSelectedSetDetails] valueForKey:@"Id"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],iacValue,[[[DataManager sharedManager] getSelectedPlantSectionDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[DataManager sharedManager] getSelectedSystemDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[DataManager sharedManager] getSelectedCriticalityDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[DataManager sharedManager] getSelectedSourceDocsDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],punchListParam];
                    theURL =  [[NSURL alloc]initWithString:str];
                }
                else {
                    theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=search&instance_url=%@&access_token=%@&plant_section=%@&system=%@&criticality=%@&source_documents=%@&search=%@&iac=%@&punch_list=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[[[DataManager sharedManager] getSelectedPlantSectionDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[DataManager sharedManager] getSelectedSystemDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[DataManager sharedManager] getSelectedCriticalityDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[DataManager sharedManager] getSelectedSourceDocsDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],iacValue,punchListParam]];
                }
            }
            else {
                if (isSearchOnSet) {
                    NSString* str = [NSString stringWithFormat:@"%@?action_type=SearchWithSet&set_id=%@&short_desc=1&parent=1&make=1&type=1&tag=1&instance_url=%@&access_token=%@&q=%@&iac=%@&plant_section=%@&system=%@&criticality=%@&source_documents=%@&punch_list=%@",SANDOBOX_REST_URL,[[[[DataManager sharedManager] getSelectedSetDetails] valueForKey:@"Id"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],iacValue,[[[DataManager sharedManager] getSelectedPlantSectionDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[DataManager sharedManager] getSelectedSystemDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[DataManager sharedManager] getSelectedCriticalityDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[DataManager sharedManager] getSelectedSourceDocsDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],punchListParam];
                    theURL =  [[NSURL alloc]initWithString:str];
                }
                else {
                    theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=search&instance_url=%@&access_token=%@&plant_section=%@&system=%@&criticality=%@&source_documents=%@&search=%@&iac=%@&punch_list=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[[[DataManager sharedManager] getSelectedPlantSectionDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[DataManager sharedManager] getSelectedSystemDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[DataManager sharedManager] getSelectedCriticalityDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[DataManager sharedManager] getSelectedSourceDocsDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],iacValue,punchListParam]];
                }
            }
            NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
            [theRequest setValue:HEADER_REQUEST_VALUE forHTTPHeaderField:HEADER_REQUEST_KEY];
            NSData *returnData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];
            //NSString *listFile = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            NSError *error;
            
            NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
            tmpDict = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers error:&error];
            
            NSMutableArray* responseData = [tmpDict valueForKey:@"assets"];
            if (responseData) {
                
                doneCount = [NSString stringWithFormat:@"%ld",[[[tmpDict valueForKey:@"RecordCount"] valueForKey:@"Done"] longValue]];
                todoCount = [NSString stringWithFormat:@"%ld",[[[tmpDict valueForKey:@"RecordCount"] valueForKey:@"Todo"] longValue]];
                
                
                searchContentArr = responseData;
                
                if ([iacValue isEqualToString:@"False"]) {
                    [self filterAssetsToBeSyncedFromSearch];
                }
                
                if ([[DataManager sharedManager] getPunchListDetails]) {
                    [self filterAssetsToBeSyncedFromSearchForPunchList];
                }
                
                nameContentArr = [searchContentArr valueForKey:@"Name"];
                if (isSearchOnSet) {
                    descriptionContentArr = [searchContentArr valueForKey:@"SHORT_DESCRIPTION__c"];
                }
                else {
                     descriptionContentArr = [searchContentArr valueForKey:@"Short_description__c"];
                }
                
                //[self extractParentAndChildAsset:searchContentArr];
                //nameContentArr = [parentContentArr valueForKey:@"Name"];
                //descriptionContentArr = [parentContentArr valueForKey:@"Short_description__c"];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.searchTableView reloadData];
                [SVProgressHUD dismiss];
                
            });
        });
    }
    else{
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No Login Credentials" message:@"Please login to app to search online" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)searchOfflineWithText:(NSString* )text {
    
    [SVProgressHUD showWithStatus:@"Searching Assets offline" maskType:SVProgressHUDMaskTypeGradient];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray* searchArr;
        NSMutableArray* searchArr1;
        long count;
        
        searchArr = [[DataManager sharedManager] getAllAssetsForOfflineTextWithAuditCompleted:text];
        searchArr1 = [[DataManager sharedManager] getAllAssetsForOfflineTextWithAuditUncompleted:text];
        
        if ([iacValue isEqualToString:@"True"]) {
            searchContentArr = searchArr;
            count = [self getCountForOffline:searchArr1];
        }
        else {
            searchContentArr = searchArr1;
            count = [self getCountForOffline:searchArr];
        }
        
        //[self extractParentAndChildAsset:searchContentArr];
        //nameContentArr = [parentContentArr valueForKey:@"Name"];
        //descriptionContentArr = [parentContentArr valueForKey:@"Short_description__c"];
        
        if ([iacValue isEqualToString:@"True"]) {
            [self filterAssetsToBeSyncedFromSearch];
        }
        if ([[DataManager sharedManager] getPunchListDetails]) {
            [self filterAssetsToBeSyncedFromSearchForPunchList];
        }
        
        nameContentArr = [searchContentArr valueForKey:@"Name"];
        descriptionContentArr = [searchContentArr valueForKey:@"Short_description__c"];
        
        if ([iacValue isEqualToString:@"True"]) {
            doneCount = [NSString stringWithFormat:@"%ld",[nameContentArr count]];
            todoCount = [NSString stringWithFormat:@"%ld",count];
        }
        else {
            todoCount = [NSString stringWithFormat:@"%ld",[nameContentArr count]];
            doneCount = [NSString stringWithFormat:@"%ld",count];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchTableView reloadData];
            [SVProgressHUD dismiss];
            
        });
    });
}


-(void)searchOfflineInStandaloneWithText:(NSString* )text {
    
    [SVProgressHUD showWithStatus:@"Searching Assets offline" maskType:SVProgressHUDMaskTypeGradient];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray* searchArr;
        searchArr = [[DataManager sharedManager] getAllAssetsForOfflineTextinStandaloneMode:text];
        
        searchContentArr = searchArr;
        
        //[self extractParentAndChildAsset:searchContentArr];
        //nameContentArr = [parentContentArr valueForKey:@"Name"];
        //descriptionContentArr = [parentContentArr valueForKey:@"Short_description__c"];
        
        
        nameContentArr = [searchContentArr valueForKey:@"Name"];
        descriptionContentArr = [searchContentArr valueForKey:@"Short_description__c"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchTableView reloadData];
            [SVProgressHUD dismiss];
            
        });
    });
}


- (void) extractParentAndChildAsset:(NSMutableArray *) contentArr {
    
    for (int i = 0; i<[contentArr count]; i++) {
            if ([[[contentArr objectAtIndex:i] valueForKey:@"PARENT_ASSET__c"] isEqualToString:@""]) {
                [parentContentArr addObject:[contentArr objectAtIndex:i]];
            }
            else {
                [childContentArr addObject:[contentArr objectAtIndex:i]];
            }
    }
}

- (NSMutableArray *) extractAuditCompletedAssets:(NSMutableArray *) contentArr {
    
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    
    for (int i = 0; i<[contentArr count]; i++) {
        if (![[[contentArr objectAtIndex:i] valueForKey:@"AUDIT_COMPLETED__c"] boolValue]) {
            [arr addObject:[contentArr objectAtIndex:i]];
        }
    }
    return arr;
}

- (void) replaceOldKeysWithNewKeys:(NSMutableArray *)contentArr {
    for (int i = 0; i<[contentArr count]; i++) {
        
        NSMutableDictionary* dict = [contentArr objectAtIndex:i];
        if ([dict objectForKey: @"SHORT_DESCRIPTION__c"]) {
            [dict setObject: [dict objectForKey: @"SHORT_DESCRIPTION__c"] forKey: @"Short_description__c"];
            [dict removeObjectForKey: @"SHORT_DESCRIPTION__c"];
        }
        if ([dict objectForKey: @"TAG__c"]) {
            [dict setObject: [dict objectForKey: @"TAG__c"] forKey: @"Tag__c"];
            [dict removeObjectForKey: @"TAG__c"];
        }
        [scrollAssetContentArr addObject:dict];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (IBAction)segmentControlValueChanged:(id)sender {
    
    [self.assetSearchBar resignFirstResponder];
    searchContentArr = [[NSMutableArray alloc] init];
    descriptionContentArr = [[NSMutableArray alloc] init];
    nameContentArr = [[NSMutableArray alloc] init];
    
    if (![self.assetSearchBar.text isEqualToString:@""]) {
        if (segmentSelectedIndex) {
            iacValue = @"True";
        }
        else {
            iacValue = @"False";
        }
        
        if ([[DataManager sharedManager] isInternetConnectionAvailable]) {
            [self searchOnlineWithText:self.assetSearchBar.text];
            internetStatus = 1;
        }
        else {
            [self searchOfflineWithText:self.assetSearchBar.text];
            internetStatus = 0;
        }
    }
    else {
        [self.searchTableView reloadData];
    }
    
}

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
