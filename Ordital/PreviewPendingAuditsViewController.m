//
//  PreviewPendingAuditsViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 01/01/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import "PreviewPendingAuditsViewController.h"
#import "DataManager.h"
#import "PendingAuditFullScreenViewController.h"

@interface PreviewPendingAuditsViewController ()

@end

@implementation PreviewPendingAuditsViewController

@synthesize auditCollectionView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    auditContentArr = [[NSMutableArray alloc] init];
    auditImageArr = [[NSMutableArray alloc] init];
    auditContentArr = [[DataManager sharedManager] getAllAuditData];
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
    static NSString *identifier = @"pendingAuditPreviewCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
    recipeImageView.image = [auditImageArr objectAtIndex:indexPath.row];
    
    UIImageView *uploadImageView = (UIImageView *)[cell viewWithTag:101];
    
    AuditData* audit = [[AuditData alloc] init];
    audit = [auditContentArr objectAtIndex:indexPath.row];
    
    if (audit.isUploaded) {
        uploadImageView.hidden = NO;
    }
    else {
        uploadImageView.hidden = YES;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    selectedIndex = indexPath.row;
    
    [self performSegueWithIdentifier:@"showFullScreenView" sender:nil];
    
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"showFullScreenView"]) {
        
        PendingAuditFullScreenViewController* controller = [segue destinationViewController];
        
        
        [controller setAuditContentArr:auditContentArr];
        [controller setAuditImgArr:auditImageArr];
        
        
        [controller setSelectedIndex:selectedIndex];
        
    }
    
}


- (IBAction)backButtonTapped:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
@end
