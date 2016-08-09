//
//  EditAssetViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria  on 9/27/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "EditAssetViewController.h"
#import "CreateAssetViewController.h"
#import "AssetData.h"
#import "DataManager.h"
#import "SVProgressHUD.h"

@interface EditAssetViewController ()

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSMutableArray *arrFileDownloadData;

-(int)getFileDownloadInfoIndexWithTaskIdentifier:(unsigned long)taskIdentifier;
-(void)initializeFileDownloadDataArray;

@end

@implementation EditAssetViewController

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
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
    
    [self.syncCountLbl setText:[NSString stringWithFormat:@"%ld",(unsigned long)[nameContentArr count]]];
    self.assetTblView.tableFooterView = [UIView new];
    
    self.responsesData = [[NSMutableDictionary alloc] init];
    
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = true;
    
    nameContentArr = [[NSMutableArray alloc] init];
    descriptionContentArr = [[NSMutableArray alloc] init];
    assetContentArr = [[NSMutableArray alloc] init];
    
    assetContentArr = [[DataManager sharedManager] getAllAssetsToBeSynced];
    for (int i = 0; i<[assetContentArr count]; i++) {
        [nameContentArr addObject:[[assetContentArr objectAtIndex:i] valueForKey:@"name"]];
        [descriptionContentArr addObject:[[assetContentArr objectAtIndex:i] valueForKey:@"description"]];
    }
    
    [self initializeFileDownloadDataArray];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.ordital.ordital1"];
    sessionConfiguration.HTTPMaximumConnectionsPerHost = 5;
    
    
    self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                 delegate:self
                                            delegateQueue:nil];
    
    
    [self.assetTblView reloadData];
}


