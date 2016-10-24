//
//  ScrollAuditImageViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria  on 10/4/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "ScrollAuditImageViewController.h"
#import "DataManager.h"
#import "SVProgressHUD.h"

@interface ScrollAuditImageViewController ()
@property (nonatomic, strong) NSArray *pageImages;
@property (nonatomic, strong) NSMutableArray *pageViews;

- (void)loadVisiblePages;
- (void)loadPage:(NSInteger)page;
- (void)purgePage:(NSInteger)page;
@end

@implementation ScrollAuditImageViewController

@synthesize auditScrollView = _auditScrollView;
@synthesize auditPageControl = _auditPageControl;

@synthesize auditContentArr,auditImgArr,selectedIndex;

@synthesize pageImages = _pageImages;
@synthesize pageViews = _pageViews;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) addPinchZoomToImageView: (UIImageView *)imgView {
    
    
    self.auditScrollView.minimumZoomScale = 1.0;
    self.auditScrollView.maximumZoomScale = 4.0f;
    self.auditScrollView.zoomScale = 1.0;
    
    [self centerScrollViewContents];
    
}


#pragma mark -

- (void)loadVisiblePages {
    // First, determine which page is currently visible
    CGFloat pageWidth = self.auditScrollView.frame.size.width;
    NSInteger page = (NSInteger)floor((self.auditScrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    
    currentPageIndex = (int)page;
    
    // Update the page control
    self.auditPageControl.currentPage = page;
    self.title = [[auditContentArr objectAtIndex:page] valueForKey:@"auditType"];
    
    // Work out which pages we want to load
    NSInteger firstPage = page - 1;
    NSInteger lastPage = page + 1;
    
    // Purge anything before the first page
    for (NSInteger i=0; i<firstPage; i++) {
        [self purgePage:i];
    }
    for (NSInteger i=firstPage; i<=lastPage; i++) {
        [self loadPage:i];
    }
    for (NSInteger i=lastPage+1; i<self.pageImages.count; i++) {
        [self purgePage:i];
    }
}

- (void)loadPage:(NSInteger)page {
    if (page < 0 || page >= self.pageImages.count) {
        // If it's outside the range of what we have to display, then do nothing
        return;
    }
    
    // Load an individual page, first seeing if we've already loaded it
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {
        CGRect frame = self.auditScrollView.bounds;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0.0f;
        
        UIImageView *newPageView = [[UIImageView alloc] initWithImage:[self.pageImages objectAtIndex:page]];
        newPageView.contentMode = UIViewContentModeScaleToFill;
        newPageView.frame = frame;
        [self.auditScrollView addSubview:newPageView];
        
        
       //[self addPinchZoomToImageView:newPageView];
        
        
        
        [self.pageViews replaceObjectAtIndex:page withObject:newPageView];
    }
}

- (void)purgePage:(NSInteger)page {
    if (page < 0 || page >= self.pageImages.count) {
        // If it's outside the range of what we have to display, then do nothing
        return;
    }
    
    // Remove a page from the scroll view and reset the container array
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView != [NSNull null]) {
        [pageView removeFromSuperview];
        [self.pageViews replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}

-(void) scrollToPage {
    CGRect frame = self.auditScrollView.frame;
    frame.origin.x = frame.size.width * selectedIndex;
    frame.origin.y = 0;
    [self.auditScrollView scrollRectToVisible:frame animated:YES];
    selectedIndex = 0;
}

-(void) setupScrollViewAttributes {
    
    self.title = @"Paged";
    
    // Set up the image we want to scroll & zoom and add it to the scroll view
    self.pageImages = auditImgArr;
    
    NSInteger pageCount = self.pageImages.count;
    
    // Set up the page control
    self.auditPageControl.currentPage = 0;
    self.auditPageControl.numberOfPages = pageCount;
    
    // Set up the array to hold the views for each page
    self.pageViews = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < pageCount; ++i) {
        [self.pageViews addObject:[NSNull null]];
    }
    
    // Set up the content size of the scroll view
    CGSize pagesScrollViewSize = self.auditScrollView.frame.size;
    self.auditScrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * self.pageImages.count, pagesScrollViewSize.height);
    
    // Load the initial set of pages that are on screen
    [self loadVisiblePages];
    
    [self scrollToPage];

}


#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupScrollViewAttributes];
    self.navigationController.navigationBarHidden = false;
    
    [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nCurrent Screen - %@",[self.navigationController.viewControllers lastObject]]]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
    
//    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
//    doubleTapRecognizer.numberOfTapsRequired = 2;
//    doubleTapRecognizer.numberOfTouchesRequired = 1;
//    [self.auditScrollView addGestureRecognizer:doubleTapRecognizer];
//    
//    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
//    twoFingerTapRecognizer.numberOfTapsRequired = 1;
//    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
//    [self.auditScrollView addGestureRecognizer:twoFingerTapRecognizer];

}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.auditScrollView = nil;
    self.auditPageControl = nil;
    self.pageImages = nil;
    self.pageViews = nil;
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.auditScrollView setDelegate:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Load the pages which are now on screen
    self.auditScrollView.contentOffset = CGPointMake(self.auditScrollView.contentOffset.x, 0);
    [self loadVisiblePages];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)deleteButtonTapped:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:@"Are you sure you want to delete this audit" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1){
        if (self.auditPageControl.currentPage == 0) {
            selectedIndex = 0;
        }
        else {
            selectedIndex = self.auditPageControl.currentPage-1;
        }
        NSString* auditIdToDelete = [[auditContentArr objectAtIndex:self.auditPageControl.currentPage] valueForKey:@"auditId"];
        //NSString* assetIdToDelete = [[auditContentArr objectAtIndex:self.auditPageControl.currentPage] valueForKey:@"assetId"];
        [SVProgressHUD showWithStatus:@"Deleting Audit" maskType:SVProgressHUDMaskTypeGradient];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [[DataManager sharedManager] deleteAllAuditImagesWithAuditId:auditIdToDelete];
            [[DataManager sharedManager] deleteAuditWithId:auditIdToDelete];
            [auditImgArr removeObjectAtIndex:self.auditPageControl.currentPage];
            [auditContentArr removeObjectAtIndex:self.auditPageControl.currentPage];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                if ([auditImgArr count]>0) {
                    [self setupScrollViewAttributes];
                }
                else {
                    //[[DataManager sharedManager] deleteAssetWithId:assetIdToDelete];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
                
            });
        });
    }
}




#pragma mark - ScrollView

- (void)centerScrollViewContents {
    
    UIImageView* photView = [self.pageViews objectAtIndex:currentPageIndex];
    
    CGSize boundsSize = self.auditScrollView.bounds.size;
    CGRect contentsFrame = photView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    photView.frame = contentsFrame;
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    // Get the location within the image view where we tapped
    
    UIImageView* photView = [self.pageViews objectAtIndex:currentPageIndex];
    
    CGPoint pointInView = [recognizer locationInView:photView];
    
    // Get a zoom scale that's zoomed in slightly, capped at the maximum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.auditScrollView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.auditScrollView.maximumZoomScale);
    
    // Figure out the rect we want to zoom to, then zoom to it
    CGSize scrollViewSize = self.auditScrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    [self.auditScrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.auditScrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.auditScrollView.minimumZoomScale);
    [self.auditScrollView setZoomScale:newZoomScale animated:YES];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    UIImageView* photView = [self.pageViews objectAtIndex:currentPageIndex];
    return photView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}
@end
