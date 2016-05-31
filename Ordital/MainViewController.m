//
//  MainViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 20/09/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "MainViewController.h"
#import "SVProgressHUD.h"
#import "DownloadAssetViewController.h"
#import "AssetsListViewController.h"
#import "FindAssetViewController.h"
#import "Reachability.h"
#import "CoreText/CoreText.h"
#import "PDFRenderer.h"

#import <AWSS3/AWSS3.h>

@interface MainViewController ()

@property (nonatomic, strong) DBRestClient *restClient;

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSMutableArray *arrFileDownloadData;

-(int)getFileDownloadInfoIndexWithTaskIdentifier:(unsigned long)taskIdentifier;
-(void)initializeFileDownloadDataArray;

@end

@implementation MainViewController
@synthesize internetStatusImg;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    todayCount = @"";
    todoCount = @"";
    doneCount = @"";
    
    [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:0.95]];
    
    [[DataManager sharedManager] setLogsString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]];
    
    NSString* tmp =[[DataManager sharedManager] logsString];
    NSLog(@"%@",tmp);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startUploadingPendingAudits) name:StartUploadingAuditImages object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startExportingToDropBox) name:@"ExpotToDropbox" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadAssetCompleted) name:@"DownloadAssetCompleted" object:nil];

    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performSyncSegue:)];
    UITapGestureRecognizer *gestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performSyncSegue:)];
    UITapGestureRecognizer *gestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performSyncSegue:)];
    [self.syncLabel addGestureRecognizer:gestureRecognizer];
    self.syncLabel.userInteractionEnabled = YES;
    [self.syncTxtLabel addGestureRecognizer:gestureRecognizer1];
    self.syncTxtLabel.userInteractionEnabled = YES;
    [self.syncImage addGestureRecognizer:gestureRecognizer2];
    self.syncImage.userInteractionEnabled = YES;
    
    
    UITapGestureRecognizer *gestureRecognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performPendingImagesSegue:)];
    UITapGestureRecognizer *gestureRecognizer4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performPendingImagesSegue:)];
    UITapGestureRecognizer *gestureRecognizer5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performPendingImagesSegue:)];
    [self.uploadsTxtLbl addGestureRecognizer:gestureRecognizer3];
    self.uploadsTxtLbl.userInteractionEnabled = YES;
    [self.uploadsValLbl addGestureRecognizer:gestureRecognizer4];
    self.uploadsValLbl.userInteractionEnabled = YES;
    [self.uploadsImage addGestureRecognizer:gestureRecognizer5];
    self.uploadsImage.userInteractionEnabled = YES;
    
}


-(void)viewWillAppear:(BOOL)animated{
    
    self.navigationController.navigationBarHidden = true;

    downloadedSetContent = [[NSMutableArray alloc] init];
    noteContentArr = [[NSMutableArray alloc] init];
    
    if ([UIApplication sharedApplication].isNetworkActivityIndicatorVisible) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    
    if ([[DataManager sharedManager] isInternetConnectionAvailable]) {
        NSLog(@"Internet available");
        internetStatusImg.image = [UIImage imageNamed:@"connect-icon.png"];
    }
    else{
        NSLog(@"Internet not available");
        internetStatusImg.image = [UIImage imageNamed:@"disconnect-icon.png"];
    }
    
    if ([[DataManager sharedManager] isLoggedIn])
    {
        //self.signInButton.titleLabel.text = @"Sign Out";
        [self.signInButton setTitle: @"Sign Out" forState: UIControlStateNormal];
    }
    else {
        //self.signInButton.titleLabel.text = @"Sign In";
        [self.signInButton setTitle: @"Sign In" forState: UIControlStateNormal];
    }
    noteContentArr = [[DataManager sharedManager] getAllNoteType];
    assetDatacount = [[DataManager sharedManager] getAssetDataCount];
    
    
//    if (assetDatacount>0 || [noteContentArr count]>0) {
//        [self.syncUpdateButton setHidden:false]; // Uncomment to enable eync button - DIPEN SEKHSARIA
//        
//        [self.listButtonHeightConstraint setConstant:81.0];
//        [self.findButtonHeightConstraint setConstant:81.0];
//        [self.createButtonHeightConstraint setConstant:81.0];
//        
//   }
//    else{
//        [self.syncUpdateButton setHidden:true];
//        
//        [self.listButtonHeightConstraint setConstant:101.0];
//        [self.findButtonHeightConstraint setConstant:101.0];
//        [self.createButtonHeightConstraint setConstant:101.0];
//        
//    }
    
    
    NSLog(@"Pending Asset Count %d",assetDatacount);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
    
    if (![self checkIfConneectionValid]) {
        
        internetStatusImg.image = [UIImage imageNamed:@"disconnect-icon.png"];
        [self.syncUpdateButton setHidden:true];
        
    }
    
    [self customSetup];
    
    [self.uploadsValLbl setText:[NSString stringWithFormat:@"%ld",[[[DataManager sharedManager] getAllAuditData] count]]];
    [self downloadAssetCompleted];
    [self.syncLabel setText:[NSString stringWithFormat:@"%d",assetDatacount]];
    
    [self.uploadsValLbl sizeToFit];
    [self.downloadsValLbl sizeToFit];
    [self.syncLabel sizeToFit];
    
}

