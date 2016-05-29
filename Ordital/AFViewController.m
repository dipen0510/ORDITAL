//
//  AFViewController.m
//  AFTabledCollectionView
//
//  Created by Ash Furrow on 2013-03-14.
//  Copyright (c) 2013 Ash Furrow. All rights reserved.
//

#import "AFViewController.h"
#import "AFTableViewCell.h"
#import "ScrollAuditImageViewController.h"
#import "AddAuditViewController.h"
#import "AuditImageCollectionViewCell.h"

@interface AFViewController ()

@property (nonatomic, strong) NSArray *colorArray;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;

@end

@implementation AFViewController

@synthesize currentAssetId,assetObj;

-(void)loadView
{
    [super loadView];
    
    const NSInteger numberOfTableViewRows = 20;
    const NSInteger numberOfCollectionViewCells = 15;
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:numberOfTableViewRows];
    
    for (NSInteger tableViewRow = 0; tableViewRow < numberOfTableViewRows; tableViewRow++)
    {
        NSMutableArray *colorArray = [NSMutableArray arrayWithCapacity:numberOfCollectionViewCells];
        
        for (NSInteger collectionViewItem = 0; collectionViewItem < numberOfCollectionViewCells; collectionViewItem++)
        {
            
            CGFloat red = arc4random() % 255;
            CGFloat green = arc4random() % 255;
            CGFloat blue = arc4random() % 255;
            UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0f];
            
            [colorArray addObject:color];
        }
        
        [mutableArray addObject:colorArray];
    }
    
    self.colorArray = [NSArray arrayWithArray:mutableArray];
    
    self.contentOffsetDictionary = [NSMutableDictionary dictionary];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
    
    auditContentArr = [[NSMutableArray alloc] init];
    auditImageArr = [[NSMutableArray alloc] init];
    equipmentArr = [[NSMutableArray alloc] init];
    tagArr = [[NSMutableArray alloc] init];
    nameplateArr = [[NSMutableArray alloc] init];
    serviceArr = [[NSMutableArray alloc] init];
    vendorArr = [[NSMutableArray alloc] init];
    inspectionArr = [[NSMutableArray alloc] init];
    
    equipmentArr1 = [[NSMutableArray alloc] init];
    tagArr1 = [[NSMutableArray alloc] init];
    nameplateArr1 = [[NSMutableArray alloc] init];
    serviceArr1 = [[NSMutableArray alloc] init];
    vendorArr1 = [[NSMutableArray alloc] init];
    inspectionArr1 = [[NSMutableArray alloc] init];
    
    sectionArr = [[NSMutableArray alloc] init];
    auditContentSortedArr = [[NSMutableArray alloc] init];
    
    auditContentArr = [[DataManager sharedManager] getAllAuditsToBeSyncedForAssetId:currentAssetId];
    
    for (int i = 0; i<auditContentArr.count; i++) {
        
        NSDictionary* currentAudit = [auditContentArr objectAtIndex:i];
        NSString* auditType = [currentAudit valueForKey:@"auditType"];
        
        if ([[auditContentSortedArr valueForKey:@"Name"] containsObject:auditType]) {
            
            NSMutableArray* tmpArr = [[NSMutableArray alloc] init];
            NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
            tmpDict = [auditContentSortedArr objectAtIndex:[[auditContentSortedArr valueForKey:@"Name"] indexOfObject:auditType]];
            tmpArr = [tmpDict valueForKey:@"AuditArr"];
            
            [tmpArr addObject:currentAudit];
            
        }
        else {
            
            NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
            [tmpDict setObject:auditType forKey:@"Name"];
            [tmpDict setObject:[[NSMutableArray alloc] initWithObjects:currentAudit, nil] forKey:@"AuditArr"];
            
            [auditContentSortedArr addObject:tmpDict];
            
        }
        
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = true;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [auditContentSortedArr count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [[auditContentSortedArr objectAtIndex:section] valueForKey:@"Name"];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    AFTableViewCell *cell = (AFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[AFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
        
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(AFTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
    NSInteger index = cell.collectionView.tag;
    
    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
    [cell.collectionView setBackgroundColor:self.view.backgroundColor];
}

#pragma mark - UITableViewDelegate Methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 40;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(10, 8, 320, 20);
    myLabel.font = [UIFont boldSystemFontOfSize:15];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    myLabel.textColor = [UIColor darkGrayColor];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    NSMutableArray* tmpArr = [[NSMutableArray alloc] init];
    tmpArr = [[auditContentSortedArr objectAtIndex:[(AFIndexedCollectionView *)collectionView indexPath].section] valueForKey:@"AuditArr"];
    
    return [tmpArr count];
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    AuditImageCollectionViewCell *cell = (AuditImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    
    NSMutableArray* tmpArr = [[NSMutableArray alloc] init];
    NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
    tmpArr = [[auditContentSortedArr objectAtIndex:[(AFIndexedCollectionView *)collectionView indexPath].section] valueForKey:@"AuditArr"];
    tmpDict = [tmpArr objectAtIndex:indexPath.row];
    
    cell.imgView.image = [[DataManager sharedManager] loadAuditImagewithPath:[tmpDict valueForKey:@"imgURL"]];
    
    
    [cell.deleteButton addTarget:self action:@selector(showName:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.deleteButton.tag = (indexPath.row+1)+([(AFIndexedCollectionView *)collectionView indexPath].section*100);

    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
    selectedIndex = [(AFIndexedCollectionView *)collectionView indexPath];
    NSLog(@"Selected Index %@",selectedIndex);
    // [self performSegueWithIdentifier:@"detailViewPushSegue" sender:nil];*/
    [self performSegueWithIdentifier:@"scrollPushSegue" sender:nil];
    
}

-(NSIndexPath*)getIndexPathFromTag:(NSInteger)tag{
    /* To get indexPath from textfeidl tag,
     TextField tag set = (indexPath.row +1) + (indexPath.section*100) */
    int row =0;
    int section =0;
    for (int i =100; i<tag; i=i+100) {
        section++;
    }
    row = tag - (section*100);
    row-=1;
    return  [NSIndexPath indexPathForRow:row inSection:section];
    
}

-(void)showName:(UIButton*)button{
    
    globalIndexPath = [self getIndexPathFromTag:button.tag];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:@"Are you sure you want to delete this audit" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
    
    
}


- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1){
        
        int section = (int)globalIndexPath.section;
        
        NSMutableDictionary* audit = [[NSMutableDictionary alloc] init];
        
        audit = [[[auditContentSortedArr objectAtIndex:section] valueForKey:@"AuditArr"] objectAtIndex:globalIndexPath.row];
        
        [[DataManager sharedManager] deleteAllAuditImagesWithAuditId:[audit valueForKey:@"auditId"]];
        [[DataManager sharedManager] deleteAuditWithId:[audit valueForKey:@"auditId"]];
        
        
        [[[auditContentSortedArr objectAtIndex:section] valueForKey:@"AuditArr"] removeObjectAtIndex:globalIndexPath.row];
        
        
        [self.tblView reloadData];
        
        
    }
}


#pragma mark - UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isKindOfClass:[UICollectionView class]]) return;
    
    CGFloat horizontalOffset = scrollView.contentOffset.x;
    
    UICollectionView *collectionView = (UICollectionView *)scrollView;
    NSInteger index = collectionView.tag;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}

- (IBAction)addAuditsButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"addMoreAuditsSegue" sender:nil];
}

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"scrollPushSegue"]) {
        
        ScrollAuditImageViewController* controller = [segue destinationViewController];
        
        
        NSMutableArray* tmpArr = [[NSMutableArray alloc] init];
        tmpArr = [[auditContentSortedArr objectAtIndex:selectedIndex.section] valueForKey:@"AuditArr"];
        
        NSMutableArray* tmpImgArr = [[NSMutableArray alloc] init];
        
        for (int i = 0; i<tmpArr.count; i++) {
            
            NSMutableDictionary* tmpDict = [tmpArr objectAtIndex:i];
            [tmpImgArr addObject:[[DataManager sharedManager] loadAuditImagewithPath:[tmpDict valueForKey:@"imgURL"]]];
            
        }
        
        [controller setAuditContentArr:tmpArr];
        [controller setAuditImgArr:tmpImgArr];
        
        
        [controller setSelectedIndex:selectedIndex.row];
        
    }
    if ([segue.identifier isEqualToString:@"addMoreAuditsSegue"]) {
        
        AddAuditViewController* auditController = [segue destinationViewController];
        auditController.currentAssetId = assetObj.assetId;
        auditController.currentAssetName = assetObj.assetName;
        auditController.assetObj = assetObj;
        auditController.isAssetToBeUpdated = false;
        
        auditController.tmpAuditDataArr = auditContentSortedArr;
        auditController.isMoreAuditAdded = true;
        
    }
    
}

@end
