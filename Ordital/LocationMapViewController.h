//
//  LocationMapViewController.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 19/10/16.
//  Copyright © 2016 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LocationMapViewController : UIViewController

@property (strong, nonatomic) AssetData* assetToUpdate;

- (IBAction)backButtonTapped:(id)sender;

@end