- (void) performSyncSegue:(id) sender {
    
    if (![self checkIfConneectionValid]) {
        [self syncButtonTapped:sender];
    }
    else {
        if (assetDatacount>0 || [noteContentArr count]>0) {
            [self syncButtonTapped:sender];
        }
    }
    
}


-(void) performPendingImagesSegue:(id) sender {
    [self performSegueWithIdentifier:@"showPendingImagesSegue" sender:nil];
}


- (void)customSetup
{
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if ( revealViewController )
    {
        [self.slideMenuButon addTarget:revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
        [self.view addGestureRecognizer:revealViewController.tapGestureRecognizer];
        [revealViewController setFrontViewShadowRadius:10.0];
        
    }
    
}

- (void) startExportingToDropBox {
    
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
    
    [self saveImagesInDBAccount];
    
}


- (void) downloadAssetCompleted {
    
    
//    if ([[DataManager sharedManager] getPunchListDetails]) {
//        [self.downloadsValLbl setText:[NSString stringWithFormat:@"%d",[[DataManager sharedManager] getDownloadDataCountForPunchList]]];
//    }
//    else {
        [self.downloadsValLbl setText:[NSString stringWithFormat:@"%d",[[DataManager sharedManager] getDownloadDataCount]]];
    //}
    [self.downloadsValLbl sizeToFit];
    
}


- (void)saveImagesInDBAccount {
    
   // [SVProgressHUD showProgress:0.0 status:@"Exporting Images to your Dropbox account." maskType:SVProgressHUDMaskTypeGradient];
    currentSavingIndex = 0;
    [self startSavingToAlbum];
    
}

-(void)startSavingToAlbum{
    
    
    
    tmpAuditArr = [[NSMutableArray alloc] init];
    
    tmpAuditArr = [[DataManager sharedManager] getAllAuditData];
    
    if (tmpAuditArr.count==0 ) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"No Image present to export"];
        [self startUploadingPDF];
        return;
    }
    
        NSDictionary* currentAudit = [tmpAuditArr objectAtIndex:currentSavingIndex];
        
        // Write a file to the local documents directory
        /*NSString *text = @"Hello world.";
        NSString *filename = @"working-draft.txt";
        NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *localPath = [localDir stringByAppendingPathComponent:filename];
        [text writeToFile:localPath atomically:YES encoding:NSUTF8StringEncoding error:nil];*/
        
        NSString* filename = [[[currentAudit valueForKey:@"imgURL"] componentsSeparatedByString:@"/"] lastObject];
    
    NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *path = [localDir stringByAppendingPathComponent:filename];
        
        // Upload file to Dropbox
        NSString *destDir = @"/ORDITAL/";
        [self.restClient uploadFile:filename toPath:destDir withParentRev:nil fromPath:path];
    
    
}


- (void) startUploadingCSV {
    
    NSMutableArray* tmpArr = [[NSMutableArray alloc] init];
    tmpArr = [[DataManager sharedManager] getAllAuditData];
    
    NSMutableString *csv = [NSMutableString stringWithString:@"Asset Name,Short Description,Tag,Parent,Condition\n"];
    
    for (int i = 0; i<tmpArr.count; i++) {
        
        AuditData* audit = [tmpArr objectAtIndex:i];
        AssetData* asset = [[DataManager sharedManager] getAssetDataForAssetId:audit.assetId];
        
        NSString *string=asset.assetName;
        string=[string stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
        [csv appendFormat:@"\"%@\"",string];
        
        string=asset.description;
        string=[string stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
        [csv appendFormat:@",\"%@\"",string];
        
        string=asset.tag;
        string=[string stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
        [csv appendFormat:@",\"%@\"",string];
        
        string=asset.parent;
        string=[string stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
        [csv appendFormat:@",\"%@\"",string];
        
        string=asset.condition;
        string=[string stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
        [csv appendFormat:@",\"%@\"",string];
        
        
        [csv appendFormat:@",\"%@\"",string];
        [csv appendFormat:@"\n"];
    }
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectoryPath  stringByAppendingPathComponent:@"ORDITAL.csv"];
    
    NSData* settingsData;
    settingsData = [csv dataUsingEncoding: NSASCIIStringEncoding];
    
    if ([settingsData writeToFile:filePath atomically:YES])
        NSLog(@"writeok");
    
    NSString *yourFileName = @"ORDITAL.csv";
     NSString *destDir = @"/ORDITAL/";
    self.restClient.delegate = nil;
    [self.restClient uploadFile:yourFileName toPath:destDir withParentRev:nil fromPath:filePath];
    
    
}

- (void) startUploadingPDF {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectoryPath  stringByAppendingPathComponent:@"ORDITAL.pdf"];
    
    NSString *yourFileName = @"ORDITAL.pdf";
    NSString *destDir = @"/ORDITAL/";
    self.restClient.delegate = nil;
    
    //[self CreaPDFconPath:filePath];
    [PDFRenderer drawPDF:filePath];
    [self.restClient uploadFile:yourFileName toPath:destDir withParentRev:nil fromPath:filePath];
    
}


- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
    
    currentSavingIndex++;
    
    if (currentSavingIndex>=tmpAuditArr.count) {
       
        currentSavingIndex=0;
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"Images exported successfully"];
        [self startUploadingPDF];
        return; //notify the user it's done.
        
    }
    
       // [self increaseProgressCompleted];
        [self startSavingToAlbum];
    
    
}

- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress
           forFile:(NSString*)destPath from:(NSString*)srcPath {
    
    NSLog(@"%0.2f",progress);
    //[SVProgressHUD showProgress:((float)(currentSavingIndex)/(float)tmpAuditArr.count + progress/(float)tmpAuditArr.count) status:[NSString stringWithFormat:@"Exporting Images to your Dropbox account."] maskType:SVProgressHUDMaskTypeGradient];
    
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File upload failed with error: %@", error);
    
    if (currentSavingIndex>=tmpAuditArr.count) {
        
        currentSavingIndex=0;
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"Images exported successfully"];
        [self startUploadingPDF];
        return; //notify the user it's done.
        
    }
    
    currentSavingIndex ++;
    [self startSavingToAlbum];
}

