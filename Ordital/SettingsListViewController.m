//
//  SettingsListViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 30/10/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "SettingsListViewController.h"
#import "PreSettingsViewController.h"
#import "DataManager.h"
#import "SVProgressHUD.h"

@interface SettingsListViewController ()

@end

@implementation SettingsListViewController

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
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    imgArr = [[NSMutableArray alloc] init];
    
    sectionContentArr = [[NSMutableArray alloc] initWithObjects:@"DATA SETTING",@"ACTIONS",@"MORE INFORMATION", nil];

    contentArr1 = [[NSMutableArray alloc] initWithObjects:@"Initial Configuration",@"Filters",@"Asset Coding", nil];
    contentArr2 = [[NSMutableArray alloc] initWithObjects:@"Clear Cache",@"Network Settings",@"Login",@"Download Assets",@"Export Photos", nil];
    contentArr3 = [[NSMutableArray alloc] initWithObjects:@"Privacy Policy",@"Terms Of Use",@"Help",@"About Us",@"View Logs", nil];
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
}

-(void)viewWillAppear:(BOOL)animated {
    [self.settingListTableView reloadData];
    self.settingListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
    
    [self.settingListTableView reloadData];
    
    
}

-(void) disableUIforStandaloneConnection {
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(45, 13, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:17.0]];
    [label setTextColor:[UIColor whiteColor]];
    
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 25, 25)];
    if (section == 0) {
        imgView.image = [UIImage imageNamed:@"settings-icon.png"];
    }
    else if (section == 1) {
        imgView.image = [UIImage imageNamed:@"actions-icon.png"];
    }
    else {
        imgView.image = [UIImage imageNamed:@"more-info-icon.png"];
    }
    
    
    NSString *string =[sectionContentArr objectAtIndex:section];
    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    [view addSubview:imgView];
    [view setBackgroundColor:[self.view backgroundColor]]; //your background color...
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 45.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionContentArr count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [contentArr1 count];
    }
    else if (section == 1) {
        return [contentArr2 count];
    }
    else if (section == 2) {
        return [contentArr3 count];
    }
    return 0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"CustomCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    [cell setBackgroundColor:[self.view backgroundColor]];
    
    if (indexPath.section == 0) {
        cell.textLabel.text=[contentArr1 objectAtIndex:indexPath.row];
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 2) {
            if ([[DataManager sharedManager] isLoggedIn]) {
                cell.textLabel.text=@"Logout";
            }
            else {
                cell.textLabel.text=@"Login";
            }
        }
        else {
            cell.textLabel.text=[contentArr2 objectAtIndex:indexPath.row];
        }
    }
    if (indexPath.section == 2) {
        cell.textLabel.text=[contentArr3 objectAtIndex:indexPath.row];
    }
    [cell.textLabel setFont:[UIFont systemFontOfSize:16.0]];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    if (![self checkIfConneectionValid]) {
        
        if ((indexPath.section == 0 && indexPath.row==1) || (indexPath.section == 1 && indexPath.row==1) || (indexPath.section == 1 && indexPath.row==2) || (indexPath.section == 1 && indexPath.row==3)) {
            
            [cell.textLabel setTextColor:[UIColor lightGrayColor]];
            cell.accessoryType=UITableViewCellAccessoryNone;
            
        }
        else  {
            
            [cell.textLabel setTextColor:[UIColor whiteColor]];
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            
        }
        
    }
    else  {
        
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    UIImageView *bgColorView = [[UIImageView alloc] init];
    bgColorView.image = [UIImage imageNamed:@"selected-bar.png"];
    [cell setSelectedBackgroundView:bgColorView];
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0 && indexPath.row==0)
    {
        [self performSegueWithIdentifier:@"initialConfigSegue" sender:self];
    }
    if (indexPath.section==0 && indexPath.row==1 && [self checkIfConneectionValid])
    {
        [self performSegueWithIdentifier:@"filtersPushSegue" sender:self];
    }
    if (indexPath.section==0 && indexPath.row==2) {
        [self performSegueWithIdentifier:@"assetCodingPushSegue" sender:nil];
    }
    if (indexPath.section==1 && indexPath.row==0)
    {
        [self performSegueWithIdentifier:@"clearCachePushSegue" sender:self];
    }
    if (indexPath.section==1 && indexPath.row==1 && [self checkIfConneectionValid]) {
        [self performSegueWithIdentifier:@"syncRecordsPushSegue" sender:self];
    }
    if (indexPath.section==1 && indexPath.row==2 && [self checkIfConneectionValid]) {
        if ([[DataManager sharedManager] isLoggedIn]) {
            [[DataManager sharedManager] deleteAuthToken];
            [[DataManager sharedManager] setIsLoggedIn:false];
            [[DataManager sharedManager] deleteConditionsDetails];
            [[DataManager sharedManager] deleteOperatorTypeDetails];
            [[DataManager sharedManager] deleteOperatorClassDetails];
            [[DataManager sharedManager] deleteOperatorSubclassDetails];
            [[DataManager sharedManager] deleteCategoryDetails];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            [self performSegueWithIdentifier:@"signInSettingPushSegue" sender:self];
        }
    }
    if (indexPath.section==1 && indexPath.row==3 && [self checkIfConneectionValid]) {
        [self downloadAssetData];
    }
    if (indexPath.section==1 && indexPath.row==4 ) {
        //[self saveImagesInPhotoLibrary];
        [self.revealViewController revealToggleAnimated:YES];
        [self didPressLink];
        
    }
    if (indexPath.section==2 && indexPath.row==0)
    {
        [self performSegueWithIdentifier:@"privacyPolicyPushSegue" sender:self];
    }
    if (indexPath.section==2 && indexPath.row==1)
    {
        [self performSegueWithIdentifier:@"termsOfUsePushSegue" sender:self];
    }
    if (indexPath.section==2 && indexPath.row==2)
    {
        [self performSegueWithIdentifier:@"helpPushSegue" sender:self];
    }
    if (indexPath.section==2 && indexPath.row==3)
    {
        [self performSegueWithIdentifier:@"aboutUsPushSegue" sender:self];
    }
    if (indexPath.section==2 && indexPath.row==4)
    {
        [self performSegueWithIdentifier:@"viewLogsPushSegue" sender:self];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

- (void)didPressLink {
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ExpotToDropbox" object:nil];
    }
}

