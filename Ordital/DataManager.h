//
//  DataManager.h
//  Ordital
//
//  Created by Dipen Sekhsaria on 23/09/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "AssetData.h"
#import "AuditData.h"

FOUNDATION_EXPORT NSString* const SANDOBOX_LOGIN_URL;
FOUNDATION_EXPORT NSString* const SANDOBOX_REST_URL;
FOUNDATION_EXPORT NSString* const PRODUCTION_LOGIN_URL;
FOUNDATION_EXPORT NSString* const PRODUCTION_REST_URL;

FOUNDATION_EXPORT NSString* const HEADER_REQUEST_VALUE;
FOUNDATION_EXPORT NSString* const HEADER_REQUEST_KEY;

FOUNDATION_EXPORT NSString* const StartUploadingAuditImages;

FOUNDATION_EXPORT NSString* const kEnvironmentURL;

@interface DataManager : NSObject

@property (strong, nonatomic) NSString *databasePath;
@property (strong, nonatomic) NSString *auditImagePath;
@property BOOL isLoggedIn;
@property (strong, nonatomic) NSMutableDictionary* selectedPlantSettings;
@property (strong, nonatomic) NSString* selectedEnvironmentSettings;

@property (strong, nonatomic) NSString* selectedConnectionSettings;

@property (strong, nonatomic) NSString* selectedTypeSettings;
@property int isFindAssetToBeOpened;
@property BOOL restEnv;
@property BOOL isAuditUploadInProgress;

@property (strong, nonatomic) NSString* tmpParentId;
@property (strong, nonatomic) NSString* tmpParentName;

@property (strong, nonatomic) NSString* logsString;

@property (strong, nonatomic) NSString* plantSectionFilter;
@property (strong, nonatomic) NSString* systemFilter;
@property (strong, nonatomic) NSString* criticalityFilter;
@property (strong, nonatomic) NSString* sourceDocFilter;

+ sharedManager;

-(NSString*)getJsonStringForSyncUpdatesWithAsset:(AssetData *)asset;
-(NSString*)getJsonStringForSyncNotes;
-(NSString*)getJsonStringForSyncNotesWithId:(NSString *)assetId andNote:(NSString *)note;
-(BOOL)isInternetConnectionAvailable;
- (void)saveAuditImage: (UIImage*)image withName: (NSString *)name;
- (UIImage*)loadAuditImagewithName: (NSString *)name;
- (UIImage*)loadAuditImagewithPath: (NSString *)path;
-(void)setupDatabase;
- (void) saveAssetData:(AssetData *)assetData withUpdate:(BOOL)update;
- (void) saveOnlyAssetData:(AssetData *)assetData;
- (NSMutableArray *) getAssetData;
- (void) saveAuditData:(AuditData *)auditData;
- (int) getAuditDataCount;
- (NSMutableArray *) getAuditDataForAssetId:(NSString *)tmpAssetId;
- (NSMutableArray *) getAllAuditImagePath;
- (void) saveAuthToken:(NSString *)token withInstanceURL:(NSString *)instanceURL withIdentity:(NSString *)identity withBucket:(NSString *)bucket andUsername:(NSString *)username;
- (NSString *) getAuthToken;
- (NSString *) getInstanceURL;
- (NSString *) getIdentity;
- (NSString *) getBucket;
- (void) deleteAuthToken;
- (void) deleteAllAssetsAndAudits;
- (void)deleteAllSavedAuditImages;
- (void)deleteAllAuditImagesWithAssetId:(NSString *) assetId ;
- (void)deleteAllAuditImagesWithAuditId:(NSString *) auditId;
- (void) saveDownloadData:(NSMutableDictionary *)downloadDict;
- (void) deleteAllDownloadsData;
- (NSMutableArray *) getAllAssetsToBeSynced;
- (NSMutableArray *) getAllAuditsToBeSyncedForAssetId:(NSString* )assetId;
- (NSMutableArray *) getAllAssetsForOfflineTextWithAuditUncompleted:(NSString* )offlineText;
- (void) savePlantDetailsWithId:(NSString *)plantId withName:(NSString *)plantName andOperatingUnit:(NSString *)opName;
- (NSMutableDictionary *) getSelectedPlantDetails;
- (void) deleteAssetWithId:(NSString *)assetid;
- (void) saveEnvironmentDetailsWithName:(NSString *)name;
- (NSString *) getSelectedEnvironmentDetails;
- (void) deleteAuditWithId:(NSString *)auditId;
- (void) deletePlantDetails;
- (void) saveNoteTypeDetailsWithId:(NSString *)assetId withNote:(NSString *)noteType;
- (NSMutableArray *) getNoteTypeForAssetId:(NSString *)tmpAssetId;
- (void) deleteNoteWithId:(NSString *)assetid ;
- (NSMutableArray *) getAllNoteType;
- (void) deleteAllNotes;
- (void) saveImQualityWithValue:(NSString *)val;
- (NSString *) getSelectedImgQuality;
- (void) saveTypeDetailsWithName:(NSString *)name;
- (NSString *) getSelectedTypeDetails;
- (void) savePlantSectionDetailsWithName:(NSString *)name;
- (NSString *) getSelectedPlantSectionDetails;
- (void) saveSystemDetailsWithName:(NSString *)name;
- (NSString *) getSelectedSystemDetails;
- (NSMutableArray *) getAllChildrenForAssetId:(NSString* )assetId;
- (NSMutableDictionary *) getAllParentForAssetId:(NSString* )assetId;
- (void) saveSelectedSetDetailsWithName:(NSString *)name andSetId:(NSString *)setId;
- (NSMutableDictionary *) getSelectedSetDetails;
- (NSMutableDictionary *) getAllDownloadedAssetsWithAuditUncompleted;
- (NSMutableDictionary *) getAllDownloadedAssetsWithAuditCompleted;
- (NSMutableArray *) getAllAssetsForOfflineTextWithAuditCompleted:(NSString* )offlineText;
/*- (void) saveIACDetailsWithName:(NSString *)name;
- (NSString *) getSelectedIACDetails;*/
- (void) saveIsSearchOnSetWithValue:(BOOL)val;
- (BOOL) getIsSearchOnSetDetails;
- (void) saveOperatorTypeDetailsWithValue:(NSString *)value andDescription:(NSString *)desc;
- (NSMutableArray *) getSelectedOpearatorTypeDetails;
- (void) deleteOperatorTypeDetails;
- (void) saveCriticalityDetailsWithName:(NSString *)name;
- (NSString *) getSelectedCriticalityDetails;
- (void) saveSourceDocsDetailsWithName:(NSString *)name;
- (NSString *) getSelectedSourceDocsDetails;
- (void) deleteOnlyAssetWithId:(NSString *)assetid;
- (int) getAssetDataCount;
- (NSMutableArray *) getPendingAuditData;
- (NSString* )convertImageToString:(UIImage *)img;
- (void) saveSyncRecordsWithValue:(BOOL)val;
- (BOOL) getSyncRecordsDetails;
-(NSMutableArray *) getAllTodayAssets;
- (NSMutableArray *) getAllAuditData;
- (void) saveConditionsWithValue:(NSString *)val andDescription:(NSString *)desc;
- (NSMutableArray *) getConditionsDetails;
- (void) deleteConditionsDetails;
- (void) saveTodayAssets:(NSMutableArray *)downloadDict;
- (NSMutableArray *) getOfflineTodayDetails;
- (void) deleteTodayDetails;
- (void) saveOperatorClassWithValue:(NSString *)val andDescription:(NSString *)desc andID:(NSString *)ident andClass:(NSString *)class1;
- (NSMutableArray *) getOperatorClassDetails;
- (void) deleteOperatorClassDetails;
- (void) saveOperatorSubclassWithValue:(NSString *)val andDescription:(NSString *)desc andId:(NSString *)ident;
- (NSMutableArray *) getOperatorSubclassDetails;
- (void) deleteOperatorSubclassDetails;
- (void) saveAssetCodingOptionsForCondition:(BOOL)con andOperatorType:(BOOL)opType andOperatorClass:(BOOL)opClass andOperatorSubclass:(BOOL)opSub andCategory:(BOOL)category andType:(BOOL)type;
- (NSMutableArray *) getAssetCodingOptions;