- (void)increaseProgressCompleted {
    [SVProgressHUD showProgress:((float)(currentSavingIndex)/(float)tmpAuditArr.count) status:[NSString stringWithFormat:@"Exporting Images to your Dropbox account."] maskType:SVProgressHUDMaskTypeGradient];
}



//-(void) startUploadingPendingAudits {
//    
//    if (![[DataManager sharedManager] isAuditUploadInProgress]) {
//        
//        NSMutableArray* auditArr = [[DataManager sharedManager] getPendingAuditData];
//        if ([auditArr count]>0 && [[DataManager sharedManager] getSyncRecordsDetails]) {
//            
//            if ([[DataManager sharedManager] isInternetConnectionAvailable] && [[DataManager sharedManager] isLoggedIn]) {
//                
//                NSInteger auditCount = [auditArr count];
//                
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    
//                    //[self uploadAuditImageToServer];
//                    
//                    [[DataManager sharedManager] setIsAuditUploadInProgress:YES];
//                    
//                    BOOL isUploadedSuccess = true;
//                    BOOL sessionExpired = false;
//                    
//                    
//                    for (int i = 0; i<auditCount; i++) {
//                        AuditData* audit = [[AuditData alloc] init];
//                        audit = [auditArr objectAtIndex:i];
//                        
//                        
//                        [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nUploading %d of %ld Images\n%@ Image upload started at %@",(i+1),(long)auditCount,[[audit.imgURL componentsSeparatedByString:@"/"] lastObject],[NSDate date]]]];
//                        
//                        NSString *post = [self getJsonStringForSingleSyncUpdatesWithAudit:audit];
//                        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
//                        
//                        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
//                        
//                        NSURL *theURL;
//                        if ([[DataManager sharedManager] restEnv]) {
//                            theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=syncImages&instance_url=%@&access_token=%@&bucket=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[[DataManager sharedManager] getBucket]]];
//                        }
//                        else {
//                            theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=syncImages&instance_url=%@&access_token=%@&bucket=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[[DataManager sharedManager] getBucket]]];
//                        }
//                        
//                        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//                        [request setURL:theURL];
//                        [request setHTTPMethod:@"POST"];
//                        [request setTimeoutInterval:300.0];
//                        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//                        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//                        [request setValue:HEADER_REQUEST_VALUE forHTTPHeaderField:HEADER_REQUEST_KEY];
//                        [request setHTTPBody:postData];
//                        
//                        NSError *error = nil;
//                        NSHTTPURLResponse *responseCode = nil;
//                        
//                        NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
//                        
//                        NSString* responseDataConv = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//                        
//                        NSLog(@"%@",responseDataConv);
//                        //NSString* responseStatus = [responseDataConv valueForKey:@"status"];
//                        if (!([responseDataConv rangeOfString:@"\"status\":true"].location == NSNotFound)) {
//                            
//                            [self performSelectorOnMainThread:@selector(auditProgressCompleted:) withObject:audit.auditId waitUntilDone:YES];
//                            
//                            [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\n%@ Image upload success at %@",[[audit.imgURL componentsSeparatedByString:@"/"] lastObject],[NSDate date]]]];
//                            
//                        }
//                        else {
//                            if (!([responseDataConv rangeOfString:@"Session expired or invalid"].location == NSNotFound)) {
//                                sessionExpired = true;
//                            }
//                            isUploadedSuccess = false;
//                            
//                            [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\n%@ Image upload failed at %@",[[audit.imgURL componentsSeparatedByString:@"/"] lastObject],[NSDate date]]]];
//                            
//                            
//                            if (sessionExpired) {
//                                break;
//                            }
//                            
//                            continue;
//                            
//                        }
//                    }
//                    [[DataManager sharedManager] setIsAuditUploadInProgress:NO];
//                    
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        
//                    });
//                });
//            }
//        }
//
//        
//    }
//}