-(void)viewWillDisappear:(BOOL)animated {
    
    [self.session invalidateAndCancel];
    self.session = nil;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [nameContentArr count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"EditAssetFieldCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
    
    // Configure the cell...
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.text = [nameContentArr objectAtIndex:indexPath.row];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
    cell.detailTextLabel.text = [descriptionContentArr objectAtIndex:indexPath.row];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    CreateAssetViewController* controller = (CreateAssetViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"createassetcontroller"];
    
    AssetData* asset = [[AssetData alloc] init];
    
    asset.description = [descriptionContentArr objectAtIndex:indexPath.row];
        asset.assetName = [nameContentArr objectAtIndex:indexPath.row];
        asset.assetId = [[assetContentArr objectAtIndex:indexPath.row] valueForKey:@"id"];
    asset.tag = [[assetContentArr objectAtIndex:indexPath.row] valueForKey:@"tag"];
    asset.plantId = [[assetContentArr objectAtIndex:indexPath.row] valueForKey:@"plantId"];
    asset.plantName = [[assetContentArr objectAtIndex:indexPath.row] valueForKey:@"plantName"];
    asset.parent = [[assetContentArr objectAtIndex:indexPath.row] valueForKey:@"parent"];
    asset.isNewAsset = [[[assetContentArr objectAtIndex:indexPath.row] valueForKey:@"isNewAsset"] boolValue];
    asset.type = [[assetContentArr objectAtIndex:indexPath.row] valueForKey:@"type"];
    asset.condition = [[assetContentArr objectAtIndex:indexPath.row] valueForKey:@"condition"];
    asset.operatorType = [[assetContentArr objectAtIndex:indexPath.row] valueForKey:@"operatorType"];
    asset.operatorClass = [[assetContentArr objectAtIndex:indexPath.row] valueForKey:@"Class__name"];
    asset.operatorClassId = [[assetContentArr objectAtIndex:indexPath.row] valueForKey:@"Class__id"];
    asset.operatorSubclass = [[assetContentArr objectAtIndex:indexPath.row] valueForKey:@"SubClass__name"];
    asset.operatorSubclassId = [[assetContentArr objectAtIndex:indexPath.row] valueForKey:@"SubClass__id"];
    asset.category = [[assetContentArr objectAtIndex:indexPath.row] valueForKey:@"Category__name"];
    asset.categoryId = [[assetContentArr objectAtIndex:indexPath.row] valueForKey:@"Category__id"];
    asset.parentId = [[assetContentArr objectAtIndex:indexPath.row] valueForKey:@"parentId"];
    asset.unableToLocate = [[[assetContentArr objectAtIndex:indexPath.row] valueForKey:@"UNABLE_TO_LOCATE__c"] boolValue];
    
    if ([asset.parentId isEqualToString:@"(null)"]) {
        asset.parentId = @"";
    }
    
    [controller setIsAssetToBeUpdated:true];
    [controller setIsAuditToBePreviewed:true];
    [controller setAssetToUpdate:asset];
    [controller setCurrentAssetViewType:1];
    [self.navigationController pushViewController:controller animated:YES];
    
    //[self.navigationController performSegueWithIdentifier:@"AssetControllerSegue" sender:nil];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"deleting row %ld",(long)indexPath.row);
        
        NSString* assetIdToDelete = [[assetContentArr objectAtIndex:indexPath.row] valueForKey:@"id"];
        [[DataManager sharedManager] deleteAllAuditImagesWithAssetId:assetIdToDelete];
        [[DataManager sharedManager] deleteAssetWithId:assetIdToDelete];
        [nameContentArr removeObjectAtIndex:indexPath.row];
        [descriptionContentArr removeObjectAtIndex:indexPath.row];
        [assetContentArr removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        if ([nameContentArr count]==0) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        
    } else {
        NSLog(@"Unhandled editing style! ");
    }
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



- (void)hudTapped:(NSNotification *)notification
{
    NSLog(@"They tapped the HUD");
    // Cancel logic goes here
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Cancel Upload" message:@"Are you sure you want to cancel uploading of assets" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
    
    
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1){
        isCancelled = 1;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SVProgressHUDDidReceiveTouchEventNotification object:nil];
        [SVProgressHUD dismiss];
        [SVProgressHUD showWithStatus:@"Cancelling Upload. Please wait while current connection is being aborted." maskType:SVProgressHUDMaskTypeGradient];
        
        for (int i = 0; i<assetContentArr.count; i++) {
            FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:i];
            if (fdi.isUploading) {
                fdi.isUploading = NO;
                fdi.taskIdentifier = -1;
                [fdi.uploadTask cancel];
            }
        }
        
        
        
    }
}

