//
//  PreviewPendingAuditsViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 01/01/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreviewPendingAuditsViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout> {
    NSMutableArray* auditContentArr;
    NSMutableArray* auditImageArr;
    NSInteger selectedIndex;
}


@property (strong, nonatomic) IBOutlet UICollectionView *auditCollectionView;
- (IBAction)backButtonTapped:(id)sender;

@end