- (void)auditProgressCompleted:(NSString *)auditId {
    
    [[DataManager sharedManager] deleteAllAuditImagesWithAuditId:auditId];
    
    [[DataManager sharedManager] deleteAuditWithId:auditId];
}

-(NSString*)getJsonStringForSingleSyncUpdatesWithAudit:(AuditData*) audit{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self prepareDictonaryForSingleSyncUpdatesWithAsset:audit] options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(NSDictionary *)prepareDictonaryForSingleSyncUpdatesWithAsset:(AuditData *)audit {
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:audit.auditId forKey:@"name"];
    
    UIImage* currImg = [[DataManager sharedManager] loadAuditImagewithName:[[audit.imgURL componentsSeparatedByString:@"/"] lastObject]];
    if (currImg) {
        [dict setObject:[[DataManager sharedManager] convertImageToString:currImg] forKey:@"image"];
    }
    else {
        [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nImage not found in DB for Audit id  %@",audit.auditId]]];
    }
    return dict;
}


-(BOOL) checkIfConneectionValid {
    
    if ([[[DataManager sharedManager] selectedConnectionSettings] isEqualToString:@"STANDALONE"]) {
        return false;
    }
    
    return true;
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)listAssetButtonTapped:(id)sender {
    
    assetListContentArr = [[NSMutableArray alloc] init];
    offlineTodoArr = [[NSMutableArray alloc] init];
    offlineTodayArr = [[NSMutableArray alloc] init];
    offlineDoneArr = [[NSMutableArray alloc] init];
    
    if ([self checkIfConneectionValid]) {
        
        if (!([[[[DataManager sharedManager] getSelectedSetDetails] valueForKey:@"Id"] isEqualToString:@""])) {
            
            if ([[DataManager sharedManager] isInternetConnectionAvailable]) {
                if ([[DataManager sharedManager] isLoggedIn]) {
                    [SVProgressHUD showWithStatus:@"Downloading Asset Data" maskType:SVProgressHUDMaskTypeGradient];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        NSString* punchListParam = @"False";
                        if ([[DataManager sharedManager] getPunchListDetails]) {
                            punchListParam = @"True";
                        }
                        
                        NSURL *theURL;
                        if ([[DataManager sharedManager] restEnv]) {
                            theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=getassets&instance_url=%@&access_token=%@&plant_section=%@&system=%@&criticality=%@&source_documents=%@&set_id=%@&short_desc=1&parent=1&tag=1&make=1&type=1&iac=%@&punch_list=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken], [[[DataManager sharedManager] getSelectedPlantSectionDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[DataManager sharedManager] getSelectedSystemDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ,[[[DataManager sharedManager] getSelectedCriticalityDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[DataManager sharedManager] getSelectedSourceDocsDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[[DataManager sharedManager] getSelectedSetDetails] valueForKey:@"Id"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"False",punchListParam]];
                        }
                        else {
                            theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=getassets&instance_url=%@&access_token=%@&plant_section=%@&system=%@&criticality=%@&source_documents=%@&set_id=%@&short_desc=1&parent=1&tag=1&make=1&type=1&iac=%@&punch_list=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken], [[[DataManager sharedManager] getSelectedPlantSectionDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[DataManager sharedManager] getSelectedSystemDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ,[[[DataManager sharedManager] getSelectedCriticalityDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[DataManager sharedManager] getSelectedSourceDocsDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[[DataManager sharedManager] getSelectedSetDetails] valueForKey:@"Id"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"False",punchListParam]];
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
                                
                                doneCount = [NSString stringWithFormat:@"%ld",[[[responseData valueForKey:@"RecordCount"] valueForKey:@"Done"] longValue]];
                                todayCount = [NSString stringWithFormat:@"%ld",[[[responseData valueForKey:@"RecordCount"] valueForKey:@"Today"] longValue]];
                                todoCount = [NSString stringWithFormat:@"%ld",[[[responseData valueForKey:@"RecordCount"] valueForKey:@"Todo"] longValue]];
                                
                                [responseData removeObjectForKey:@"token"];
                                [responseData removeObjectForKey:@"instance_url"];
                                [responseData removeObjectForKey:@"RecordCount"];
                                /*if ([[[DataManager sharedManager] getSelectedIACDetails] isEqualToString:@"True"]) {
                                 [self filterAssetsToBeSyncedFromSearch:responseData];
                                 }*/
                                
                                [self filterAssetsToBeSyncedFromSearch:responseData];
                                
                                if ([[DataManager sharedManager] getPunchListDetails]) {
                                   responseData = [self filterAssetsToBeSyncedFromSearchForPunchList:responseData];
                                }
                                
                                [assetListContentArr addObject:responseData];
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
                            [SVProgressHUD dismiss];
                            //[[self navigationController] popToRootViewControllerAnimated:YES];
                            if (!status) {
                                isinternetForAssetList = YES;
                                
                            }
                            else {
                                if (errMsg) {
                                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",errMsg]];
                                }
                                else{
                                    [SVProgressHUD showErrorWithStatus:@"Downloading Assets failed"];
                                }
                                status = nil;
                            }
                            
                            [self performSegueWithIdentifier:@"listAssetSegue" sender:nil];
                            
                        });
                    });
                }
                else{
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No Login Credentials Found" message:@"Please login to app after turning on internet settings to view this section" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
            else {
                [SVProgressHUD showWithStatus:@"Fetching Asset Data" maskType:SVProgressHUDMaskTypeGradient];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    
                    NSMutableDictionary* responseData = [[NSMutableDictionary alloc] init];
                    responseData = [[DataManager sharedManager] getAllDownloadedAssetsWithAuditUncompleted];
                    
                    offlineTodoArr = (NSMutableArray *)responseData;
                    offlineDoneArr = (NSMutableArray *)[[DataManager sharedManager] getAllDownloadedAssetsWithAuditCompleted];
                    offlineTodayArr = [[DataManager sharedManager] getAllTodayAssets];
                    [offlineTodayArr addObjectsFromArray:[[DataManager sharedManager] getOfflineTodayDetails]];
                    
                    NSMutableDictionary* countDict = [[NSMutableDictionary alloc] init];
                    countDict = [[DataManager sharedManager] getAssetCountDetails];
                    
                    todayCount = [countDict valueForKey:@"Today"];
                    todoCount = [countDict valueForKey:@"Todo"];
                    doneCount = [countDict valueForKey:@"Done"];
                    
                    if ([[DataManager sharedManager] getPunchListDetails]) {
                        responseData = (NSMutableDictionary *)[self filterAssetsToBeSyncedFromSearchForPunchListForOffline:(NSMutableArray *)responseData];
                        offlineDoneArr = [self filterAssetsToBeSyncedFromSearchForPunchListForOffline:(NSMutableArray *)offlineDoneArr];
                        offlineTodoArr = [self filterAssetsToBeSyncedFromSearchForPunchListForOffline:(NSMutableArray *)offlineTodoArr];
                        
                    }
                    
                    
                    [assetListContentArr addObject:responseData];
                    
                    
                    
                    //[[DataManager sharedManager] saveDownloadData:responseData];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                        //[[self navigationController] popToRootViewControllerAnimated:YES];
                        //if ([[assetListContentArr objectAtIndex:0] count]>0) {
                        isinternetForAssetList = NO;
                        [self performSegueWithIdentifier:@"listAssetSegue" sender:nil];
                        
                        //}
                    });
                });
            }
        }
        else {
            
            if ([[DataManager sharedManager] isInternetConnectionAvailable]) {
                isinternetForAssetList = YES;
            }
            else {
                isinternetForAssetList = NO;
            }
            
            [self performSegueWithIdentifier:@"listAssetSegue" sender:nil];
            
            /*UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No Location defined" message:@"Please select Location from Filters in Settings to view this section" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [alert show];*/
        }

        
    }
    else {
        
                isinternetForAssetList = NO;
                [self performSegueWithIdentifier:@"listAssetSegue" sender:nil];
    }
    
    
}

