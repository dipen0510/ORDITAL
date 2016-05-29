//
//  ChildrenListViewController.h
//  Ordital
//
//  Created by Dhruv  on 10/17/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChildrenListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate> {
    NSMutableArray *nameContentArr;
    NSMutableArray *descriptionContentArr;
    int selectedIndex;
    NSMutableArray* scrollAssetContentArr;
}

@property (weak, nonatomic) IBOutlet UITableView *childrenListTblView;
@property (strong, nonatomic) NSMutableArray *searchContentArr;
@property BOOL isInternetActive;
- (IBAction)backButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *childrenListCountLbl;

@end
