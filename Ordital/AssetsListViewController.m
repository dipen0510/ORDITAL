//
//  AssetsListViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 21/10/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "AssetsListViewController.h"
#import "CreateAssetViewController.h"
#import "DataManager.h"
#import "SVProgressHUD.h"

@interface AssetsListViewController ()

@end

@implementation AssetsListViewController

@synthesize searchContentArr,internetStatus,internetStatusImg,todayCount,todoCount,doneCount,offlineDoneArr,offlineTodayArr,offlineTodoArr;

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
    
    [self initializeDisplayContent];
    
    scrollAssetContentArr = [[NSMutableArray alloc] init];
    assetStatusArr = [[NSMutableArray alloc] init];
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
    
    if (internetStatus) {
        internetStatusImg.image = [UIImage imageNamed:@"connect-icon.png"];
    }
    else{
        internetStatusImg.image = [UIImage imageNamed:@"disconnect-icon.png"];
    }
    
    
    if (![self checkIfConneectionValid]) {
        
        //[self.segmentControl removeSegmentAtIndex:0 animated:NO];
        //[self.segmentControl removeSegmentAtIndex:0 animated:NO];
        
        [self.todayImg setImage:[UIImage imageNamed:@"today-icon-selected.png"]];
        [self.todayLbl setTextColor:[UIColor orangeColor]];
        [self.todayValLbl setTextColor:[UIColor orangeColor]];
        
        internetStatusImg.image = [UIImage imageNamed:@"disconnect-icon.png"];
        internetStatus = 0;
        
        [self.segmentControl setEnabled:NO forSegmentAtIndex:0];
        [self.segmentControl setEnabled:NO forSegmentAtIndex:1];
        
        [self refreshTableWithTodayAssets];
        
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
        UITapGestureRecognizer *gestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeSegment2:)];
        [self.todayView addGestureRecognizer:gestureRecognizer2];
        self.todayView.userInteractionEnabled = YES;
        
    }

}

-(void)viewWillAppear:(BOOL)animated {
    
    //isSecondTime = false;
    
    pendingTodayAssetCount = [[[DataManager sharedManager] getAllTodayAssets] count];
    
    
    if (viewNotLoadedForFirstTime) {
        
        if ([self checkIfConneectionValid]) {
            if (segmentSelectedIndex==1) {
                [self refreshTableWithIacValue:@"True"];
            }
            else if (segmentSelectedIndex==0){
                [self refreshTableWithIacValue:@"False"];
            }
            else {
                [self refreshTableWithTodayAssets];
            }
        }
        else {
            
            [self refreshTableWithTodayAssets];
            
        
        }
        
    }
    else {
        
        if ([self checkIfConneectionValid]) {
            [self adjustAssetCount];
        }
        
        
    }

}

-(void)viewDidAppear:(BOOL)animated {
    viewNotLoadedForFirstTime = 1;
}


-(void) changeSegment0 :(id)sender {
    
    [self.uncompletedImg setImage:[UIImage imageNamed:@"to-do-icon-selected.png"]];
    [self.uncompletedLbl setTextColor:[UIColor orangeColor]];
    [self.uncompletedValLbl setTextColor:[UIColor orangeColor]];
    
    [self.completedImg setImage:[UIImage imageNamed:@"done-icon-normal.png"]];
    [self.completedLbl setTextColor:[UIColor whiteColor]];
    [self.completedValLbl setTextColor:[UIColor whiteColor]];
    
    [self.todayImg setImage:[UIImage imageNamed:@"today-icon-normal.png"]];
    [self.todayLbl setTextColor:[UIColor whiteColor]];
    [self.todayValLbl setTextColor:[UIColor whiteColor]];
    
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
    
    [self.todayImg setImage:[UIImage imageNamed:@"today-icon-normal.png"]];
    [self.todayLbl setTextColor:[UIColor whiteColor]];
    [self.todayValLbl setTextColor:[UIColor whiteColor]];
    
    segmentSelectedIndex = 1;
    [self segmentControlValueChanged:sender];
    
}