//- (IBAction)syncButtonTapped:(id)sender {
//    
//    //if ([[DataManager sharedManager] getSyncRecordsDetails]) {
//        if ([[DataManager sharedManager] isInternetConnectionAvailable] && [[DataManager sharedManager] isLoggedIn]) {
//            
//            NSMutableArray* assetArr = [[DataManager sharedManager] getAssetData];
//            NSInteger assetCount = [assetArr count];
//            
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudTapped:) name:SVProgressHUDDidReceiveTouchEventNotification object:nil];
//            
//            [SVProgressHUD showProgress:0.0 status:[NSString stringWithFormat:@"DATABASE SYNCHRONIZATION OF %ld ASSETS IN PROGRESS. SEE SETTINGS FOR PROGRESS OF IMAGE SYNCHRONIZATION",(long)assetCount] maskType:SVProgressHUDMaskTypeGradient];
//            
//            myQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//            
//            dispatch_async(myQueue, ^{
//                
//                //[self uploadAuditImageToServer];
//                
//                
//                BOOL isUploadedSuccess = true;
//                BOOL sessionExpired = false;
//                
//                
//                for (int i = 0; i<assetCount; i++) {
//                    
//                    if (isCancelled) {
//                        break;
//                    }
//                    AssetData* asset = [[AssetData alloc] init];
//                    asset = [assetArr objectAtIndex:i];
//                    NSString *post = [[DataManager sharedManager] getJsonStringForSyncUpdatesWithAsset:asset];
//                    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
//                    
//                    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
//                    
//                    NSURL *theURL;
//                    if ([[DataManager sharedManager] restEnv]) {
//                        theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=bulkdataupload&instance_url=%@&access_token=%@&identity=%@&bucket=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[[DataManager sharedManager] getIdentity],[[DataManager sharedManager] getBucket]]];
//                    }
//                    else {
//                        theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=bulkdataupload&instance_url=%@&access_token=%@&identity=%@&bucket=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[[DataManager sharedManager] getIdentity],[[DataManager sharedManager] getBucket]]];
//                    }
//                    
//                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//                    [request setURL:theURL];
//                    [request setHTTPMethod:@"POST"];
//                    [request setTimeoutInterval:600.0];
//                    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//                    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//                    [request setValue:HEADER_REQUEST_VALUE forHTTPHeaderField:HEADER_REQUEST_KEY];
//                    [request setHTTPBody:postData];
//                    
//                    NSError *error = nil;
//                    NSHTTPURLResponse *responseCode = nil;
//                    
//                    NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
//                    
//                    NSString* responseDataConv = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//                    
//                    NSLog(@"%@",responseDataConv);
//                    //NSString* responseStatus = [responseDataConv valueForKey:@"status"];
//                    if (!([responseDataConv rangeOfString:@"\"status\":true"].location == NSNotFound)) {
//                        
//                        // [[DataManager sharedManager] deleteAllAuditImagesWithAssetId:asset.assetId];
//                        
//                        [[DataManager sharedManager] deleteOnlyAssetWithId:asset.assetId];
//                        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
//                        [dict setObject:[NSNumber numberWithInt:i] forKey:@"current"];
//                        [dict setObject:[NSNumber numberWithInt:assetCount] forKey:@"total"];
//                        [self performSelectorOnMainThread:@selector(increaseProgressCompleted:) withObject:dict waitUntilDone:YES];
//                        
//                    }
//                    else {
//                        if (!([responseDataConv rangeOfString:@"Session expired or invalid"].location == NSNotFound)) {
//                            sessionExpired = true;
//                        }
//                        isUploadedSuccess = false;
//                        break;
//                    }
//                }
//                
//                
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [SVProgressHUD dismiss];
//                    if (isUploadedSuccess && !isCancelled) {
//                        //[self.syncUpdateButton setHidden:true];
//                        
//                        [SVProgressHUD showSuccessWithStatus:@"Uploaded Successfully"];
//                        
//                        [self refreshDownloadData];
//                    }
//                    else if (!isCancelled){
//                        if (sessionExpired) {
//                            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Session Expired" message:@"Please sign out and sign in again to synchronize data" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                            [alertView show];
//                        }
//                        else {
//                            [SVProgressHUD showErrorWithStatus:@"Upload Failed"];
//                        }
//                        
//                    }
//                    else {
//                        [SVProgressHUD showErrorWithStatus:@"Upload Cancelled"];
//                        nameContentArr = [[NSMutableArray alloc] init];
//                        descriptionContentArr = [[NSMutableArray alloc] init];
//                        assetContentArr = [[NSMutableArray alloc] init];
//                        assetContentArr = [[DataManager sharedManager] getAllAssetsToBeSynced];
//                        for (int i = 0; i<[assetContentArr count]; i++) {
//                            [nameContentArr addObject:[[assetContentArr objectAtIndex:i] valueForKey:@"name"]];
//                            [descriptionContentArr addObject:[[assetContentArr objectAtIndex:i] valueForKey:@"description"]];
//                        }
//                        if ([assetContentArr count]==0) {
//                            [self.navigationController popToRootViewControllerAnimated:YES];
//                        }
//                        [self.assetTblView reloadData];
//                        isCancelled = 0;
//                    }
//                });
//            });
//        }
//        else{
//            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No Login Credentials Found" message:@"Signing in after turning on internet settings will enable synchronization of data" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alert show];
//        }
//    /*}
//    else {
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Unable to Sync Assets" message:@"Please turn on Sync Records from Setting to enable this feature" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//    }*/
//    
//    
//    /*if ([[DataManager sharedManager] isInternetConnectionAvailable] && [[DataManager sharedManager] isLoggedIn]) {
//        
//        
//        [SVProgressHUD showWithStatus:@"Uploading Assets" maskType:SVProgressHUDMaskTypeGradient];
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            
//            //[self uploadAuditImageToServer];
//            
//            BOOL isUploadedSuccess;
//            BOOL sessionExpired;
//            NSString *post = [[DataManager sharedManager] getJsonStringForSyncUpdates];
//            NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
//            
//            NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
//            
//            NSURL *theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://socialcabel.com/webuters/sfauth/sfdc_upload.php?action_type=bulkdataupload&instance_url=%@&access_token=%@&plant_id=a0X90000005BkgNEAS",[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken]]];
//            
//            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//            [request setURL:theURL];
//            [request setHTTPMethod:@"POST"];
//            [request setTimeoutInterval:60.0];
//            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//            [request setHTTPBody:postData];
//            
//            NSError *error = nil;
//            NSHTTPURLResponse *responseCode = nil;
//            
//            NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
//            
//            NSString* responseDataConv = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//            
//            NSLog(@"%@",responseDataConv);
//            //NSString* responseStatus = [responseDataConv valueForKey:@"status"];
//            if (!([responseDataConv rangeOfString:@"\"status\":true"].location == NSNotFound)) {
//                isUploadedSuccess = true;
//                [[DataManager sharedManager] deleteAllAssetsAndAudits];
//            }
//            else {
//                if (!([responseDataConv rangeOfString:@"Session expired or invalid"].location == NSNotFound)) {
//                    sessionExpired = true;
//                }
//                isUploadedSuccess = false;
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [SVProgressHUD dismiss];
//                if (isUploadedSuccess) {
//                    //[self.syncUpdateButton setHidden:true];
//                    [SVProgressHUD showSuccessWithStatus:@"Uploaded Successfully"];
//                    [self.navigationController popToRootViewControllerAnimated:YES];
//                }
//                else{
//                    if (sessionExpired) {
//                        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Session Expired" message:@"Please sign out and sign in again to synchronize data" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                        [alertView show];
//                    }
//                    else {
//                        [SVProgressHUD showErrorWithStatus:@"Upload Failed"];
//                    }
//                    
//                }
//            });
//        });
//    }
//    else{
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No Login Credentials Found" message:@"Signing in after turning on internet settings will enable synchronization of data" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//    }*/
//}

