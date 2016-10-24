//
//  SetListViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 30/11/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate> {
    NSMutableArray *nameContentArr;
    NSMutableArray *descriptionContentArr;
}

@property (weak, nonatomic) IBOutlet UITableView *setListTblView;
@property (strong, nonatomic) NSMutableArray* downloadedSetContent;
@property (weak, nonatomic) IBOutlet UILabel *listCountLbl;
- (IBAction)backButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *listsLabel;
@property (weak, nonatomic) IBOutlet UINavigationItem *locationListTitle;
@end
