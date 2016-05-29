//
//  AddNoteViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria  on 10/6/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "AddNoteViewController.h"
#import "DataManager.h"
#import "SVProgressHUD.h"

@interface AddNoteViewController ()

@end

@implementation AddNoteViewController

@synthesize noteContentArr,noteTextField,currentAssetId;

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
    
    noteContentArr = [[NSMutableArray alloc] init];
    [noteContentArr addObject:@"Asset cannot be loaded"];
    [noteContentArr addObject:@"Suggest Asset be deleted"];
    
    //selectedPickerContent = [noteContentArr objectAtIndex: 0];
    
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
    
    noteTextField.inputView = picker;
    noteTextField.inputAccessoryView = toolBar;
    noteTextField.delegate = self;
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
}


-(void)pickerViewDoneButtonTapped:(id)sender{
    NSLog(@"Done tapped");
    noteTextField.text = selectedPickerContent;
    [noteTextField resignFirstResponder];
}

//animate the picker out of view
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [noteTextField becomeFirstResponder];
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
    
    selectedPickerContent = [noteContentArr objectAtIndex: 0];
    [l1 setText:[noteContentArr objectAtIndex:row]];
    
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
    return [noteContentArr  count];
}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    selectedPickerContent = [noteContentArr objectAtIndex: 0];
    return [noteContentArr objectAtIndex:row];
}

// Do something with the selected row.
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"You selected this: %@", [noteContentArr objectAtIndex: 0]);
    selectedPickerContent = [noteContentArr objectAtIndex:row];
    [pickerView reloadComponent:component];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)addNoteButtonTapped:(id)sender {
    [SVProgressHUD showWithStatus:@"Adding Notes" maskType:SVProgressHUDMaskTypeGradient];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString* noteType;
        
        if ([noteContentArr containsObject:selectedPickerContent]) {
            noteType = [NSString stringWithFormat:@"%d",(int)([noteContentArr indexOfObject:selectedPickerContent]+1)];
            //[[DataManager sharedManager] saveNoteTypeDetailsWithId:currentAssetId withNote:[NSString stringWithFormat:@"%d",(int)([noteContentArr indexOfObject:selectedPickerContent]+1)]];
        }
        
        //NSString* noteType = [[DataManager sharedManager] getNoteTypeForAssetId:currentAssetId];
        if (noteType && [[DataManager sharedManager] isInternetConnectionAvailable] && [[DataManager sharedManager] isLoggedIn]) {
            
            BOOL isUploadedSuccess = true;
            BOOL sessionExpired = false;
            
            NSString *post = [[DataManager sharedManager] getJsonStringForSyncNotesWithId:currentAssetId andNote:noteType];
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
            
            NSString* responseDataConv = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            
            NSLog(@"%@",responseDataConv);
            //NSString* responseStatus = [responseDataConv valueForKey:@"status"];
            if (!([responseDataConv rangeOfString:@"\"status\":true"].location == NSNotFound)) {
            }
            else {
                if (!([responseDataConv rangeOfString:@"Session expired or invalid"].location == NSNotFound)) {
                    sessionExpired = true;
                }
                isUploadedSuccess = false;
                [[DataManager sharedManager] saveNoteTypeDetailsWithId:currentAssetId withNote:noteType];
            }
            
        }
        else {
            if (noteType) {
                [[DataManager sharedManager] saveNoteTypeDetailsWithId:currentAssetId withNote:noteType];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [[self navigationController] popViewControllerAnimated:YES];
        });
    });
}
@end