-(NSMutableDictionary *)filterAssetsToBeSyncedFromSearchForPunchList:(NSMutableDictionary*)arr {
    
    NSMutableDictionary* tmpArr = [[NSMutableDictionary alloc] init];
    int counter=0;
    for (int i = 0; i<[arr count]; i++) {
        if ([[[arr valueForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"PUNCH_LIST__c"] boolValue] ) {
            [tmpArr setObject:[arr valueForKey:[NSString stringWithFormat:@"%d",i] ] forKey:[NSString stringWithFormat:@"%d",counter++]];
        }
    }
    
    return tmpArr;
}

-(NSMutableArray *)filterAssetsToBeSyncedFromSearchForPunchListForOffline:(NSMutableArray*)arr {
    
    NSMutableArray* tmpArr = [[NSMutableArray alloc] init];
    for (int i = 0; i<[arr count]; i++) {
        if ([[[arr objectAtIndex:i] valueForKey:@"PUNCH_LIST__c"] boolValue] ) {
            [tmpArr addObject:[arr objectAtIndex:i]];
        }
    }
    
    return tmpArr;
}

-(NSMutableDictionary* )filterAssetsToBeSyncedFromSearch:(NSMutableDictionary *)arr {
    NSMutableArray* idArr = [[NSMutableArray alloc] init];
    long index = -1;
    for (int i = 0; i<[arr count]; i++) {
        [idArr addObject:[[arr valueForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"ASSETS_id"]];
    }
    NSMutableArray* assetIdToBeSyncedArr = [[[DataManager sharedManager] getAllAssetsToBeSynced]valueForKey:@"id"];
    for (int i = 0; i<[assetIdToBeSyncedArr count]; i++) {
        
        if ([idArr containsObject:[assetIdToBeSyncedArr objectAtIndex:i]] ) {
            [arr removeObjectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)[idArr indexOfObject:[assetIdToBeSyncedArr objectAtIndex:i]]]];
            index = [idArr indexOfObject:[assetIdToBeSyncedArr objectAtIndex:i]];
            [idArr removeObjectAtIndex:[idArr indexOfObject:[assetIdToBeSyncedArr objectAtIndex:i]]];
            
            for (long j = index; j<[arr count]; j++) {
                [arr setObject:[arr valueForKey:[NSString stringWithFormat:@"%ld",(j+1)]] forKey:[NSString stringWithFormat:@"%ld",j]];
                [arr removeObjectForKey:[NSString stringWithFormat:@"%ld",(j+1)]];
                
            }
            
        }
    }
    return arr;
}