-(void) changeSegment2 :(id)sender {
    
    [self.uncompletedImg setImage:[UIImage imageNamed:@"to-do-icon-normal.png"]];
    [self.uncompletedLbl setTextColor:[UIColor whiteColor]];
    [self.uncompletedValLbl setTextColor:[UIColor whiteColor]];
    
    [self.completedImg setImage:[UIImage imageNamed:@"done-icon-normal.png"]];
    [self.completedLbl setTextColor:[UIColor whiteColor]];
    [self.completedValLbl setTextColor:[UIColor whiteColor]];
    
    [self.todayImg setImage:[UIImage imageNamed:@"today-icon-selected.png"]];
    [self.todayLbl setTextColor:[UIColor orangeColor]];
    [self.todayValLbl setTextColor:[UIColor orangeColor]];
    
    segmentSelectedIndex = 2;
    [self segmentControlValueChanged:sender];
    
}




-(void) initializeDisplayContent {
    
    nameContentArr = [[NSMutableArray alloc] init];
    descriptionContentArr = [[NSMutableArray alloc] init];
    
    if (searchContentArr.count>0) {
        searchContentArr = [searchContentArr objectAtIndex:0];
    }
    
    for (int i = 0; i<[searchContentArr count]; i++) {
        NSDictionary* currentAsset = [[NSDictionary alloc] init];
        if (internetStatus) {
            currentAsset = [searchContentArr valueForKey:[NSString stringWithFormat:@"%d",i]];
        }
        else {
            currentAsset = [searchContentArr objectAtIndex:i];
        }
        [nameContentArr addObject:[currentAsset valueForKey:@"Name"]];
        [descriptionContentArr addObject:[currentAsset valueForKey:@"SHORT_DESCRIPTION__c"]];
    }
    
    [self adjustAssetCount];
    
    if (segmentSelectedIndex == 2) {
        [self initializeTodayAssetStatus];
    }
    
}

-(void) initializeDisplayContentForTodayAssetsOnlineMode {
    
    nameContentArr = [[NSMutableArray alloc] init];
    descriptionContentArr = [[NSMutableArray alloc] init];
    
    if ([searchContentArr count]>0) {
        
        searchContentArr = [[searchContentArr objectAtIndex:0] valueForKey:@"assets"];
        
//        if ([searchContentArr count]>1) {
//            
//            NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)searchContentArr];
//            searchContentArr = [[NSMutableArray alloc] initWithArray:[tmpDict allValues]];
//            
//            
//        }
        
    }
    
    for (int i = 0; i<[searchContentArr count]; i++) {
        NSDictionary* currentAsset = [[NSDictionary alloc] init];
        currentAsset = [searchContentArr objectAtIndex:i];
        [nameContentArr addObject:[currentAsset valueForKey:@"Name"]];
        
        NSString* desc = [currentAsset valueForKey:@"SHORT_DESCRIPTION__c"];
        if (desc && ![desc isKindOfClass:[NSNull class]]) {
            [descriptionContentArr addObject:desc];
        }
        else {
            [descriptionContentArr addObject:@""];
        }
        
    }
    
    //Adding pending today assets to list in online mode
    
    NSMutableArray* assetArr = [[DataManager sharedManager] getAllTodayAssets];
    for (int i = 0; i<[assetArr count]; i++) {
        NSDictionary* currentAsset = [[NSDictionary alloc] init];
        currentAsset = [assetArr objectAtIndex:i];
        [searchContentArr addObject:currentAsset];
        [nameContentArr addObject:[currentAsset valueForKey:@"Name"]];
        [descriptionContentArr addObject:[currentAsset valueForKey:@"SHORT_DESCRIPTION__c"]];
    }
    
    [self adjustAssetCount];
    
    [self initializeTodayAssetStatus];
    
}