-(BOOL) checkIfConneectionValid {
    
    if ([[[DataManager sharedManager] selectedConnectionSettings] isEqualToString:@"STANDALONE"]) {
        return false;
    }
    
    return true;
    
}

-(void)downloadAssetData {
    
    err = 0;
    
    [SVProgressHUD showWithStatus:@"Downloading Assets" maskType:SVProgressHUDMaskTypeGradient];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (![[[[DataManager sharedManager] getSelectedSetDetails] valueForKey:@"Id"] isEqualToString:@""]) {
            if ([[DataManager sharedManager] isInternetConnectionAvailable] && [[DataManager sharedManager] isLoggedIn]) {
                
                [[DataManager sharedManager] deleteAllDownloadsData];
                
                NSString* punchListParam = @"False";
                if ([[DataManager sharedManager] getPunchListDetails]) {
                    punchListParam = @"True";
                }
                
                NSURL *theURL;
                if ([[DataManager sharedManager] restEnv]) {
                    theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=getassets&instance_url=%@&access_token=%@&set_id=%@&short_desc=1&parent=1&tag=1&make=1&type=1&punch_list=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken] ,[[[[DataManager sharedManager] getSelectedSetDetails] valueForKey:@"Id"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],punchListParam]];
                }
                else {
                    theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=getassets&instance_url=%@&access_token=%@&set_id=%@&short_desc=1&parent=1&tag=1&make=1&type=1&punch_list=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken] ,[[[[DataManager sharedManager] getSelectedSetDetails] valueForKey:@"Id"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],punchListParam]];
                }
                NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                [theRequest setValue:HEADER_REQUEST_VALUE forHTTPHeaderField:HEADER_REQUEST_KEY];
                NSData *returnData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];
                //NSString *listFile = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                NSError *error;
                if (returnData) {
                    NSMutableDictionary* responseData = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers error:&error];
                    if (responseData.count>0) {
                        
                        
                        [[DataManager sharedManager] saveAssetCountWithToday:[NSString stringWithFormat:@"%ld",[[[responseData valueForKey:@"RecordCount"] valueForKey:@"Today"] longValue]] andTODO:[NSString stringWithFormat:@"%ld",[[[responseData valueForKey:@"RecordCount"] valueForKey:@"Todo"] longValue]] andDone:[NSString stringWithFormat:@"%ld",[[[responseData valueForKey:@"RecordCount"] valueForKey:@"Done"] longValue]]];
                        
                        [responseData removeObjectForKey:@"token"];
                        [responseData removeObjectForKey:@"instance_url"];
                        [responseData removeObjectForKey:@"RecordCount"];
                        [[DataManager sharedManager] saveDownloadData:responseData];
                    }
                    else {
                        err = 1;
                    }
                }
                else {
                    err = 1;
                }
            }
            else{
                err = 1;
            }
        }
        else {
            err = 2;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (err == 1) {
                [SVProgressHUD dismiss];
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Unable To Download Assets" message:@"Please login to app after turning on internet settings to download assets" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            else if (err == 2) {
                [SVProgressHUD dismiss];
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Unable To Download Assets" message:@"Please select location from filters to download assets." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            else{
                //[SVProgressHUD dismiss];
                //[SVProgressHUD showSuccessWithStatus:@"Assets Saved"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadAssetCompleted" object:nil];
                
                [self downloadTodayAssetData];
                
            }
            //[self.navigationController popViewControllerAnimated:YES];
            
            
        });
        
    });
    
}


