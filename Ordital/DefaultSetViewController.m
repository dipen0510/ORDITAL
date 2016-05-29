//
//  DefaultSetViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 21/10/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "DefaultSetViewController.h"
#import "SVProgressHUD.h"
#import "DataManager.h"
#import "SetListViewController.h"

@interface DefaultSetViewController ()

@end

@implementation DefaultSetViewController


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
    
    self.assetSearchBar.delegate  =self;
    
    downloadedSetContent = [[NSMutableArray alloc] init];
    searchContentArr = [[NSMutableArray alloc] init];
    nameContentArr = [[NSMutableArray alloc] init];
    descriptionContentArr = [[NSMutableArray alloc] init];
    downloadedSetListContent = [[NSMutableArray alloc] init];
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    dict  = [[DataManager sharedManager] getAllDynamicLabelValues];
    NSString* listStr = @"List";
    
    if (dict.count > 0) {
        
        listStr = [dict valueForKey:@"LISTS"];
        
        if ([listStr isEqual:[NSNull null]]) {
                listStr = @"List";
        }
        
    }
    
    navigation = [[UIBarButtonItem alloc]
                  initWithTitle:[NSString stringWithFormat:@"%@ Locations",listStr]
                  style:UIBarButtonItemStyleBordered
                  target:self
                  action:@selector(listAllSet:)];
    
    
    self.navigationItem.rightBarButtonItem = navigation;
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
    
    [self.assetSearchBar setImage:[UIImage imageNamed:@"search-icon.png"]
                 forSearchBarIcon:UISearchBarIconSearch
                            state:UIControlStateNormal];
    [self.assetSearchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"search-text-field.png"] forState:UIControlStateNormal];
    
    self.assetSearchBar.searchTextPositionAdjustment = UIOffsetMake(10.0f, 0.0f);
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = true;
}