-(void) refreshDownloadData {
    
    [[DataManager sharedManager] deleteAllDownloadsData];
    
    if ([[DataManager sharedManager] isInternetConnectionAvailable] && [[DataManager sharedManager] isLoggedIn]) {
        [SVProgressHUD showWithStatus:@"Refreshing Offline Data" maskType:SVProgressHUDMaskTypeGradient];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString* punchListParam = @"False";
            if ([[DataManager sharedManager] getPunchListDetails]) {
                punchListParam = @"True";
            }
            
            NSURL *theURL;
            if ([[DataManager sharedManager] restEnv]) {
             theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=getassets&instance_url=%@&access_token=%@&set_id=%@&short_desc=1&parent=1&tag=1&make=1&type=1&punch_list=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken], [[[[DataManager sharedManager] getSelectedSetDetails] valueForKey:@"Id"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],punchListParam]];
             }
             else {
            theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=getassets&instance_url=%@&access_token=%@&set_id=%@&short_desc=1&parent=1&tag=1&make=1&type=1&punch_list=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken], [[[[DataManager sharedManager] getSelectedSetDetails] valueForKey:@"Id"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],punchListParam]];
            }
            NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
            [theRequest setValue:HEADER_REQUEST_VALUE forHTTPHeaderField:HEADER_REQUEST_KEY];
            NSData *returnData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];
            //NSString *listFile = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            NSError *error;
            if (returnData) {
                NSMutableDictionary* responseData = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers error:&error];
                
                [[DataManager sharedManager] saveAssetCountWithToday:[NSString stringWithFormat:@"%ld",[[[responseData valueForKey:@"RecordCount"] valueForKey:@"Today"] longValue]] andTODO:[NSString stringWithFormat:@"%ld",[[[responseData valueForKey:@"RecordCount"] valueForKey:@"Todo"] longValue]] andDone:[NSString stringWithFormat:@"%ld",[[[responseData valueForKey:@"RecordCount"] valueForKey:@"Done"] longValue]]];
                
                [responseData removeObjectForKey:@"token"];
                [responseData removeObjectForKey:@"instance_url"];
                [responseData removeObjectForKey:@"RecordCount"];
                [[DataManager sharedManager] saveDownloadData:responseData];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                //[SVProgressHUD dismiss];
                //[[self navigationController] popToRootViewControllerAnimated:YES];
                [self refreshTodayAssetData];
            });
        });
    }
    else{
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connectivity" message:@"Please login to app after turning on internet settings to view this section" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}


-(void) refreshTodayAssetData {
    
    [[DataManager sharedManager] deleteTodayDetails];
    
    if ([[DataManager sharedManager] isInternetConnectionAvailable]) {
        if ([[DataManager sharedManager] isLoggedIn]) {
            //[SVProgressHUD showWithStatus:@"Downloading Asset Data" maskType:SVProgressHUDMaskTypeGradient];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSURL *theURL;
                if ([[DataManager sharedManager] restEnv]) {
                    theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=todayassets&instance_url=%@&access_token=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken]]];
                }
                else {
                    theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=todayassets&instance_url=%@&access_token=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken]]];
                }
                NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                [theRequest setValue:HEADER_REQUEST_VALUE forHTTPHeaderField:HEADER_REQUEST_KEY];
                NSData *returnData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];
                //NSString *listFile = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                NSError *error;
                if (returnData) {
                    NSMutableDictionary* responseData = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers error:&error];
                    
                    status = [responseData valueForKey:@"status"];
                    if (!error && !status) {
                        [responseData removeObjectForKey:@"token"];
                        [responseData removeObjectForKey:@"instance_url"];
                        
                        [[DataManager sharedManager] saveTodayAssets:[responseData valueForKey:@"assets"]];
                    }
                    else {
                        if (status) {
                            errMsg = [responseData valueForKey:@"msg"];
                        }
                    }
                    
                    
                    //[[DataManager sharedManager] saveDownloadData:responseData];
                }
                else {
                    status = @"";
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self refreshAssetCodingData];
                    
                    if (!status) {
                        
                    }
                    else {
                        if (errMsg) {
                            //[SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",errMsg]];
                        }
                        else{
                            [SVProgressHUD showErrorWithStatus:@"Downloading Assets failed"];
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
    
}

-(void) refreshAssetCodingData {
    
    conditionArr = [[NSMutableArray alloc] init];
    operatorClassArr = [[NSMutableArray alloc] init];
    operatorSubclassArr = [[NSMutableArray alloc] init];
    operatorTypeArr = [[NSMutableArray alloc] init];
    categoryArr = [[NSMutableArray alloc] init];
    
    if ([[DataManager sharedManager] isInternetConnectionAvailable] && [[DataManager sharedManager] isLoggedIn]) {
        
        //[SVProgressHUD showWithStatus:@"Downloading Conditions data" maskType:SVProgressHUDMaskTypeGradient];
        
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
                if (!status) {
                    if ([conditionArr count] > 0) {
                        [[DataManager sharedManager] deleteConditionsDetails];
                        [self addConditionsDataToDB];
                    }
                    
                    if ([operatorTypeArr count] > 0) {
                        [[DataManager sharedManager] deleteOperatorTypeDetails];
                        [self addOperatorTypeDataToDB];
                    }
                    
                    if ([operatorClassArr count] > 0) {
                        [[DataManager sharedManager] deleteOperatorClassDetails];
                        [self addOperatorClassDataToDB];
                    }
                    
                    if ([operatorSubclassArr count] > 0) {
                        [[DataManager sharedManager] deleteOperatorSubclassDetails];
                        [self addOperatorSubclassDataToDB];
                    }
                    
                    if ([categoryArr count] > 0) {
                        [[DataManager sharedManager] deleteCategoryDetails];
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
                
                [SVProgressHUD dismiss];
                [[self navigationController] popToRootViewControllerAnimated:YES];
                
            });
        });
    }
    else{
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No Login Credentials Found" message:@"Please login to app after turning on internet settings to view this section" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
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
        [[DataManager sharedManager] saveOperatorClassWithValue:[dict valueForKey:@"Name"] andDescription:[dict valueForKey:@"catgory"] andID:[dict valueForKey:@"id"] andClass:[dict valueForKey:@"class"] andDesignation:[dict valueForKey:@"designation"]];
        
    }
    
}

