//
//  SettingsListViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 30/10/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>


@interface SettingsListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,DBRestClientDelegate> {
    NSMutableArray* contentArr1;
    NSMutableArray* contentArr2;
    NSMutableArray* contentArr3;
    NSMutableArray* sectionContentArr;
    NSString* status;
    NSString* errMsg;
    int err;
    int currentSavingIndex;
    
     NSMutableArray* imgArr;

}
@property (weak, nonatomic) IBOutlet UITableView *settingListTableView;

- (void) saveImagesInPhotoLibrary;


@end