-(void) listAllSet:(id)sender {
    
    downloadedSetListContent = [[NSMutableArray alloc] init];
    
    if ([[DataManager sharedManager] isInternetConnectionAvailable] && [[DataManager sharedManager] isLoggedIn]) {
        
        if ([[[DataManager sharedManager] selectedPlantSettings] valueForKey:@"Id"] && ![[[[DataManager sharedManager] selectedPlantSettings] valueForKey:@"Id"] isEqualToString:@""]) {
            
            [SVProgressHUD showWithStatus:@"Downloading Lists Data" maskType:SVProgressHUDMaskTypeGradient];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSURL *theURL;
                if ([[DataManager sharedManager] restEnv]) {
                    theURL = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=getsets&instance_url=%@&access_token=%@&plant_id=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[[[DataManager sharedManager] selectedPlantSettings] valueForKey:@"Id"]]];
                }
                else  {
                    theURL = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=getsets&instance_url=%@&access_token=%@&plant_id=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[[[DataManager sharedManager] selectedPlantSettings] valueForKey:@"Id"]]];
                }
                
                NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                
                [theRequest setValue:HEADER_REQUEST_VALUE forHTTPHeaderField:HEADER_REQUEST_KEY];
                NSData *returnData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];
                //NSString *listFile = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                NSError *error;
                NSDictionary* responseData = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers error:&error];
                status = [responseData valueForKey:@"status"];
                if (!error && !status) {
                    [downloadedSetListContent addObject:[responseData valueForKey:@"sets"]];
                }
                else {
                    if (status) {
                        errMsg = [responseData valueForKey:@"msg"];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    if (!status) {
                        if ([[downloadedSetListContent objectAtIndex:0] valueForKey:@"Id"]) {
                            [self performSegueWithIdentifier:@"listAllSetPushSegue" sender:nil];
                        }
                    }
                    else {
                        if (errMsg) {
                            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",errMsg]];
                        }
                        else{
                            [SVProgressHUD showErrorWithStatus:@"Downloading lists failed"];
                        }
                        status = nil;
                    }
                    
                });
            });
            
        }
        else {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Plant Missing" message:@"Please select plant details from Settings to proceed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil , nil];
            [alert show];
        }
        
    }
    else{
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No Login Credentials Found" message:@"Please login to app after turning on internet settings to view this section" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [nameContentArr count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"SetFieldCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
    
    // Configure the cell...
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
    cell.textLabel.text = [nameContentArr objectAtIndex:indexPath.row];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.text = [descriptionContentArr objectAtIndex:indexPath.row];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [SVProgressHUD showWithStatus:@"Saving Settings" maskType:SVProgressHUDMaskTypeGradient];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[DataManager sharedManager] deleteAllDownloadsData];
        [[DataManager sharedManager] saveSelectedSetDetailsWithName:[[searchContentArr objectAtIndex:indexPath.row] valueForKey:@"Name"] andSetId:[[searchContentArr objectAtIndex:indexPath.row] valueForKey:@"Id"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [[self navigationController] popViewControllerAnimated:YES];
        });
    });
    //[self.navigationController performSegueWithIdentifier:@"AssetControllerSegue" sender:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.assetSearchBar resignFirstResponder];
    downloadedSetContent = [[NSMutableArray alloc] init];
    searchContentArr = [[NSMutableArray alloc] init];
    descriptionContentArr = [[NSMutableArray alloc] init];
    nameContentArr = [[NSMutableArray alloc] init];
    
    if ([[DataManager sharedManager] isInternetConnectionAvailable] && [[DataManager sharedManager] isLoggedIn]) {
        
        if ([[[DataManager sharedManager] selectedPlantSettings] valueForKey:@"Id"] && ![[[[DataManager sharedManager] selectedPlantSettings] valueForKey:@"Id"] isEqualToString:@""]) {
            
            [SVProgressHUD showWithStatus:@"Searching Lists Data" maskType:SVProgressHUDMaskTypeGradient];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSURL *theURL;
                if ([[DataManager sharedManager] restEnv]) {
                    theURL = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=getsets&instance_url=%@&access_token=%@&set=%@&plant_id=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[DataManager sharedManager] selectedPlantSettings] valueForKey:@"Id"]]];
                }
                else  {
                    theURL = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=getsets&instance_url=%@&access_token=%@&set=%@&plant_id=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken],[searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[DataManager sharedManager] selectedPlantSettings] valueForKey:@"Id"]]];
                }
                
                NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                
                [theRequest setValue:HEADER_REQUEST_VALUE forHTTPHeaderField:HEADER_REQUEST_KEY];
                NSData *returnData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];
                //NSString *listFile = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                NSError *error;
                NSDictionary* responseData = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers error:&error];
                status = [responseData valueForKey:@"status"];
                if (!error && !status) {
                    [downloadedSetContent addObject:[responseData valueForKey:@"sets"]];
                }
                else {
                    if (status) {
                        errMsg = [responseData valueForKey:@"msg"];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    if (!status) {
                        if ([[downloadedSetContent objectAtIndex:0] valueForKey:@"Id"]) {
                            searchContentArr = [downloadedSetContent objectAtIndex:0];
                            nameContentArr = [[downloadedSetContent objectAtIndex:0] valueForKey:@"Name"];
                            descriptionContentArr = [[downloadedSetContent objectAtIndex:0] valueForKey:@"Title"];
                            [self.searchTableView reloadData];
                            [self.listountLbl setText:[NSString stringWithFormat:@"%ld",(unsigned long)[nameContentArr count]]];
                        }
                    }
                    else {
                        if (errMsg) {
                            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",errMsg]];
                        }
                        else{
                            [SVProgressHUD showErrorWithStatus:@"Downloading lists failed"];
                        }
                        status = nil;
                    }
                    
                });
            });
            
        }
        else {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Plant Missing" message:@"Please select plant details from Settings to proceed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil , nil];
            [alert show];
        }
        
        
    }
    else{
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No Login Credentials Found" message:@"Please login to app after turning on internet settings to view this section" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
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
     if ([[segue identifier] isEqualToString:@"listAllSetPushSegue"]) {
         
         SetListViewController* controller = [segue destinationViewController];
         controller.downloadedSetContent = [downloadedSetListContent objectAtIndex:0];
         
     }
 }


- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showListsTapped:(id)sender {
    [self listAllSet:sender];
}
@end