-(void) addOperatorSubclassDataToDB {
    
    for (int i = 0; i<operatorSubclassArr.count; i++) {
        
        NSDictionary* dict = [operatorSubclassArr objectAtIndex:i];
        [[DataManager sharedManager] saveOperatorSubclassWithValue:[dict valueForKey:@"Name"] andDescription:[dict valueForKey:@"class"] andId:[dict valueForKey:@"id"] andDesignation:[dict valueForKey:@"designation"]];
        
    }
    
}

-(void) addCategoryDataToDB {
    
    for (int i = 0; i<categoryArr.count; i++) {
        
        NSDictionary* dict = [categoryArr objectAtIndex:i];
        [[DataManager sharedManager] saveCategoryWithValue:[dict valueForKey:@"Name"] andId:[dict valueForKey:@"id"] andCategory:[dict valueForKey:@"catgory"] andDesignation:[dict valueForKey:@"designation"]];
        
    }
    
}

- (void)increaseProgressCompleted:(NSMutableDictionary*) dict {
    [SVProgressHUD showProgress:((float)([[dict valueForKey:@"current"] intValue]+1)/(float)[[dict valueForKey:@"total"] intValue]) status:[NSString stringWithFormat:@"DATABASE SYNCHRONIZATION OF %d ASSETS IN PROGRESS. SEE SETTINGS FOR PROGRESS OF IMAGE SYNCHRONIZATION",[[dict valueForKey:@"total"] intValue]] maskType:SVProgressHUDMaskTypeGradient];
}


- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - Background transfer services




- (IBAction)syncButtonTapped:(id)sender {
    
    self.responsesData = [[NSMutableDictionary alloc] init];
    
    if ([[DataManager sharedManager] isInternetConnectionAvailable] && [[DataManager sharedManager] isLoggedIn]) {
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudTapped:) name:SVProgressHUDDidReceiveTouchEventNotification object:nil];
        
        [SVProgressHUD showProgress:0.0 status:[NSString stringWithFormat:@"DATABASE SYNCHRONIZATION OF %ld ASSETS IN PROGRESS. SEE SETTINGS FOR PROGRESS OF IMAGE SYNCHRONIZATION",(long)[[[DataManager sharedManager] getAssetData] count]] maskType:SVProgressHUDMaskTypeGradient];
        
        [self performSelectorInBackground:@selector(startBulkUploadAPI) withObject:nil];
        
            
            
    }
    else{
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No Login Credentials Found" message:@"Signing in after turning on internet settings will enable synchronization of data" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}


- (void) startBulkUploadAPI {
    
    NSMutableArray* assetArr = [[DataManager sharedManager] getAssetData];
    NSInteger assetCount = [assetArr count];
    
    uploadCounter = 0;
    
    for (int i = 0; i<assetCount; i++) {
        
        
        // Get the FileDownloadInfo object being at the cellIndex position of the array.
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:i];
        
        // The isDownloading property of the fdi object defines whether a downloading should be started
        // or be stopped.
        if (!fdi.isUploading) {
            // This is the case where a download task should be started.
            
            // Create a new task, but check whether it should be created using a URL or resume data.
            if (fdi.taskIdentifier == -1) {
                // If the taskIdentifier property of the fdi object has value -1, then create a new task
                // providing the appropriate URL as the download source.
                
                AssetData* asset = [[AssetData alloc] init];
                asset = [assetArr objectAtIndex:i];
                NSString *post = [[DataManager sharedManager] getJsonStringForSyncUpdatesWithAsset:asset];
                NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
                
                NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
                
                
                NSURL *url = [NSURL URLWithString:fdi.uploadSource];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                   timeoutInterval:60.0];
                
                [request setHTTPMethod:@"POST"];
                [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
                [request addValue:postLength forHTTPHeaderField:@"Content-Length"];
                [request addValue:HEADER_REQUEST_VALUE forHTTPHeaderField:HEADER_REQUEST_KEY];
                [request setHTTPBody:postData];
                
                
                
                fdi.uploadTask = [self.session dataTaskWithRequest:request];
                // Keep the new task identifier.
                fdi.taskIdentifier = fdi.uploadTask.taskIdentifier;
                
                // Start the task.
                [fdi.uploadTask resume];
            }
            else{
                
            }
        }
        
        // Change the isDownloading property value.
        fdi.isUploading = !fdi.isUploading;
        
    }
    
}


