//
//  ScrollAuditImageViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria  on 10/4/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollAuditImageViewController : UIViewController<UIScrollViewDelegate> {
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