-(void) initializeTodayAssetStatus {
    
    NSMutableArray* auditArr = [[DataManager sharedManager] getAllAuditData];
    NSMutableArray* assetArr = [[DataManager sharedManager] getAllAssetsToBeSynced];
    assetStatusArr = [[NSMutableArray alloc] init];
    
    for (int i=0; i < searchContentArr.count; i++) {
        
        int tmpStatus = 0;
        
        for (int j=0; j < auditArr.count; j++) {
            AuditData* tmpAudit = [auditArr objectAtIndex:j];
            if ([tmpAudit.assetId isEqualToString:[[searchContentArr objectAtIndex:i] valueForKey:@"Iphone_Asset_Id__c"]]) {
                tmpStatus = 1;
                break;
            }
        }
        if (tmpStatus) {
            [assetStatusArr addObject:[NSNumber numberWithInt:0]];
            continue;
        }
        
        for (int k=0; k < assetArr.count; k++) {
            if ([[[assetArr objectAtIndex:k] valueForKey:@"id"] isEqualToString:[[searchContentArr objectAtIndex:i] valueForKey:@"Id"]]) {
                tmpStatus = 1;
                break;
            }
        }
        if (tmpStatus) {
            [assetStatusArr addObject:[NSNumber numberWithInt:0]];
            continue;
        }
        
        [assetStatusArr addObject:[NSNumber numberWithInt:1]];

        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) adjustAssetCount {
    
    if (internetStatus) {
        
        if (segmentSelectedIndex != 2) {
            todayCount = [NSString stringWithFormat:@"%d",[todayCount intValue] + pendingTodayAssetCount];
        }
        
        
        long tmpToDoCount = [todoCount intValue];
        long tmpDoneCount = [doneCount intValue];
        long tmpTodayCount = [todayCount intValue];
        long diff ;
        
        tmpDoneCount = tmpDoneCount - doneDiffCount;
        tmpToDoCount = tmpToDoCount - todoDiffCount;
        
        if (segmentSelectedIndex == 0) {
            diff = tmpToDoCount - [nameContentArr count];
            if (diff > 0) {
                
                tmpToDoCount = tmpToDoCount - diff;
                todoDiffCount = todoDiffCount + diff;
                //tmpTodayCount = tmpTodayCount + diff;
                
            }
        }
        if (segmentSelectedIndex == 1) {
            diff = tmpDoneCount - [nameContentArr count];
            if (diff > 0) {
                
                tmpDoneCount = tmpDoneCount - diff;
                doneDiffCount = doneDiffCount + diff;
                //tmpTodayCount = tmpTodayCount + diff;
                
            }
        }
        
        
        [self.uncompletedValLbl setText:[NSString stringWithFormat:@"%ld",tmpToDoCount]];
        [self.completedValLbl setText:[NSString stringWithFormat:@"%ld",tmpDoneCount]];
        [self.todayValLbl setText:[NSString stringWithFormat:@"%ld",tmpTodayCount]];
        
    }
    else {
        
        [self.uncompletedValLbl setText:[NSString stringWithFormat:@"%d",offlineTodoArr.count]];
        [self.completedValLbl setText:[NSString stringWithFormat:@"%d",offlineDoneArr.count]];
        [self.todayValLbl setText:[NSString stringWithFormat:@"%d",offlineTodayArr.count]];
        
    }
    
    
    
    
    isSecondTime = true;
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    
    return [nameContentArr count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"ListAssetFieldCell";
    
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
    
    if (segmentSelectedIndex == 2) {
        
        UIImage *image = [[UIImage alloc] init];
        if ([[assetStatusArr objectAtIndex:indexPath.row] intValue] == 0) {
            image = [UIImage imageNamed:@"orange.png"];
        }
        else {
            image = [UIImage imageNamed:@"green.png"];
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
        button.frame = frame;
        [button setBackgroundImage:image forState:UIControlStateNormal];
        
        button.backgroundColor = [UIColor clearColor];
        cell.accessoryView = button;
        
        
    }
    else {
        cell.accessoryView = nil;
    }
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (segmentSelectedIndex != 2) {
        selectedIndex = indexPath.row;
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        
        CreateAssetViewController* controller = (CreateAssetViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"createassetcontroller"];
        
        AssetData* asset = [[AssetData alloc] init];
        
        asset.description = [descriptionContentArr objectAtIndex:selectedIndex];
        asset.assetName = [nameContentArr objectAtIndex:selectedIndex];
        
        if (internetStatus) {
            asset.assetId = [[searchContentArr valueForKey:[NSString stringWithFormat:@"%d",selectedIndex]] valueForKey:@"ASSETS_id"];
            
            asset.parent = [[searchContentArr valueForKey:[NSString stringWithFormat:@"%d",selectedIndex]] valueForKey:@"PARENT_ASSET__Name"];
            asset.plantId = [[searchContentArr valueForKey:[NSString stringWithFormat:@"%d",selectedIndex]] valueForKey:@"Plant__id"];
            asset.plantName = [[searchContentArr valueForKey:[NSString stringWithFormat:@"%d",selectedIndex]] valueForKey:@"Plant__name"];
            asset.type = [[searchContentArr valueForKey:[NSString stringWithFormat:@"%d",selectedIndex]] valueForKeyPath:@"TYPE__c"];
            
            asset.tag = [[searchContentArr valueForKey:[NSString stringWithFormat:@"%d",selectedIndex]] valueForKey:@"TAG__c"];
            
            asset.unableToLocate = [[[searchContentArr valueForKey:[NSString stringWithFormat:@"%d",selectedIndex]] valueForKey:@"UNABLE_TO_LOCATE__c"] boolValue];
            asset.condition = [[searchContentArr valueForKey:[NSString stringWithFormat:@"%d",selectedIndex]] valueForKey:@"CONDITION__c"];
            asset.operatorType = [[searchContentArr valueForKey:[NSString stringWithFormat:@"%d",selectedIndex]] valueForKey:@"OPERATOR_TYPE__c"];
            asset.operatorClass = [[searchContentArr valueForKey:[NSString stringWithFormat:@"%d",selectedIndex]] valueForKey:@"Class__name"];
            asset.operatorClassId = [[searchContentArr valueForKey:[NSString stringWithFormat:@"%d",selectedIndex]] valueForKey:@"Class__id"];
            asset.operatorSubclass = [[searchContentArr valueForKey:[NSString stringWithFormat:@"%d",selectedIndex]] valueForKey:@"SubClass__name"];
            asset.operatorSubclassId = [[searchContentArr valueForKey:[NSString stringWithFormat:@"%d",selectedIndex]] valueForKey:@"SubClass__id"];
            asset.category = [[searchContentArr valueForKey:[NSString stringWithFormat:@"%d",selectedIndex]] valueForKey:@"Category__name"];
            asset.categoryId = [[searchContentArr valueForKey:[NSString stringWithFormat:@"%d",selectedIndex]] valueForKey:@"Category__id"];
            
            [self replaceOldKeysWithNewKeys:searchContentArr];
            
            asset.parentId = [[searchContentArr valueForKey:[NSString stringWithFormat:@"%d",selectedIndex]] valueForKey:@"PARENT_ASSET__c"];
        }
        else {
            asset.assetId = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Id"];
            
            asset.parent = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"PARENT_ASSET__Name"];
            asset.plantId = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Plant__id"];
            asset.plantName = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Plant__name"];
            asset.type = [[searchContentArr objectAtIndex:selectedIndex] valueForKeyPath:@"TYPE__c"];
            
            asset.tag = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Tag__c"];
            
            asset.unableToLocate = [[[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"UNABLE_TO_LOCATE__c"] boolValue];
            asset.condition = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"CONDITION__c"];
            asset.operatorType = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"OPERATOR_TYPE__c"];
            asset.operatorClass = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Class__name"];
            asset.operatorClassId = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Class__id"];
            asset.operatorSubclass = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"SubClass__name"];
            asset.operatorSubclassId = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"SubClass__id"];
            asset.category = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Category__name"];
            asset.categoryId = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Category__id"];
            
            [self replaceOldKeysWithNewKeysOnlyDesc:searchContentArr];
            
            asset.parentId = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"PARENT_ASSET__c"];
        }
        
        
        if ([asset.tag isEqualToString:@"(null)"]) {
            asset.tag = @"";
        }
        if ([asset.parent isEqualToString:@"(null)"]) {
            asset.parent = @"";
        }
        if ([asset.parentId isEqualToString:@"(null)"]) {
            asset.parentId = @"";
        }
        if ([asset.condition isEqualToString:@"(null)"]) {
            asset.condition = @"";
        }
        
        [controller setIsAssetToBeUpdated:true];
        [controller setAssetToUpdate:asset];
        
        [controller setScrollContentArr:scrollAssetContentArr];
        [controller setCurrentAssetViewType:1];
        [controller setCurrentScrollAssetIndex:selectedIndex];
        [controller setCurrentInternetStatus:internetStatus];
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    //For Today's asset
    
    else {
        
        selectedIndex = indexPath.row;
        
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
            
        asset.tag = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"TAG__c"];
            
        asset.unableToLocate = [[[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"UNABLE_TO_LOCATE__c"] boolValue];
        asset.condition = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"CONDITION__c"];
        asset.operatorType = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"OPERATOR_TYPE__c"];
        asset.operatorClass = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Class__name"];
        asset.operatorClassId = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Class__id"];
        asset.operatorSubclass = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"SubClass__name"];
        asset.operatorSubclassId = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"SubClass__id"];
        asset.category = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Category__name"];
        asset.categoryId = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"Category__id"];
        
        [self replaceOldKeysWithNewKeysOnlyDesc:searchContentArr];
            
        asset.parentId = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"PARENT_ASSET__c"];
        
        
        if ([asset.tag isEqualToString:@"(null)"]) {
            asset.tag = @"";
        }
        if ([asset.parent isEqualToString:@"(null)"]) {
            asset.parent = @"";
        }
        if ([asset.parentId isEqualToString:@"(null)"]) {
            asset.parentId = @"";
        }
        
        NSString* tmpIsNewAsset = [[searchContentArr objectAtIndex:selectedIndex] valueForKey:@"isNewAsset"];
        if (tmpIsNewAsset && ![tmpIsNewAsset isEqualToString:@""]) {
            
            asset.isNewAsset = [tmpIsNewAsset boolValue];
            
        }
        
        [controller setIsAssetToBeUpdated:true];
        [controller setAssetToUpdate:asset];
        
        [controller setScrollContentArr:scrollAssetContentArr];
        [controller setCurrentAssetViewType:1];
        [controller setCurrentScrollAssetIndex:selectedIndex];
        [controller setCurrentInternetStatus:internetStatus];
        [self.navigationController pushViewController:controller animated:YES];
        
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60.0;
    
}