#pragma mark - Private method implementation

-(void)initializeFileDownloadDataArray{
    
    self.arrFileDownloadData = [[NSMutableArray alloc] init];
    
    NSMutableArray* assetArr = [[DataManager sharedManager] getAssetData];
    
    NSString*theURL;
    if ([[DataManager sharedManager] restEnv]) {
        theURL =  [NSString stringWithFormat:@"%@?action_type=bulkdataupload&instance_url=%@&access_token=%@&identity=%@&bucket=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[[DataManager sharedManager] getIdentity],[[DataManager sharedManager] getBucket]];
    }
    else {
        theURL =  [NSString stringWithFormat:@"%@?action_type=bulkdataupload&instance_url=%@&access_token=%@&identity=%@&bucket=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[[DataManager sharedManager] getIdentity],[[DataManager sharedManager] getBucket]];
    }
    
    for (int i = 0 ; i < assetArr.count; i++) {
        
        AssetData* asset = [[AssetData alloc] init];
        asset = [assetArr objectAtIndex:i];
        
        [self.arrFileDownloadData addObject:[[FileDownloadInfo alloc] initWithFileTitle:asset.assetId andDownloadSource:theURL]];
        
    }
}


-(int)getFileDownloadInfoIndexWithTaskIdentifier:(unsigned long)taskIdentifier{
    int index = 0;
    for (int i=0; i<[self.arrFileDownloadData count]; i++) {
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:i];
        if (fdi.taskIdentifier == taskIdentifier) {
            index = i;
            break;
        }
    }
    
    return index;
}



#pragma mark - NSURLSession Delegate method implementation

-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    
    [self performSelectorOnMainThread:@selector(handleIfFailed) withObject:nil waitUntilDone:YES];
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSMutableData *responseData = self.responsesData[@(dataTask.taskIdentifier)];
    if (!responseData) {
        responseData = [NSMutableData dataWithData:data];
        self.responsesData[@(dataTask.taskIdentifier)] = responseData;
    } else {
        [responseData appendData:data];
    }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error != nil) {
        NSLog(@"Upload completed with error: %@", [error localizedDescription]);
        if ([[error localizedDescription] isEqualToString:@"cancelled"]) {
            
            [self performSelectorOnMainThread:@selector(handleIfCancelled) withObject:nil waitUntilDone:YES];
            
        }
    }
    else{
        NSLog(@"Upload finished successfully.");
        
        uploadCounter++;
        
        // Change the flag values of the respective FileDownloadInfo object.
        int index = [self getFileDownloadInfoIndexWithTaskIdentifier:task.taskIdentifier];
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:index];
        
        fdi.isUploading = NO;
        fdi.uploadComplete = YES;
        
        // Set the initial value to the taskIdentifier property of the fdi object,
        // so when the start button gets tapped again to start over the file download.
        fdi.taskIdentifier = -1;
        
        // In case there is any resume data stored in the fdi object, just make it nil.
        fdi.taskResumeData = nil;
        
        
        //[[DataManager sharedManager] deleteOnlyAssetWithId:fdi.fileTitle];
        
        [[DataManager sharedManager] updateUploadStatusForAssetId:fdi.fileTitle];
        
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[NSNumber numberWithInt:uploadCounter] forKey:@"current"];
        [dict setObject:[NSNumber numberWithLong:assetContentArr.count] forKey:@"total"];
        [self performSelectorOnMainThread:@selector(increaseProgressCompleted:) withObject:dict waitUntilDone:YES];
        
        
        NSMutableData *responseData = self.responsesData[@(task.taskIdentifier)];
        
        if (responseData) {
            // my response is JSON; I don't know what yours is, though this handles both
            
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
            if (response) {
                
                NSLog(@"response = %@", response);
                
                [[DataManager sharedManager] updateAssetIdForOldAssetId:fdi.fileTitle withNewAssetId:[response valueForKey:@"assetId"]];
                
                
            } else {
                NSLog(@"responseData = %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
            }
            
            [self.responsesData removeObjectForKey:@(task.taskIdentifier)];
        } else {
            NSLog(@"responseData is nil");
        }
        
        
        if (uploadCounter == assetContentArr.count) {
            
            [self performSelectorOnMainThread:@selector(handleAllUploadCommpleted) withObject:nil waitUntilDone:YES];
            
        }
    }

}