/*-(NSMutableDictionary* )filterAssetsToBeSyncedFromSearch:(NSMutableDictionary *)arr {
    NSMutableArray* idArr = [[NSMutableArray alloc] init];
    int index = -1;
    for (int i = 0; i<[arr count]; i++) {
        [idArr addObject:[[arr valueForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"ASSETS_id"]];
    }
    NSMutableArray* assetIdToBeSyncedArr = [[[DataManager sharedManager] getAllAssetsToBeSynced]valueForKey:@"id"];
    for (int i = 0; i<[assetIdToBeSyncedArr count]; i++) {
        
        if ([idArr containsObject:[assetIdToBeSyncedArr objectAtIndex:i]] ) {
           [arr removeObjectForKey:[NSString stringWithFormat:@"%d",[idArr indexOfObject:[assetIdToBeSyncedArr objectAtIndex:i]]]];
            index = [idArr indexOfObject:[assetIdToBeSyncedArr objectAtIndex:i]];
            [idArr removeObjectAtIndex:[idArr indexOfObject:[assetIdToBeSyncedArr objectAtIndex:i]]];
           
            for (int j = index; j<[arr count]; j++) {
                [arr setObject:[arr valueForKey:[NSString stringWithFormat:@"%d",(j+1)]] forKey:[NSString stringWithFormat:@"%d",j]];
                [arr removeObjectForKey:[NSString stringWithFormat:@"%d",(j+1)]];
                
            }

        }
    }
        return arr;
}*/


- (IBAction)signInButtonTapped:(id)sender {
    if (![[DataManager sharedManager] isLoggedIn]) {
        [self performSegueWithIdentifier:@"SignInSegue" sender:nil];
    }
    else{
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Confirm Logout" message:@"Are you sure you want to sign out from your account" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        NSLog(@"YES");
        DataManager* dataManagerObj = [DataManager sharedManager];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [dataManagerObj deleteAuthToken];
        if (![dataManagerObj isLoggedIn]) {
            [self.signInButton setTitle: @"Sign In" forState: UIControlStateNormal];
        }
        [SVProgressHUD dismiss];
    }
}