// v5.0

- (void) saveSeletedConnectionDetailsWithName:(NSString *)name;
- (NSString *) getSelectedConnectionDetails;
- (void) deleteSelectedConnectionDetails;

- (NSMutableArray *) getAllAssetsForOfflineTextinStandaloneMode:(NSString* )offlineText;
- (AssetData *) getAssetDataForAssetId:(NSString *)tmpAssetId;
- (int) getDownloadDataCount;

- (void) saveLockRecordsWithValue:(BOOL)val;
- (BOOL) getLockRecordsDetails;
- (void) deleteLockcRecordsDetails;

- (void) savePunchListWithValue:(BOOL)val;
- (BOOL) getPunchListDetails;
- (void) deletePunchListDetails;

- (void) saveCategoryWithValue:(NSString *)val andId:(NSString *)ident andCategory:(NSString *)category;
- (NSMutableArray *) getCategoryDetails;
- (void) deleteCategoryDetails;

- (int) getDownloadDataCountForPunchList;

- (void) saveForceOfflineWithValue:(BOOL)val;
- (BOOL) getForceOfflineDetails;
- (void) deleteForceOfflineDetails;

- (void) saveAssetCountWithToday:(NSString *)today andTODO:(NSString *)todo andDone:(NSString *)done;
- (NSMutableDictionary *) getAssetCountDetails;
- (void) deleteAssetCountDetails;


- (void) saveAuditTypeForId:(NSString *)auditId andName:(NSString *)name andOrder:(NSString *)order;
- (NSMutableArray *) getAllAuditTypes;
- (void) deleteAuditTypeDetails;
- (void) addDefaultAuditTypeValuesToDB;

- (void) saveDynamicLabelValues:(NSMutableDictionary *)responseDict;
- (NSMutableDictionary *) getAllDynamicLabelValues;
- (void) deleteDynamicLabelValues;

- (void) updateUploadStatusForAuditId:(NSString *)auditId;
- (void) updateUploadStatusForAssetId:(NSString *)assetId;

- (NSString *) getUsername;
- (NSMutableArray *) getCompletedAuditData;

@end
