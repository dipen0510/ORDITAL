//
//  PreviewPendingAuditsViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 01/01/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreviewPendingAuditsViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIAlertViewDelegate,NSURLSessionDelegate> {
    NSMutableArray* auditContentArr;
    NSMutableArray* auditImageArr;
    NSInteger selectedIndex;
    NSMutableArray* auditArr;
    int uploadCounter;
}


@property (weak, nonatomic) IBOutlet UIButton *resyncButton;
@property (strong, nonatomic) IBOutlet UICollectionView *auditCollectionView;

- (IBAction)backButtonTapped:(id)sender;
- (IBAction)purgeButtonTapped:(id)sender;

@end