-(void)uploadAuditImageToServer {
    
    /*NSMutableArray* imgUrlArr = [[DataManager sharedManager] getAllAuditImagePath];
    for (int i = 0; i<[imgUrlArr count]; i++) {
        NSString* imgPath = [imgUrlArr objectAtIndex:i];
        NSArray* imgPathArr = [imgPath componentsSeparatedByString:@"/"];
        NSString* imgName = [imgPathArr lastObject];
       // UIImage* img = [UIImage imageWithContentsOfFile:imgPath];
        //NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(img)];
        AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:@"AKIAJRADXF5AT6E2HFSQ" secretKey:@"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"];
        AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
        [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
        AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
        AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
        uploadRequest.bucket = @"YogeshTest";
        uploadRequest.key = imgName;
        uploadRequest.body = [NSURL fileURLWithPath:imgPath];
        long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:imgPath error:nil][NSFileSize] longLongValue];
        uploadRequest.contentLength = [NSNumber numberWithUnsignedLongLong:fileSize];
        
        [[transferManager upload:uploadRequest] continueWithBlock:^id(BFTask *task) {
            // Do something with the response
            NSLog(@"Success");
            return nil;
        }];
    }*/
    
    /*
    AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:MY_ACCESS_KEY_ID withSecretKey:MY_SECRET_KEY];
    NSMutableArray* imgUrlArr = [[DataManager sharedManager] getAllAuditImagePath];
    for (int i = 0; i<[imgUrlArr count]; i++) {
        NSString* imgPath = [imgUrlArr objectAtIndex:i];
        NSArray* imgPathArr = [imgPath componentsSeparatedByString:@"/"];
        NSString* imgName = [imgPathArr lastObject];
        UIImage* img = [UIImage imageWithContentsOfFile:imgPath];
        NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(img)];
        ASIS3ObjectRequest *request = [ASIS3ObjectRequest PUTRequestForData:imageData withBucket:@"YogeshTest" key:imgName];
        [request setShouldCompressRequestBody:YES];
        request.accessPolicy = ASIS3AccessPolicyPublicReadWrite;
        [request startSynchronous];
        
        
        if (![request error]) {
            //Here I should share a link for the put file, how do I get it? Is there any response from s3?
            NSString * linkString = [NSString stringWithFormat:@"http://YogeshTest.s3.amazonaws.com/%@", imgName];
            NSLog(@"link string %@",linkString);
        }
        else {
            NSLog(@"%@",[[request error] localizedDescription]);
        }
    }*/
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"listAssetSegue"])
    {
        // Get reference to the destination view controller
        AssetsListViewController *vc = [segue destinationViewController];
        
        
        // Pass any objects to the view controller here, like...
        [vc setSearchContentArr:assetListContentArr];
        [vc setInternetStatus:isinternetForAssetList];
        [vc setTodayCount:todayCount];
        [vc setTodoCount:todoCount];
        [vc setDoneCount:doneCount];
        
        [vc setOfflineDoneArr:offlineDoneArr];
        [vc setOfflineTodayArr:offlineTodayArr];
        [vc setOfflineTodoArr:offlineTodoArr];
        
    }
    
}
- (void)syncButtonTapped:(id)sender {
    if ([noteContentArr count]>0) {
        if ([[DataManager sharedManager] isInternetConnectionAvailable] && [[DataManager sharedManager] isLoggedIn]) {
            
           // [SVProgressHUD showWithStatus:@"Uploading Notes" maskType:SVProgressHUDMaskTypeGradient];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                //[self uploadAuditImageToServer];
                
                
                BOOL isUploadedSuccess = true;
                BOOL sessionExpired = false;
                
                    NSString *post = [[DataManager sharedManager] getJsonStringForSyncNotes];
                    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
                    
                    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
                    
                    NSURL *theURL;
                    if ([[DataManager sharedManager] restEnv]) {
                     theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=AddNote&instance_url=%@&access_token=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken]]];
                     }
                     else {
                    theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=AddNote&instance_url=%@&access_token=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken]]];
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
                        [[DataManager sharedManager] deleteAllNotes];
                    }
                    else {
                        if (!([responseDataConv rangeOfString:@"Session expired or invalid"].location == NSNotFound)) {
                            sessionExpired = true;
                        }
                        isUploadedSuccess = false;
                    }
                }
                else {
                    isUploadedSuccess = false;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
//                    else {
//                        if (isUploadedSuccess) {
//                            [self.syncUpdateButton setHidden:true];
//                        }
//                    }
                });
            });
            
            if (assetDatacount>0) {
                [self performSegueWithIdentifier:@"syncPushSegue" sender:nil];
            }
            
        }
        else{
            
            if ([[DataManager sharedManager] isInternetConnectionAvailable]) {
                
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No Login Credentials Found" message:@"Please login to app after turning on internet settings to view this section" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            else {
                
                [self performSegueWithIdentifier:@"syncPushSegue" sender:nil];
                
            }
            
        }
    }
    else {
        if (assetDatacount>0) {
            [self performSegueWithIdentifier:@"syncPushSegue" sender:nil];
        }
    }
    
    
}








#pragma mark - Background transfer services


-(void) startUploadingPendingAudits {
    
    if (![[DataManager sharedManager] isAuditUploadInProgress]) {
        
        [self initializeFileDownloadDataArray];
        
        if ([auditArr count]>0 && [[DataManager sharedManager] getSyncRecordsDetails]) {
            
            if ([[DataManager sharedManager] isInternetConnectionAvailable] && [[DataManager sharedManager] isLoggedIn]) {
                
                //[self startSingleUpload];
                [self startAWSUpload];
            
            }
        }
        
        
    }
}


//- (void) startAWSUpload {
//    
//    AuditData* audit = [[AuditData alloc] init];
//    audit = [auditArr objectAtIndex:uploadCounter];
//    
//    NSURL* fileUrl = [NSURL fileURLWithPath:audit.imgURL];
//    
//    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
//    
//    //upload the image
//    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
//    uploadRequest.body = fileUrl;
//    uploadRequest.bucket = [[DataManager sharedManager] getBucket];
//    uploadRequest.key = [[audit.imgURL componentsSeparatedByString:@"/"] lastObject];
//    uploadRequest.contentType = @"image/jpg";
//    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
//        if(task.error) {
//            NSLog(@"woot");
//            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:task.error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alert show];
//            
//        }
//        if (task.result) {
//            AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
//            // The file uploaded successfully.
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:task.result delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alert show];
//        }
//        return nil;
//    }];
//    
//}



- (void) startAWSUpload {
    
    [[DataManager sharedManager] setIsAuditUploadInProgress:YES];
    
    AuditData* audit = [[AuditData alloc] init];
    audit = [auditArr objectAtIndex:uploadCounter];
    
    NSString* urlStr = [[[DataManager sharedManager] auditImagePath] stringByAppendingPathComponent:[[audit.imgURL componentsSeparatedByString:@"/"] lastObject]];
    
    NSURL* fileUrl = [NSURL fileURLWithPath:urlStr];
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    //upload the image
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.body = fileUrl;
    uploadRequest.bucket = [[DataManager sharedManager] getBucket];
    uploadRequest.key = [NSString stringWithFormat:@"%@.jpg",audit.auditId];
    uploadRequest.contentType = @"image/jpeg";
    uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
        if(task.error) {
            NSLog(@"Upload Failed");
            [[DataManager sharedManager] setIsAuditUploadInProgress:NO];
            uploadCounter = 0;
        }
        if (task.result) {
            NSLog(@"%@ uploaded successfully",audit.auditId);
            AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
            // The file uploaded successfully.
            [[DataManager sharedManager] updateUploadStatusForAuditId:audit.auditId];
            uploadCounter++;
            
            if (uploadCounter < auditArr.count) {
                [self startAWSUpload];
            }
            else {
                [[DataManager sharedManager] setIsAuditUploadInProgress:NO];
            }
            
        }
        return nil;
    }];
    
}


