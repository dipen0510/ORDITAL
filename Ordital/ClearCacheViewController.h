//
//  ClearCacheViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 30/10/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClearCacheViewController : UIViewController<UITableViewDataSource,UITableViewDelegate> {
    NSArray *cacheFieldArr;
    NSMutableArray *cellSelected;
}

- (IBAction)clearCacheButtonTapped:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *cacheOptionsTableView;
- (IBAction)backButtonTapped:(id)sender;

@end