- (void) replaceOldKeysWithNewKeys:(NSMutableArray *)contentArr {
    for (int i = 0; i<[contentArr count]; i++) {
        
        NSMutableDictionary* dict = [contentArr valueForKey:[NSString stringWithFormat:@"%d",i]];
        if ([dict objectForKey: @"SHORT_DESCRIPTION__c"]) {
            [dict setObject: [dict objectForKey: @"SHORT_DESCRIPTION__c"] forKey: @"Short_description__c"];
            [dict removeObjectForKey: @"SHORT_DESCRIPTION__c"];
        }
        if ([dict objectForKey: @"TAG__c"]) {
            [dict setObject: [dict objectForKey: @"TAG__c"] forKey: @"Tag__c"];
            [dict removeObjectForKey: @"TAG__c"];
        }
        if ([dict objectForKey: @"ASSETS_id"]) {
            [dict setObject: [dict objectForKey: @"ASSETS_id"] forKey: @"Id"];
            [dict removeObjectForKey: @"ASSETS_id"];
        }
        
        [scrollAssetContentArr addObject:dict];
    }
}

- (void) replaceOldKeysWithNewKeysOnlyDesc:(NSMutableArray *)contentArr {
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

-(BOOL) checkIfConneectionValid {
    
    if ([[[DataManager sharedManager] selectedConnectionSettings] isEqualToString:@"STANDALONE"]) {
        return false;
    }
    
    return true;
    
}

- (IBAction)segmentControlValueChanged:(id)sender {
    
    offlineDoneArr = [[NSMutableArray alloc] init];
    offlineTodayArr = [[NSMutableArray alloc] init];
    offlineTodoArr = [[NSMutableArray alloc] init];
    
    if ([self checkIfConneectionValid]) {
        
        if (segmentSelectedIndex == 1 ) {
            [self refreshTableWithIacValue:@"True"];
        }
        else if (segmentSelectedIndex == 0){
            [self refreshTableWithIacValue:@"False"];
        }
        else {
            [self refreshTableWithTodayAssets];
        }
        
    }
    else {
        
        if (segmentSelectedIndex == 2) {
            [self refreshTableWithTodayAssets];
        }
        
    }
    
    
}

-(void) refreshTableWithTodayAssets {
    
        assetListContentArr = [[NSMutableArray alloc] init];
    //todayCount = 0;
    
    if ([self checkIfConneectionValid]) {
        
        if ([[DataManager sharedManager] isInternetConnectionAvailable]) {
            if ([[DataManager sharedManager] isLoggedIn]) {
                [SVProgressHUD showWithStatus:@"Downloading Asset Data" maskType:SVProgressHUDMaskTypeGradient];
                
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
                            internetStatus = true;
                            searchContentArr = [[NSMutableArray alloc] init];
                            searchContentArr = assetListContentArr;
                            [self initializeDisplayContentForTodayAssetsOnlineMode];
                            [self.assetListTblView reloadData];
                        }
                        else {
                            if (errMsg) {
                                //[SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",errMsg]];
                            }
                            else{
                                [SVProgressHUD showErrorWithStatus:@"Downloading Assets failed"];
                            }
                            status = nil;
                            
                            searchContentArr = [[NSMutableArray alloc] init];
                            nameContentArr = [[NSMutableArray alloc] init];
                            descriptionContentArr = [[NSMutableArray alloc] init];
                            [self initializeDisplayContentForTodayAssetsOnlineMode];
                            [self.assetListTblView reloadData];
                        }
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
                
                
                NSMutableArray* responseData = [[NSMutableArray alloc] init];
                
                responseData = [[DataManager sharedManager] getAllTodayAssets];
                [responseData addObjectsFromArray:[[DataManager sharedManager] getOfflineTodayDetails]];
                
                offlineTodayArr = (NSMutableArray *)responseData;
                offlineDoneArr = (NSMutableArray *)[[DataManager sharedManager] getAllDownloadedAssetsWithAuditCompleted];
                offlineTodoArr = (NSMutableArray *)[[DataManager sharedManager] getAllDownloadedAssetsWithAuditUncompleted];
                
                if ([[DataManager sharedManager] getPunchListDetails]) {
                    offlineDoneArr = [self filterAssetsToBeSyncedFromSearchForPunchListForOffline:(NSMutableArray *)offlineDoneArr];
                    offlineTodoArr = [self filterAssetsToBeSyncedFromSearchForPunchListForOffline:(NSMutableArray *)offlineTodoArr];
                }
                
                
                [assetListContentArr addObject:responseData];
                //[[DataManager sharedManager] saveDownloadData:responseData];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    //[[self navigationController] popToRootViewControllerAnimated:YES];
                    if ([[assetListContentArr objectAtIndex:0] count]>0) {
                        internetStatus = false;
                        searchContentArr = [[NSMutableArray alloc] init];
                        searchContentArr = assetListContentArr;
                        [self initializeDisplayContent];
                        [self.assetListTblView reloadData];
                        
                    }
                    else {
                        searchContentArr = [[NSMutableArray alloc] init];
                        nameContentArr = [[NSMutableArray alloc] init];
                        descriptionContentArr = [[NSMutableArray alloc] init];
                        [self.assetListTblView reloadData];
                    }
                });
            });
        }
        
    }
    else {
        
        [SVProgressHUD showWithStatus:@"Fetching Asset Data" maskType:SVProgressHUDMaskTypeGradient];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            
            NSMutableArray* responseData = [[NSMutableArray alloc] init];
            
            responseData = [[DataManager sharedManager] getAllTodayAssets];
            [responseData addObjectsFromArray:[[DataManager sharedManager] getOfflineTodayDetails]];
            
            offlineTodayArr = (NSMutableArray *)responseData;
            offlineDoneArr = (NSMutableArray *)[[DataManager sharedManager] getAllDownloadedAssetsWithAuditCompleted];
            offlineTodoArr = (NSMutableArray *)[[DataManager sharedManager] getAllDownloadedAssetsWithAuditUncompleted];
            
            if ([[DataManager sharedManager] getPunchListDetails]) {
                offlineDoneArr = [self filterAssetsToBeSyncedFromSearchForPunchListForOffline:(NSMutableArray *)offlineDoneArr];
                offlineTodoArr = [self filterAssetsToBeSyncedFromSearchForPunchListForOffline:(NSMutableArray *)offlineTodoArr];
            }
            
            
            [assetListContentArr addObject:responseData];
            //[[DataManager sharedManager] saveDownloadData:responseData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                //[[self navigationController] popToRootViewControllerAnimated:YES];
                if ([[assetListContentArr objectAtIndex:0] count]>0) {
                    internetStatus = false;
                    searchContentArr = [[NSMutableArray alloc] init];
                    searchContentArr = assetListContentArr;
                    [self initializeDisplayContent];
                    [self.assetListTblView reloadData];
                    
                }
                else {
                    searchContentArr = [[NSMutableArray alloc] init];
                    nameContentArr = [[NSMutableArray alloc] init];
                    descriptionContentArr = [[NSMutableArray alloc] init];
                    [self.assetListTblView reloadData];
                }
            });
        });
        
    }

    
}

