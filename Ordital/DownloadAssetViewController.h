//
//  DownloadAssetViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 23/09/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadAssetViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>{
    NSArray *assetFieldArr;
    NSMutableArray *cellSelected;
    UIPickerView *picker;
    NSMutableDictionary* selectedPickerContent;
}

@property (strong, nonatomic) IBOutlet UITextField *assetSetLabel;
@property (strong, nonatomic) IBOutlet UITableView *assetTableView;
@property (strong, nonatomic) NSMutableArray *assetContentArr;
- (IBAction)downloadTapped:(id)sender;
@end
