//
//  PreviewAuditViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria  on 10/2/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "PreviewAuditViewController.h"
#import "DataManager.h"
#import "ScrollAuditImageViewController.h"
#import "AddAuditViewController.h"

@interface PreviewAuditViewController ()

@end

@implementation PreviewAuditViewController

@synthesize auditCollectionView,currentAssetId,assetObj;

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
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Add Audits"
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(addAuditButtonTapped:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    auditContentArr = [[NSMutableArray alloc] init];
    auditImageArr = [[NSMutableArray alloc] init];
    auditContentArr = [[DataManager sharedManager] getAllAuditsToBeSyncedForAssetId:currentAssetId];
    for (int i = 0; i<[auditContentArr count]; i++) {
        NSDictionary* currentAudit = [auditContentArr objectAtIndex:i];
        [auditImageArr addObject:[[DataManager sharedManager] loadAuditImagewithPath:[currentAudit valueForKey:@"imgURL"]]];
    }
    [auditCollectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [auditImageArr count];
}
// 2

// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"auditPreviewCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
    recipeImageView.image = [auditImageArr objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
   selectedIndex = indexPath.row;
    NSLog(@"Selected Index %ld",(long)selectedIndex);
   // [self performSegueWithIdentifier:@"detailViewPushSegue" sender:nil];*/
    [self performSegueWithIdentifier:@"scrollPushSegue" sender:nil];
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

-(void)addAuditButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"addMoreAuditsSegue" sender:nil];
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"scrollPushSegue"]) {
        
        ScrollAuditImageViewController* controller = [segue destinationViewController];
        [controller setAuditContentArr:auditContentArr];
        [controller setAuditImgArr:auditImageArr];
        [controller setSelectedIndex:selectedIndex];
        
    }
    if ([segue.identifier isEqualToString:@"addMoreAuditsSegue"]) {
        
        AddAuditViewController* auditController = [segue destinationViewController];
        auditController.currentAssetId = assetObj.assetId;
        auditController.currentAssetName = assetObj.assetName;
        auditController.assetObj = assetObj;
        auditController.isAssetToBeUpdated = false;
        
    }
    
}


@end
