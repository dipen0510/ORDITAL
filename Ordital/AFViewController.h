//
//  AFViewController.h
//  AFTabledCollectionView
//
//  Created by Ash Furrow on 2013-03-14.
//  Copyright (c) 2013 Ash Furrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AFViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate> {
    NSMutableArray* auditContentArr;
    NSMutableArray* auditImageArr;
    NSIndexPath* selectedIndex;
    NSMutableArray* equipmentArr;
    NSMutableArray* tagArr;
    NSMutableArray* nameplateArr;
    NSMutableArray* serviceArr;
    NSMutableArray* vendorArr;
    NSMutableArray* inspectionArr;
    
    NSMutableArray* equipmentArr1;
    NSMutableArray* tagArr1;
    NSMutableArray* nameplateArr1;
    NSMutableArray* serviceArr1;
    NSMutableArray* vendorArr1;
    NSMutableArray* inspectionArr1;
    
    
    NSIndexPath *globalIndexPath;
    
    NSMutableArray* sectionArr;
    NSMutableArray* auditContentSortedArr;
    
}

@property NSString* currentAssetId;
@property (nonatomic, strong) AssetData* assetObj;
@property (weak, nonatomic) IBOutlet UITableView *tblView;

- (IBAction)addAuditsButtonTapped:(id)sender;
- (IBAction)backButtonTapped:(id)sender;

@end
