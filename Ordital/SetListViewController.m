//
//  SetListViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 30/11/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "SetListViewController.h"
#import "DataManager.h"
#import "SVProgressHUD.h"

@interface SetListViewController ()

@end

@implementation SetListViewController

@synthesize downloadedSetContent;

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
    
    nameContentArr = [[NSMutableArray alloc] init];
    descriptionContentArr = [[NSMutableArray alloc] init];
    
    nameContentArr = [downloadedSetContent valueForKey:@"Name"];
    descriptionContentArr = [downloadedSetContent valueForKey:@"Title"];
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
    
    [self.listCountLbl setText:[NSString stringWithFormat:@"%ld",(unsigned long)[nameContentArr count]]];
    
    [self setupInitialView];
}


- (void) setupInitialView {
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    dict  = [[DataManager sharedManager] getAllDynamicLabelValues];
    
    if (dict.count > 0) {
        
        NSString* plantSectionStr = [dict valueForKey:@"LISTS"];
        
        if (![plantSectionStr isEqual:[NSNull null]]) {
            self.listsLabel.text = plantSectionStr;
        }
        
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [nameContentArr count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"ListSetFieldCell";
    
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [SVProgressHUD showWithStatus:@"Saving Settings" maskType:SVProgressHUDMaskTypeGradient];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[DataManager sharedManager] deleteAllDownloadsData];
        [[DataManager sharedManager] saveSelectedSetDetailsWithName:[[downloadedSetContent objectAtIndex:indexPath.row] valueForKey:@"Name"] andSetId:[[downloadedSetContent objectAtIndex:indexPath.row] valueForKey:@"Id"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            NSMutableArray *newStack = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
            [newStack removeLastObject];
            [newStack removeLastObject];
            [self.navigationController setViewControllers:newStack animated:YES];
        });
    });
    //[self.navigationController performSegueWithIdentifier:@"AssetControllerSegue" sender:nil];
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

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
