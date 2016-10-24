//
//  ChildrenListViewController.m
//  Ordital
//
//  Created by Dhruv  on 10/17/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "ChildrenListViewController.h"
#import "CreateAssetViewController.h"
#import "DataManager.h"

@interface ChildrenListViewController ()

@end

@implementation ChildrenListViewController

@synthesize searchContentArr,isInternetActive;

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
    selectedIndex = -1;
    
    nameContentArr = [[NSMutableArray alloc] init];
    descriptionContentArr = [[NSMutableArray alloc] init];
    
    nameContentArr = [searchContentArr valueForKey:@"Name"];
    descriptionContentArr = [searchContentArr valueForKey:@"SHORT_DESCRIPTION__c"];
    
    scrollAssetContentArr = [[NSMutableArray alloc] init];
    
    self.childrenListTblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
    
    [self.childrenListCountLbl setText:[NSString stringWithFormat:@"%ld",(unsigned long)[nameContentArr count]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [nameContentArr count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"ChildAssetFieldCell";
    
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    CreateAssetViewController* controller = (CreateAssetViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"createassetcontroller"];
    
    AssetData* asset = [[AssetData alloc] init];
    
    asset.description = [descriptionContentArr objectAtIndex:selectedIndex];
    asset.assetName = [nameContentArr objectAtIndex:selectedIndex];
    
    asset.assetId = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Id"];
    asset.tag = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Tag__c"];
    asset.parent = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"PARENT_ASSET__Name"];
    asset.plantId = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Plant__id"];
    asset.plantName = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Plant__name"];
    asset.type = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"TYPE__c"];
    asset.condition = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"CONDITION__c"];
    
    asset.operatorType = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"OPERATOR_TYPE__c"];
    asset.operatorClass = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Class__name"];
    asset.operatorClassId = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Class__id"];
    asset.operatorSubclass = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"SubClass__name"];
    asset.operatorSubclassId = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"SubClass__id"];
    asset.category = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Category__name"];
    asset.categoryId = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Category__id"];
    
    asset.unableToLocate = [[[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"UNABLE_TO_LOCATE__c"] boolValue];
    
    if ([asset.tag isEqualToString:@"(null)"]) {
        asset.tag = @"";
    }
    if ([asset.parent isEqualToString:@"(null)"]) {
        asset.parent = @"";
    }
    
    [self replaceOldKeysWithNewKeys:searchContentArr];
    
    [controller setIsAssetToBeUpdated:true];
    [controller setAssetToUpdate:asset];
    
    [controller setScrollContentArr:scrollAssetContentArr];
    [controller setCurrentAssetViewType:2];
    [controller setCurrentScrollAssetIndex:selectedIndex];
    
    [controller setCurrentInternetStatus:isInternetActive];
    
    asset.parentId = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"PARENT_ASSET__c"];
    
    [self.navigationController pushViewController:controller animated:YES];
    
    //[self.navigationController performSegueWithIdentifier:@"AssetControllerSegue" sender:nil];
}

- (void) replaceOldKeysWithNewKeys:(NSMutableArray *)contentArr {
    for (int i = 0; i<[contentArr count]; i++) {
        
        NSMutableDictionary* dict = [contentArr objectAtIndex:i];
        if ([dict objectForKey: @"SHORT_DESCRIPTION__c"]) {
            [dict setObject: [dict objectForKey: @"SHORT_DESCRIPTION__c"] forKey: @"Short_description__c"];
            [dict removeObjectForKey: @"SHORT_DESCRIPTION__c"];
        }
        
        
        [scrollAssetContentArr addObject:dict];
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

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