-(void) refreshTableWithIacValue:(NSString *)iacValue {
    
    if (!([[[[DataManager sharedManager] getSelectedSetDetails] valueForKey:@"Id"] isEqualToString:@""])) {
        assetListContentArr = [[NSMutableArray alloc] init];
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
                        theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=getassets&instance_url=%@&access_token=%@&plant_section=%@&system=%@&criticality=%@&source_documents=%@&set_id=%@&short_desc=1&parent=1&tag=1&make=1&type=1&iac=%@&punch_list=%@",PRODUCTION_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken], [[[DataManager sharedManager] getSelectedPlantSectionDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[DataManager sharedManager] getSelectedSystemDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ,[[[DataManager sharedManager] getSelectedCriticalityDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[DataManager sharedManager] getSelectedSourceDocsDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[[DataManager sharedManager] getSelectedSetDetails] valueForKey:@"Id"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],iacValue,punchListParam]];
                    }
                    else {
                        theURL =  [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@?action_type=getassets&instance_url=%@&access_token=%@&plant_section=%@&system=%@&criticality=%@&source_documents=%@&set_id=%@&short_desc=1&parent=1&tag=1&make=1&type=1&iac=%@&punch_list=%@",SANDOBOX_REST_URL,[[DataManager sharedManager] getInstanceURL],[[DataManager sharedManager] getAuthToken], [[[DataManager sharedManager] getSelectedPlantSectionDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[DataManager sharedManager] getSelectedSystemDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ,[[[DataManager sharedManager] getSelectedCriticalityDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[DataManager sharedManager] getSelectedSourceDocsDetails] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[[DataManager sharedManager] getSelectedSetDetails] valueForKey:@"Id"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],iacValue,punchListParam]];
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
                            if ([iacValue isEqualToString:@"False"]) {
                                [self filterAssetsToBeSyncedFromSearch:responseData];
                            }
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
                            internetStatus = true;
                            searchContentArr = [[NSMutableArray alloc] init];
                            searchContentArr = assetListContentArr;
                            [self initializeDisplayContent];
                            [self.assetListTblView reloadData];
                        }
                        else {
                            if (errMsg) {
                                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",errMsg]];
                            }
                            else{
                                [SVProgressHUD showErrorWithStatus:@"Downloading Assets failed"];
                            }
                            status = nil;
                            
                            searchContentArr = [[NSMutableArray alloc] init];
                            nameContentArr = [[NSMutableArray alloc] init];
                            descriptionContentArr = [[NSMutableArray alloc] init];
                            [self.assetListTblView reloadData];
                        }
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
                if ([iacValue isEqualToString:@"True"]) {
                    responseData = [[DataManager sharedManager] getAllDownloadedAssetsWithAuditCompleted];
                    
                    offlineDoneArr = (NSMutableArray *)responseData;
                    offlineTodoArr = (NSMutableArray *)[[DataManager sharedManager] getAllDownloadedAssetsWithAuditUncompleted];
                    
                }
                else {
                    responseData = [[DataManager sharedManager] getAllDownloadedAssetsWithAuditUncompleted];
                    
                    offlineTodoArr = (NSMutableArray *)responseData;
                    offlineDoneArr = (NSMutableArray *)[[DataManager sharedManager] getAllDownloadedAssetsWithAuditCompleted];
                }
                
                offlineTodayArr = [[DataManager sharedManager] getAllTodayAssets];
                [offlineTodayArr addObjectsFromArray:[[DataManager sharedManager] getOfflineTodayDetails]];
                
                if ([[DataManager sharedManager] getPunchListDetails]) {
                    responseData = (NSMutableDictionary *)[self filterAssetsToBeSyncedFromSearchForPunchListForOffline:(NSMutableArray *)responseData];
                    offlineDoneArr = [self filterAssetsToBeSyncedFromSearchForPunchListForOffline:(NSMutableArray *)offlineDoneArr];
                    offlineTodoArr = [self filterAssetsToBeSyncedFromSearchForPunchListForOffline:(NSMutableArray *)offlineTodoArr];
                }
                
                [assetListContentArr addObject:responseData];
                //[[DataManager sharedManager] saveDownloadData:responseData];
                
                NSMutableDictionary* countDict = [[NSMutableDictionary alloc] init];
                countDict = [[DataManager sharedManager] getAssetCountDetails];
                
                todayCount = [countDict valueForKey:@"Today"];
                todoCount = [countDict valueForKey:@"Todo"];
                doneCount = [countDict valueForKey:@"Done"];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    //[[self navigationController] popToRootViewControllerAnimated:YES];
                    if ([[assetListContentArr objectAtIndex:0] count]>0) {
                        internetStatus = false;
                        searchContentArr = [[NSMutableArray alloc] init];
                        searchContentArr = assetListContentArr;
                        [self initializeDisplayContent];
                        [self.assetListTblView reloadData];
                        
                    }
                    else {
                        searchContentArr = [[NSMutableArray alloc] init];
                        nameContentArr = [[NSMutableArray alloc] init];
                        descriptionContentArr = [[NSMutableArray alloc] init];
                        [self.assetListTblView reloadData];
                    }
                });
            });
        }
    }
    else {
        
        searchContentArr = [[NSMutableArray alloc] init];
        nameContentArr = [[NSMutableArray alloc] init];
        descriptionContentArr = [[NSMutableArray alloc] init];
        [self.assetListTblView reloadData];
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No Location defined" message:@"Please select Location from Filters in Settings to view this section" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
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

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
