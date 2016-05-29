//
//  AssetData.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 20/09/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AssetData : NSObject

@property NSString* assetId;
@property NSString* assetName;
@property NSString* plantName;
@property NSString* description;
@property NSString* tag;
@property NSString* plantId;
@property NSString* parent;
@property NSString* type;
@property NSString* parentId;
@property BOOL isNewAsset;
@property BOOL unableToLocate;
@property NSString* condition;
@property NSString* operatorType;
@property NSString* operatorClass;
@property NSString* operatorClassId;
@property NSString* operatorSubclass;
@property NSString* operatorSubclassId;
@property NSString* category;
@property NSString* categoryId;

@end
