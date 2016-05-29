//
//  PreviewAuditViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria  on 10/2/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetData.h"

@interface PreviewAuditViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout> {
     NSMutableArray* auditContentArr;
    NSMutableArray* auditImageArr;
    NSInteger selectedIndex;
}
@property (weak, nonatomic) IBOutlet UICollectionView *auditCollectionView;
@property NSString* currentAssetId;
@property (nonatomic, strong) AssetData* assetObj;

@end