-(void) downloadTodayAssetData {
    
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
                    [SVProgressHUD dismiss];
                    //[[self navigationController] popToRootViewControllerAnimated:YES];
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    /*if ([[segue identifier] isEqualToString:@"initial"])
    {
        // Get reference to the destination view controller
        InitialConfiguration *vc;
        vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        //[vc setMyObjectHere:object];
    }
    if ([[segue identifier] isEqualToString:@"filter"])
    {
        // Get reference to the destination view controller
        FilterScreen *fc;
        fc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        //[vc setMyObjectHere:object];
    }
    if ([[segue identifier] isEqualToString:@"clearCache"])
    {
        // Get reference to the destination view controller
        ClearCacheScreen *clc;
        clc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        //[vc setMyObjectHere:object];
    }
    if ([[segue identifier] isEqualToString:@"version"])
    {
        // Get reference to the destination view controller
        VersionInformationScreen *vic;
        vic = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        //[vc setMyObjectHere:object];
    }
    if ([[segue identifier] isEqualToString:@"about"])
    {
        // Get reference to the destination view controller
        AboutUsScreen *ac;
        ac = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        //[vc setMyObjectHere:object];
    }
    if ([[segue identifier] isEqualToString:@"help"])
    {
        // Get reference to the destination view controller
        HelpScreen *helpObj;
        helpObj = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        //[vc setMyObjectHere:object];
    }*/
    
}


- (void)saveImagesInPhotoLibrary {
    
    [SVProgressHUD showProgress:0.0 status:@"Saving Images in photo library." maskType:SVProgressHUDMaskTypeGradient];
    [self performSelectorInBackground:@selector(startSavingToAlbum) withObject:nil];
    
}

-(void)startSavingToAlbum{
    
    currentSavingIndex = 0;
    
    NSMutableArray* tmpAuditArr = [[NSMutableArray alloc] init];
    
    tmpAuditArr = [[DataManager sharedManager] getAllAuditData];
    for (int i = 0; i<[tmpAuditArr count]; i++) {
        NSDictionary* currentAudit = [tmpAuditArr objectAtIndex:i];
        [imgArr addObject:[[DataManager sharedManager] loadAuditImagewithPath:[currentAudit valueForKey:@"imgURL"]]];
    }
    
    if (imgArr.count>0) {
        UIImage* img = imgArr[currentSavingIndex];//get your image
        UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    else {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"No Image present to save"];
    }
    
    
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{ //can also handle error message as well
    currentSavingIndex ++;
    
    [self performSelectorOnMainThread:@selector(increaseProgressCompleted:)  withObject:nil waitUntilDone:YES];
    
    if (currentSavingIndex >= imgArr.count) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"Images saved successfully"];
        return; //notify the user it's done.
    }
    else
    {
        UIImage* img = imgArr[currentSavingIndex];
        UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)increaseProgressCompleted:(NSMutableDictionary*) dict {
    [SVProgressHUD showProgress:((float)(currentSavingIndex)/(float)imgArr.count) status:[NSString stringWithFormat:@"Saving Images in photo library."] maskType:SVProgressHUDMaskTypeGradient];
}


@end
