//
//  AuditData.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 21/09/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuditData : NSObject

@property NSString* auditId;
@property NSString* assetId;
@property NSString* assetName;
@property NSString* auditType;
@property NSString* imgURL;
@property NSString* dateTime;
@property double latitude;
@property double longitude;
@property double altitude;
@property UIImage* auditImg;
@property BOOL isUploaded;

@end
