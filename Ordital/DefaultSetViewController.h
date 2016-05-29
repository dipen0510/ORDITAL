//
//  DefaultSetViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 21/10/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DefaultSetViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate> {
    NSMutableArray *nameContentArr;
    NSMutableArray *descriptionContentArr;
    NSMutableArray *searchContentArr;
    
    NSString* status;
    NSString* errMsg;
    NSMutableArray* downloadedSetContent;
    NSMutableArray* downloadedSetListContent;
    
    UIBarButtonItem* navigation;
}


@property (weak, nonatomic) IBOutlet UISearchBar *assetSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;

- (IBAction)backButtonTapped:(id)sender;
- (IBAction)showListsTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *listountLbl;
@property (weak, nonatomic) IBOutlet UINavigationItem *searchLocationTitle;

@end