- (void) startSingleUpload {
    
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.ordital.ordital"];
    sessionConfiguration.HTTPMaximumConnectionsPerHost = 5;
    
    
    self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                 delegate:self
                                            delegateQueue:nil];
    
    
    [[DataManager sharedManager] setIsAuditUploadInProgress:YES];
    
    
    //for (int i = 0; i<auditCount; i++) {
    
    
    // Get the FileDownloadInfo object being at the cellIndex position of the array.
    FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:uploadCounter];
    
    // The isDownloading property of the fdi object defines whether a downloading should be started
    // or be stopped.
    if (!fdi.isUploading) {
        // This is the case where a download task should be started.
        
        // Create a new task, but check whether it should be created using a URL or resume data.
        if (fdi.taskIdentifier == -1) {
            // If the taskIdentifier property of the fdi object has value -1, then create a new task
            // providing the appropriate URL as the download source.
            
            AuditData* audit = [[AuditData alloc] init];
            audit = [auditArr objectAtIndex:uploadCounter];
            
            
            [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nUploading %d of %ld Images\n%@ Image upload started at %@",(uploadCounter+1),[auditArr count],[[audit.imgURL componentsSeparatedByString:@"/"] lastObject],[NSDate date]]]];
            
            NSString *post = [self getJsonStringForSingleSyncUpdatesWithAudit:audit];
            NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
            
            NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
            
            
            NSURL *url = [NSURL URLWithString:fdi.uploadSource];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                               timeoutInterval:300.0];
            
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
    
}


#pragma mark - Private method implementation

-(void)initializeFileDownloadDataArray{
    
    self.arrFileDownloadData = [[NSMutableArray alloc] init];
    auditContentArr = [[NSMutableArray alloc] init];
     auditArr = [[NSMutableArray alloc] init];
    uploadCounter = 0;
    
    NSMutableArray* assetArr = [[DataManager sharedManager] getPendingAuditData];
    auditArr = [[DataManager sharedManager] getPendingAuditData];
    
    NSString*theURL;
    if ([[DataManager sharedManager] restEnv]) {
        theURL =  [NSString stringWithFormat:@"%@?action_type=syncImages&instance_url=%@&access_token=%@&bucket=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[[DataManager sharedManager] getBucket]];
    }
    else {
        theURL =  [NSString stringWithFormat:@"%@?action_type=syncImages&instance_url=%@&access_token=%@&bucket=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[[DataManager sharedManager] getBucket]];
    }
    
    for (int i = 0 ; i < assetArr.count; i++) {
        
        AuditData* asset = [[AuditData alloc] init];
        asset = [assetArr objectAtIndex:i];
        
        [auditContentArr addObject:asset];
        
        [self.arrFileDownloadData addObject:[[FileDownloadInfo alloc] initWithFileTitle:asset.auditId andFileURL:asset.imgURL andDownloadSource:theURL]];
        
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
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error != nil) {
        NSLog(@"Upload completed with error: %@", [error localizedDescription]);
        uploadCounter = 0;
        [[DataManager sharedManager] setIsAuditUploadInProgress:NO];
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
        
        
        [self performSelectorOnMainThread:@selector(auditProgressCompleted:) withObject:fdi.fileTitle waitUntilDone:YES];
        
        
        [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\n%@ Image upload success at %@",[[fdi.fileURL componentsSeparatedByString:@"/"] lastObject],[NSDate date]]]];
        
        
        if (uploadCounter == auditContentArr.count) {
            
            [self performSelectorOnMainThread:@selector(handleAllUploadCommpleted) withObject:nil waitUntilDone:YES];
            
        }
        else {
            [self performSelectorOnMainThread:@selector(startSingleUpload) withObject:nil waitUntilDone:YES];
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
                    localNotification.alertBody = @"All files have been uploaded!";
                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                    uploadCounter = 0;
                    [[DataManager sharedManager] setIsAuditUploadInProgress:NO];
                }];
            }
        }
    }];
}

- (void) handleAllUploadCommpleted {
    
    uploadCounter = 0;
    [[DataManager sharedManager] setIsAuditUploadInProgress:NO];
    
}

- (void) handleIfFailed {
    
    uploadCounter = 0;
    [[DataManager sharedManager] setIsAuditUploadInProgress:NO];
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nImage upload failed at %@",[NSDate date]]]];
    
}


@end
