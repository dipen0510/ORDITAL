//
//  PendingAuditFullScreenViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 31/05/16.
//  Copyright © 2016 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PendingAuditFullScreenViewController : UIViewController<UIScrollViewDelegate> {
    CGPoint center;
    int currentPageIndex;
}
@property (weak, nonatomic) IBOutlet UIScrollView *auditScrollView;
- (IBAction)deleteButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIPageControl *auditPageControl;

@property (strong, nonatomic) NSMutableArray* auditContentArr;
@property (strong, nonatomic) NSMutableArray* auditImgArr;
@property NSInteger selectedIndex;

@end
