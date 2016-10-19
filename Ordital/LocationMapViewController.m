//
//  LocationMapViewController.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 19/10/16.
//  Copyright © 2016 Home. All rights reserved.
//

#import "LocationMapViewController.h"

@interface LocationMapViewController ()

@end

@implementation LocationMapViewController

@synthesize assetToUpdate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (assetToUpdate.latitude && assetToUpdate.longitude && ([assetToUpdate.latitude floatValue]<=90 && [assetToUpdate.latitude floatValue]>=-90) && ([assetToUpdate.longitude floatValue]<=180 && [assetToUpdate.longitude floatValue]>=-180)) {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([assetToUpdate.latitude floatValue], [assetToUpdate.longitude floatValue]);
        
        MKCoordinateSpan span = MKCoordinateSpanMake(10.0, 10.0);
        MKCoordinateRegion region = {coord, span};
        
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:coord];
        
        [self.myMapView setRegion:region];
        [self.myMapView addAnnotation:annotation];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
