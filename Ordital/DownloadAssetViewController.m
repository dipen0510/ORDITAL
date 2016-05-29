//
//  DownloadAssetViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 23/09/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "DownloadAssetViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DataManager.h"
#import "SVProgressHUD.h"


@interface DownloadAssetViewController ()

@end

@implementation DownloadAssetViewController
@synthesize assetSetLabel,assetTableView,assetContentArr;

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
    
    selectedPickerContent = [[assetContentArr objectAtIndex: 0] objectAtIndex:0];
    
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
    
    assetSetLabel.inputView = picker;
    assetSetLabel.inputAccessoryView = toolBar;
    assetSetLabel.delegate = self;
    
    
    cellSelected = [[NSMutableArray alloc] init];
    
    assetTableView.layer.borderWidth = 1.0f;
    assetTableView.layer.borderColor = [UIColor grayColor].CGColor;
    assetFieldArr = [NSArray arrayWithObjects:@"Asset Name",@"Short Description",@"TAG",@"Parent",@"Make",@"Type", nil];
    
    /*assetContentArr = [[NSMutableArray alloc] init];
    
    
    
    // Add some data for demo purposes.
    [assetContentArr addObject:@"ST-000000008"];
    [assetContentArr addObject:@"ST-000065757"];
    [assetContentArr addObject:@"ST-002374232"];
    [assetContentArr addObject:@"ST-000002032"];
    [assetContentArr addObject:@"ST-000932732"];*/
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
}

-(void)pickerViewDoneButtonTapped:(id)sender{
    NSLog(@"Done tapped");
    assetSetLabel.text = [selectedPickerContent valueForKey:@"Name"];
    [assetSetLabel resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [assetFieldArr count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"AssetFieldCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    // Configure the cell...
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    
    cell.textLabel.text = [assetFieldArr objectAtIndex:indexPath.row];
    
    if ([cellSelected containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]] || indexPath.row==0)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //if you want only one cell to be selected use a local NSIndexPath property instead of array. and use the code below
    //self.selectedIndexPath = indexPath;
    
    //the below code will allow multiple selection
    if (indexPath.row!=0) {
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
    
}


//animate the picker out of view
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [assetSetLabel becomeFirstResponder];
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
    
    NSDictionary* currentSet = [[assetContentArr objectAtIndex: 0] objectAtIndex:row];
    [l1 setText: [currentSet valueForKey:@"Name"]];
    
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
    return [[assetContentArr objectAtIndex:0] count];
}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSDictionary* currentSet = [[assetContentArr objectAtIndex: 0] objectAtIndex:row];
    return [currentSet valueForKey:@"Name"];
}

// Do something with the selected row.
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"You selected this: %@", [[[assetContentArr objectAtIndex: 0] objectAtIndex:row] valueForKey:@"Name"]);
    selectedPickerContent = [[assetContentArr objectAtIndex: 0] objectAtIndex:row];
}

//just hide the keyboard in this example
/*- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)downloadTapped:(id)sender {
    
    [SVProgressHUD showWithStatus:@"Downloading Asset Data" maskType:SVProgressHUDMaskTypeGradient];
    NSString* shortDescSelection = [[NSString alloc] init];
    NSString* tagSelection = [[NSString alloc] init];
    NSString* parentSelection = [[NSString alloc] init];
    NSString* makeSelection = [[NSString alloc] init];
    NSString* typeSelection = [[NSString alloc] init];
    if ([cellSelected containsObject:@"1"]) {
        shortDescSelection = @"1";
    }
    if ([cellSelected containsObject:@"2"]) {
        tagSelection = @"1";
    }
    if ([cellSelected containsObject:@"3"]) {
        parentSelection = @"1";
    }
    if ([cellSelected containsObject:@"4"]) {
        makeSelection = @"1";
    }
    if ([cellSelected containsObject:@"5"]) {
        typeSelection = @"1";
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString* punchListParam = @"False";
        if ([[DataManager sharedManager] getPunchListDetails]) {
            punchListParam = @"True";
        }
        
        NSURL *theURL;
        if ([[DataManager sharedManager] restEnv]) {
            theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=getassets&instance_url=%@&access_token=%@&set_id=%@&short_desc=%@&parent=%@&tag=%@&make=%@&type=%@&punch_list=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken], [selectedPickerContent valueForKey:@"Id"], shortDescSelection, parentSelection, tagSelection,makeSelection,typeSelection,punchListParam]];
        }
        else {
            theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=getassets&instance_url=%@&access_token=%@&set_id=%@&short_desc=%@&parent=%@&tag=%@&make=%@&type=%@&punch_list=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken], [selectedPickerContent valueForKey:@"Id"], shortDescSelection, parentSelection, tagSelection,makeSelection,typeSelection,punchListParam]];
        }
        NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        [theRequest setValue:HEADER_REQUEST_VALUE forHTTPHeaderField:HEADER_REQUEST_KEY];
        NSData *returnData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];
        //NSString *listFile = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        NSError *error;
        if (returnData) {
            NSMutableDictionary* responseData = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers error:&error];
            [responseData removeObjectForKey:@"token"];
            [responseData removeObjectForKey:@"instance_url"];
            [responseData removeObjectForKey:@"RecordCount"];
            [[DataManager sharedManager] saveDownloadData:responseData];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [[self navigationController] popToRootViewControllerAnimated:YES];
        });
    });
    
}
@end