-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    if (totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown) {
        NSLog(@"Unknown transfer size");
    }
    else{
        // Locate the FileDownloadInfo object among all based on the taskIdentifier property of the task.
        int index = [self getFileDownloadInfoIndexWithTaskIdentifier:downloadTask.taskIdentifier];
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:index];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Calculate the progress.
            fdi.uploadProgress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
            
            
        }];
    }
}


-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    // Check if all download tasks have been finished.
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        
        if ([uploadTasks count] == 0) {
            if (appDelegate.backgroundTransferCompletionHandler != nil) {
                // Copy locally the completion handler.
                void(^completionHandler)() = appDelegate.backgroundTransferCompletionHandler;
                
                // Make nil the backgroundTransferCompletionHandler.
                appDelegate.backgroundTransferCompletionHandler = nil;
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // Call the completion handler to tell the system that there are no other background transfers.
                    completionHandler();
                    
                    // Show a local notification when all downloads are over.
                    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                    localNotification.alertBody = @"All files have been downloaded!";
                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                }];
            }
        }
    }];
}

- (void) handleAllUploadCommpleted {
    
    uploadCounter = 0;
    [SVProgressHUD dismiss];
    [SVProgressHUD showSuccessWithStatus:@"Uploaded Successfully"];
    [self refreshDownloadData];
    
}

- (void) handleIfFailed {

    [SVProgressHUD dismiss];
    
}

- (void) handleIfCancelled {
    
    [SVProgressHUD dismiss];
    
    nameContentArr = [[NSMutableArray alloc] init];
    descriptionContentArr = [[NSMutableArray alloc] init];
    assetContentArr = [[NSMutableArray alloc] init];
    assetContentArr = [[DataManager sharedManager] getAllAssetsToBeSynced];
    for (int i = 0; i<[assetContentArr count]; i++) {
        [nameContentArr addObject:[[assetContentArr objectAtIndex:i] valueForKey:@"name"]];
        [descriptionContentArr addObject:[[assetContentArr objectAtIndex:i] valueForKey:@"description"]];
    }
    if ([assetContentArr count]==0) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    [self.assetTblView reloadData];
    
}
@end
