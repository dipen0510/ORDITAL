//
//  DataManager.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 23/09/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "DataManager.h"
#import "Reachability.h"
#import "AssetData.h"

NSString* const SANDOBOX_LOGIN_URL = @"https://pics.ordital.com/Dev/API/oauth.php?community=";
NSString* const SANDOBOX_REST_URL = @"https://pics.ordital.com/Dev/API/5.0.0/sfdc_upload.php";
NSString* const PRODUCTION_LOGIN_URL = @"https://pics.ordital.com/Live/API/oauth.php?community=";
NSString* const PRODUCTION_REST_URL = @"https://pics.ordital.com/Live/API/6.0.0/sfdc_upload.php";

NSString* const HEADER_REQUEST_VALUE = @"959e8a4343df32234qwe3erfkjuy35b98e079fc2540d7yuhggte543bdvsfrwwjskdga5d454e67e";
NSString* const HEADER_REQUEST_KEY = @"validate-header";


NSString* const StartUploadingAuditImages = @"StartUploadingAuditImages";
NSString* const kEnvironmentURL = @"";//@"testingapp-ordital.cs6.force.com";

@implementation DataManager

const char *create_authToken_table =
"CREATE TABLE IF NOT EXISTS AUTHTOKEN (token TEXT PRIMARY KEY, instanceURL TEXT, identity TEXT, bucket TEXT, username TEXT)";
const char *create_plant_table =
"CREATE TABLE IF NOT EXISTS SELECTEDPLANT (plantId TEXT PRIMARY KEY, plantName TEXT, operatingName TEXT)";
const char *create_asset_table =
"CREATE TABLE IF NOT EXISTS ASSETS (assetId TEXT PRIMARY KEY, assetName TEXT, plantName TEXT, description TEXT, tag TEXT, plantId TEXT, parent TEXT, type TEXT, isNewAsset TINYINT, parentId TEXT, createdDate TEXT, condition TEXT, operatorType TEXT, operatorClass TEXT, operatorClassId TEXT, category TEXT, categoryId TEXT, operatorSubclass TEXT, operatorSubclassId TEXT, unableToLocate TINYINT, uploaded TINYINT)";
const char *create_audit_table =
"CREATE TABLE IF NOT EXISTS AUDITS (auditId TEXT PRIMARY KEY, assetId TEXT, assetName TEXT, auditType TEXT, imgURL TEXT, dateTime TEXT, latitude REAL, longitude REAL, altitude REAL, uploaded TINYINT)";
const char *create_download_table =
"CREATE TABLE IF NOT EXISTS DOWNLOADS (assetId TEXT PRIMARY KEY, assetName TEXT, plantName TEXT, description TEXT, tag TEXT, plantId TEXT, parentId TEXT, parentName TEXT, isAuditCompleted TEXT, make TEXT, type TEXT, unableToLocate TINYINT, plantSection TEXT, system TEXT, operatorType TEXT, criticality TEXT, sourceDocs TEXT, condition TEXT, operatorClass TEXT, operatorClassId TEXT, category TEXT, categoryId TEXT, operatorSubclass TEXT, operatorSubclassId TEXT, punchList TEXT, locationList TEXT, sequence TEXT)";
const char *create_environment_table =
"CREATE TABLE IF NOT EXISTS SELECTEDENVIRONMENT (name TEXT PRIMARY KEY)";
const char *create_notetype_table =
"CREATE TABLE IF NOT EXISTS NOTETYPE (assetId TEXT, notetype TEXT)";
const char *create_imgQuality_table =
"CREATE TABLE IF NOT EXISTS IMGQUALITY (value TEXT PRIMARY KEY)";
const char *create_typeSettings_table =
"CREATE TABLE IF NOT EXISTS SELECTEDTYPE (type TEXT PRIMARY KEY)";
const char *create_plantSection_table =
"CREATE TABLE IF NOT EXISTS PLANTSECTION (name TEXT PRIMARY KEY)";
const char *create_system_table =
"CREATE TABLE IF NOT EXISTS SYSTEM (name TEXT PRIMARY KEY)";
const char *create_selectedSet_table =
"CREATE TABLE IF NOT EXISTS SELECTEDSET (setId TEXT PRIMARY KEY, setName TEXT)";
/*const char *create_selectedIacValue_table =
"CREATE TABLE IF NOT EXISTS SELECTEDIAC (name TEXT PRIMARY KEY)";*/
const char *create_isSearchOnSet_table =
"CREATE TABLE IF NOT EXISTS ISSEARCHONSET (name TINYINT PRIMARY KEY)";
const char *create_criticality_table =
"CREATE TABLE IF NOT EXISTS CRITICALITY (name TEXT PRIMARY KEY)";
const char *create_sourceDocs_table =
"CREATE TABLE IF NOT EXISTS SOURCEDOCS (name TEXT PRIMARY KEY)";
const char *create_syncRecords_table =
"CREATE TABLE IF NOT EXISTS SYNCRECORDS (name TINYINT PRIMARY KEY)";
const char *create_conditions_table =
"CREATE TABLE IF NOT EXISTS CONDITIONS (value TEXT PRIMARY KEY, description TEXT)";
const char *create_operatorType_table =
"CREATE TABLE IF NOT EXISTS OPERATORTYPE (value TEXT PRIMARY KEY, description TEXT)";
const char *create_operatorClass_table =
"CREATE TABLE IF NOT EXISTS OPERATORCLASS (value TEXT, parentValue TEXT, class TEXT, id TEXT PRIMARY KEY)";
const char *create_operatorSubclass_table =
"CREATE TABLE IF NOT EXISTS OPERATORSUBCLASS (value TEXT, parentValue TEXT, id TEXT PRIMARY KEY)";
const char *create_category_table =
"CREATE TABLE IF NOT EXISTS CATEGORY (value TEXT, category TEXT, id TEXT PRIMARY KEY)";
const char *create_today_table =
"CREATE TABLE IF NOT EXISTS TODAY (assetId TEXT PRIMARY KEY, assetName TEXT, plantName TEXT, description TEXT, tag TEXT, plantId TEXT, parentId TEXT, parentName TEXT, make TEXT, type TEXT, unableToLocate TINYINT, condition TEXT, iPhoneAssetId TEXT, operatorType TEXT, operatorClass TEXT, operatorClassId TEXT, category TEXT, categoryId TEXT, operatorSubclass TEXT, operatorSubclassId TEXT)";
const char *create_assetCoding_table =
"CREATE TABLE IF NOT EXISTS ASSETCODING (condition TINYINT, operatorType TINYINT, operatorClass TINYINT, operatorSubclass TINYINT, category TINYINT, type TINYINT)";

//v5.0 changes

const char *create_selectedConnection_table =
"CREATE TABLE IF NOT EXISTS SELECTEDCONNECTION (name TEXT PRIMARY KEY)";
const char *create_lockExistingRecords_table =
"CREATE TABLE IF NOT EXISTS LOCKRECORDS (name TINYINT PRIMARY KEY)";
const char *create_searchOnlyInPuchList_table =
"CREATE TABLE IF NOT EXISTS SEARCHPUNCHLIST (name TINYINT PRIMARY KEY)";
const char *create_forceOfflineMode_table =
"CREATE TABLE IF NOT EXISTS FORCEOFFLINE (name TINYINT PRIMARY KEY)";
const char *create_assetCount_table =
"CREATE TABLE IF NOT EXISTS ASSETCOUNT (today TEXT, todo TEXT, done TEXT)";

const char *create_auditType_table =
"CREATE TABLE IF NOT EXISTS AUDITTYPE (id TEXT PRIMARY KEY, name TEXT, orderNo TEXT)";

const char *create_dynamicLabel_table =
"CREATE TABLE IF NOT EXISTS DYNAMICLABEL (ASSET_CODING TEXT, ASSET_NAME TEXT, CONDITION TEXT, CRITICALITY TEXT, FILTER TEXT, LISTS TEXT, OPERATOR_TYPE TEXT, PLANT TEXT, PLANT_SECTION TEXT, SOURCE_DOCUMENTS TEXT, SYSTEM TINYINT, TAG TEXT, UNABLE_TO_LOCATE TEXT)";

@synthesize databasePath,auditImagePath,isLoggedIn,selectedPlantSettings,selectedEnvironmentSettings,selectedTypeSettings,isFindAssetToBeOpened,restEnv,isAuditUploadInProgress,tmpParentId,tmpParentName,logsString,plantSectionFilter,systemFilter,criticalityFilter,sourceDocFilter,selectedConnectionSettings;

static DataManager *singletonObject = nil;

+ (id) sharedManager
{
    if (! singletonObject) {
        
        singletonObject = [[DataManager alloc] init];
    }
    return singletonObject;
}

-(NSString*)getJsonStringForSyncUpdatesWithAsset:(AssetData *)asset{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self prepareDictonaryForSyncUpdatesWithAsset:asset] options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(NSDictionary *)prepareDictonaryForSyncUpdatesWithAsset:(AssetData *)asset {
    
    NSMutableArray* resultArr = [[NSMutableArray alloc] init];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    NSMutableArray* tmpAuditArr = [[NSMutableArray alloc] init];
    
    NSMutableArray* auditArr = [self getAuditDataForAssetId:asset.assetId];
    
    [dict setObject:asset.assetName forKey:@"name"];
    [dict setObject:asset.plantId forKey:@"Plant__c"];
    
    if (asset.isNewAsset) {
        [dict setObject:@"" forKey:@"Asset_id"];
    }
    else {
        [dict setObject:asset.assetId forKey:@"Asset_id"];
    }
    
    if (asset.parentId && ![asset.parentId isEqualToString:@""] && ![asset.parentId isEqualToString:@"(null)"]) {
        [dict setObject:asset.parentId forKey:@"Parent_Asset__c"];
    }
    
    if (asset.unableToLocate) {
        [dict setObject:@"true" forKey:@"UNABLE_TO_LOCATE__c"];
    }
    else {
        [dict setObject:@"false" forKey:@"UNABLE_TO_LOCATE__c"];
    }
    
    [dict setObject:asset.description forKey:@"Short_description__c"];
    [dict setObject:asset.tag forKey:@"Tag__c"];
    [dict setObject:asset.parent forKey:@"Make__c"];
    [dict setObject:asset.type forKey:@"Type__c"];
    [dict setObject:asset.condition forKey:@"CONDITION__c"];
    [dict setObject:asset.operatorClassId forKey:@"classname"];
    //[dict setObject:asset.operatorSubclass forKey:@"OPERATOR_SUB_CLASS__c"];
    [dict setObject:asset.operatorType forKey:@"OPERATOR_TYPE__c"];
    [dict setObject:asset.assetId forKey:@"Iphone_Asset_Id__c"];
    
    for (int j =0; j<[auditArr count]; j++) {
            AuditData* audit = [auditArr objectAtIndex:j];
            NSMutableDictionary* auditDict = [[NSMutableDictionary alloc] init];
            [auditDict setObject:[[audit.imgURL componentsSeparatedByString:@"/"] lastObject] forKey:@"Photograph__c"];
            [auditDict setObject:@"" forKey:@"TAG__c"];
            [auditDict setObject:[NSString stringWithFormat:@"%f",audit.altitude] forKey:@"Altitude__c"];
            [auditDict setObject:[NSString stringWithFormat:@"%f",audit.latitude] forKey:@"Geolocation__Latitude__s"];
            [auditDict setObject:[NSString stringWithFormat:@"%f",audit.longitude] forKey:@"Geolocation__Longitude__s"];
            [auditDict setObject:audit.dateTime forKey:@"Photograph_Taken__c"];
            [auditDict setObject:audit.auditType forKey:@"TYPE__c"];
        
            NSData* imgData = UIImageJPEGRepresentation([self loadAuditImagewithPath:audit.imgURL] ,1.0);
            [auditDict setObject:[NSNumber numberWithInteger:[imgData length]] forKey:@"file_size"];
            [auditDict setObject:audit.auditId forKey:@"file_name"];
            
            //UIImage* currImg = [self loadAuditImagewithPath:audit.imgURL];
            //[auditDict setObject:[self convertImageToString:currImg] forKey:@"image"];
            
            [tmpAuditArr addObject:auditDict];
    }
    
    [dict setObject:tmpAuditArr forKey:@"Audits"];
    tmpAuditArr = [[NSMutableArray alloc] init];
    [resultArr addObject:dict];
    NSDictionary* resultDict = [NSDictionary dictionaryWithObject:resultArr forKey:@"bulkdata"];
    
    return resultDict;
}

-(NSString*)getJsonStringForSyncNotes{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self prepareDictonaryForSyncNotes] options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(NSMutableDictionary *)prepareDictonaryForSyncNotes{
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    NSMutableArray* tmpAuditArr = [[NSMutableArray alloc] init];
    
    NSMutableArray* assetArr = [self getAllAssetIdForNote];
    
    for (int i = 0; i<[assetArr count]; i++) {
        NSMutableArray* noteArr = [self getNoteTypeForAssetId:[assetArr objectAtIndex:i]];
        
        for (int j =0; j<[noteArr count]; j++) {
            [tmpAuditArr addObject:[noteArr objectAtIndex:j]];
        }
        
        [dict setObject:tmpAuditArr forKey:[assetArr objectAtIndex:i]];
        tmpAuditArr = [[NSMutableArray alloc] init];
        
    }
    
    
    
    return dict;
}

-(NSString*)getJsonStringForSyncNotesWithId:(NSString *)assetId andNote:(NSString *)note{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self prepareDictonaryForSyncNotesWithId:assetId withNote:note] options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(NSMutableDictionary *)prepareDictonaryForSyncNotesWithId:(NSString *)assetId withNote:(NSString *)note{
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    NSMutableArray* tmpAuditArr = [[NSMutableArray alloc] init];
    
    
        [tmpAuditArr addObject:note];
        
        [dict setObject:tmpAuditArr forKey:assetId];
        tmpAuditArr = [[NSMutableArray alloc] init];
        //dict = [[NSMutableDictionary alloc] init];
    
    
    
    return dict;
}

- (NSString*)GetCurrentTimeStamp
{
    NSDateFormatter *objDateformat = [[NSDateFormatter alloc] init];
    [objDateformat setDateFormat:@"dd-MM-yyyy hh:mm:ss:SSS"];
    NSString    *strTime = [objDateformat stringFromDate:[NSDate date]];
    NSLog(@"The Timestamp is = %@",strTime);
    return strTime;
}


- (NSString*)GetCurrentDate
{
    NSDateFormatter *objDateformat = [[NSDateFormatter alloc] init];
    [objDateformat setDateFormat:@"dd-MM-yyyy"];
    NSString    *strTime = [objDateformat stringFromDate:[NSDate date]];
    NSLog(@"The Timestamp is = %@",strTime);
    return strTime;
}

/*-(NSString*)getJsonStringForSyncUpdates{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self prepareDictonaryForSyncUpdates] options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(NSDictionary *)prepareDictonaryForSyncUpdates {
    NSMutableArray* resultArr = [[NSMutableArray alloc] init];
    
    NSMutableArray* assetArr = [self getAssetData];
    for (int i = 0; i<[assetArr count]; i++) {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        NSMutableArray* tmpAuditArr = [[NSMutableArray alloc] init];
        AssetData* asset = [assetArr objectAtIndex:i];
        NSMutableArray* auditArr = [self getAuditDataForAssetId:asset.assetId];
        [dict setObject:asset.assetName forKey:@"name"];
        [dict setObject:asset.plantId forKey:@"Plant__c"];
        [dict setObject:asset.description forKey:@"Short_description__c"];
        [dict setObject:asset.tag forKey:@"Tag__c"];
        [dict setObject:asset.parent forKey:@"Make__c"];
        for (int j =0; j<[auditArr count]; j++) {
            AuditData* audit = [auditArr objectAtIndex:j];
            NSMutableDictionary* auditDict = [[NSMutableDictionary alloc] init];
            [auditDict setObject:[[audit.imgURL componentsSeparatedByString:@"/"] lastObject] forKey:@"Photograph__c"];
            [auditDict setObject:audit.auditId forKey:@"TAG__c"];
            [auditDict setObject:[NSString stringWithFormat:@"%f",audit.altitude] forKey:@"Altitude__c"];
            [auditDict setObject:[NSString stringWithFormat:@"%f",audit.latitude] forKey:@"Geolocation__Latitude__s"];
            [auditDict setObject:[NSString stringWithFormat:@"%f",audit.longitude] forKey:@"Geolocation__Longitude__s"];
            [auditDict setObject:audit.dateTime forKey:@"Photograph_Taken__c"];
            [auditDict setObject:audit.auditType forKey:@"TYPE__c"];
            
            UIImage* currImg = [self loadAuditImagewithPath:audit.imgURL];
            [auditDict setObject:[self convertImageToString:currImg] forKey:@"image"];
            
            [tmpAuditArr addObject:auditDict];
        }
        [dict setObject:tmpAuditArr forKey:@"Audits"];
        tmpAuditArr = [[NSMutableArray alloc] init];
        [resultArr addObject:dict];
    }
    NSDictionary* resultDict = [NSDictionary dictionaryWithObject:resultArr forKey:@"bulkdata"];
    return resultDict;
}*/

- (NSString* )convertImageToString:(UIImage *)img {
    
    NSData *imageData = UIImageJPEGRepresentation(img,1.0);
    
    NSString *encodedString = [imageData base64Encoding];
    
    return encodedString;
}

-(BOOL)isInternetConnectionAvailable{
    
//    if ([self getForceOfflineDetails]) {
//        return false;
//    }
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nInternet Disabled"]]];
        return false;
    } else {
        [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\nInternet Enabled"]]];
        return true;
    }
}

- (void)saveAuditImage: (UIImage*)image withName: (NSString *)name
{
    if (image != nil)
    {
        NSString* path = [auditImagePath stringByAppendingPathComponent:name];
        NSData* data = UIImageJPEGRepresentation(image,1.0);
        [data writeToFile:path atomically:YES];
    }
}

- (void)deleteAllSavedAuditImages {
    NSMutableArray* imgPathArr = [self getAllAuditImagePath];
    for (int i =0; i<[imgPathArr count]; i++) {
        NSString* path = [auditImagePath stringByAppendingPathComponent:[[[imgPathArr objectAtIndex:i] componentsSeparatedByString:@"/"] lastObject]];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        NSLog(@"%@ audit image deleted",[[[imgPathArr objectAtIndex:i] componentsSeparatedByString:@"/"] lastObject]);
        
        [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\n%@ audit image deleted",[[[imgPathArr objectAtIndex:i] componentsSeparatedByString:@"/"] lastObject]]]];
    }
}

- (void)deleteAllAuditImagesWithAssetId:(NSString *) assetId {
    NSMutableArray* imgPathArr = [self getAllAuditImagePathForAssetId:assetId];
    for (int i =0; i<[imgPathArr count]; i++) {
        NSString* path = [auditImagePath stringByAppendingPathComponent:[[[imgPathArr objectAtIndex:i] componentsSeparatedByString:@"/"] lastObject]];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        NSLog(@"%@ audit image deleted",[[[imgPathArr objectAtIndex:i] componentsSeparatedByString:@"/"] lastObject]);
        
        [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\n%@ audit image deleted",[[[imgPathArr objectAtIndex:i] componentsSeparatedByString:@"/"] lastObject]]]];
    }
}

- (void)deleteAllAuditImagesWithAuditId:(NSString *) auditId {
    NSMutableArray* imgPathArr = [self getAllAuditImagePathForAuditId:auditId];
    for (int i =0; i<[imgPathArr count]; i++) {
        NSString* path = [auditImagePath stringByAppendingPathComponent:[[[imgPathArr objectAtIndex:i] componentsSeparatedByString:@"/"] lastObject]];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        NSLog(@"%@ audit image deleted",[[[imgPathArr objectAtIndex:i] componentsSeparatedByString:@"/"] lastObject]);
        
        [[DataManager sharedManager] setLogsString:[[[DataManager sharedManager] logsString] stringByAppendingString:[NSString stringWithFormat:@"\n%@ audit image deleted",[[[imgPathArr objectAtIndex:i] componentsSeparatedByString:@"/"] lastObject]]]];
    }
}

- (UIImage*)loadAuditImagewithName: (NSString *)name
{
    NSString* path = [auditImagePath stringByAppendingPathComponent:name];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}

- (UIImage*)loadAuditImagewithPath: (NSString *)path
{
    NSString* path1 = [auditImagePath stringByAppendingPathComponent:[[path componentsSeparatedByString:@"/"] lastObject]];
    UIImage* image = [UIImage imageWithContentsOfFile:path1];
    return image;
}



-(void)setupDatabase{
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    sqlite3 *assetDB;
    auditImagePath = docsDir;
    
    // Build the path to the database file
    databasePath = [[NSString alloc]
                     initWithString: [docsDir stringByAppendingPathComponent:
                                      @"assets2.db"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = create_asset_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create Assets table with error %s",errMsg);
            }
            else
            {
                NSLog(@"Assets Table created");
            }
            
            sql_stmt = create_authToken_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create AUTHTOKEN table with error %s",errMsg);
            }
            else
            {
                NSLog(@"AUTHTOKEN Table created");
            }
            
            sql_stmt = create_audit_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create Audit table with error %s",errMsg);
            }
            else
            {
                NSLog(@"Audit Table created");
            }
            
            sql_stmt = create_download_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create Download table with error %s",errMsg);
            }
            else
            {
                NSLog(@"Download Table created");
            }
            
            sql_stmt = create_plant_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create SelectedPlant table with error %s",errMsg);
            }
            else
            {
                NSLog(@"SelectedPlant Table created");
            }
            
            sql_stmt = create_environment_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create SelectedEnvironment table with error %s",errMsg);
            }
            else
            {
                NSLog(@"SelectedEnvironment Table created");
            }
            
            sql_stmt = create_notetype_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create NoteType table with error %s",errMsg);
            }
            else
            {
                NSLog(@"NoteType Table created");
            }
            
            sql_stmt = create_imgQuality_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create ImgQuality table with error %s",errMsg);
            }
            else
            {
                NSLog(@"ImgQuality Table created");
            }
            
            sql_stmt = create_typeSettings_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create SELECTEDTYPE table with error %s",errMsg);
            }
            else
            {
                NSLog(@"SELECTEDTYPE Table created");
            }
            
            sql_stmt = create_plantSection_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create PLANTSECTION table with error %s",errMsg);
            }
            else
            {
                NSLog(@"PLANTSECTION Table created");
            }
            
            sql_stmt = create_system_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create SYSTEM table with error %s",errMsg);
            }
            else
            {
                NSLog(@"SYSTEM Table created");
            }
            
            sql_stmt = create_selectedSet_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create SELECTEDSET table with error %s",errMsg);
            }
            else
            {
                NSLog(@"SELECTEDSET Table created");
            }
            
            /*sql_stmt = create_selectedIacValue_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create SELECTEDIAC table with error %s",errMsg);
            }
            else
            {
                NSLog(@"SELECTEDIAC Table created");
            }*/
            
            sql_stmt = create_isSearchOnSet_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create ISSEARCHONSET table with error %s",errMsg);
            }
            else
            {
                NSLog(@"ISSEARCHONSET Table created");
            }
            
            sql_stmt = create_operatorType_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create OPERATORTYPE table with error %s",errMsg);
            }
            else
            {
                NSLog(@"OPERATORTYPE Table created");
            }
            
            sql_stmt = create_criticality_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create CRITICALITY table with error %s",errMsg);
            }
            else
            {
                NSLog(@"CRITICALITY Table created");
            }
            
            sql_stmt = create_sourceDocs_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create SOURCEDOCS table with error %s",errMsg);
            }
            else
            {
                NSLog(@"SOURCEDOCS Table created");
            }
            
            sql_stmt = create_syncRecords_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create SYNCRECORDS table with error %s",errMsg);
            }
            else
            {
                NSLog(@"SYNCRECORDS Table created");
            }
            
            sql_stmt = create_conditions_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create CONDITIONS table with error %s",errMsg);
            }
            else
            {
                NSLog(@"CONDITIONS Table created");
            }
            
            sql_stmt = create_operatorClass_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create OPERATORCLASS table with error %s",errMsg);
            }
            else
            {
                NSLog(@"OPERATORCLASS Table created");
            }
            
            sql_stmt = create_operatorSubclass_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create OPERATORSUBCLASS table with error %s",errMsg);
            }
            else
            {
                NSLog(@"OPERATORSUBCLASS Table created");
            }
            
            sql_stmt = create_today_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create TODAY table with error %s",errMsg);
            }
            else
            {
                NSLog(@"TODAY Table created");
            }
            
            sql_stmt = create_assetCoding_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create ASSETCODING table with error %s",errMsg);
            }
            else
            {
                NSLog(@"ASSETCODING Table created");
            }
            
            sql_stmt = create_selectedConnection_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create SELECTEDCONNECTION table with error %s",errMsg);
            }
            else
            {
                NSLog(@"SELECTEDCONNECTION Table created");
            }
            
            sql_stmt = create_lockExistingRecords_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create LOCKRECORDS table with error %s",errMsg);
            }
            else
            {
                NSLog(@"LOCKRECORDS Table created");
            }
            
            sql_stmt = create_searchOnlyInPuchList_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create SEARCHPUNCHLIST table with error %s",errMsg);
            }
            else
            {
                NSLog(@"SEARCHPUNCHLIST Table created");
            }
            
            sql_stmt = create_category_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create CATEGORY table with error %s",errMsg);
            }
            else
            {
                NSLog(@"CATEGORY Table created");
            }
            
            sql_stmt = create_forceOfflineMode_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create FORCEOFFLINE table with error %s",errMsg);
            }
            else
            {
                NSLog(@"FORCEOFFLINE Table created");
            }
            
            sql_stmt = create_assetCount_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create ASSETCOUNT table with error %s",errMsg);
            }
            else
            {
                NSLog(@"ASSETCOUNT Table created");
            }
            
            sql_stmt = create_auditType_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create AUDITTYPE table with error %s",errMsg);
            }
            else
            {
                NSLog(@"AUDITTYPE Table created");
            }
            
            sql_stmt = create_dynamicLabel_table;
            if (sqlite3_exec(assetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create DYNAMICTABLE table with error %s",errMsg);
            }
            else
            {
                NSLog(@"DYNAMICTABLE Table created");
            }
            
            
            
            sqlite3_close(assetDB);
            
            [self saveImQualityWithValue:@"2.0"];
            [self saveTypeDetailsWithName:@"ASSET"];
            [self savePlantSectionDetailsWithName:@""];
            [self saveSystemDetailsWithName:@""];
            [self saveCriticalityDetailsWithName:@""];
            [self saveSourceDocsDetailsWithName:@""];
            [self saveSelectedSetDetailsWithName:@"" andSetId:@""];
            [self savePlantDetailsWithId:@"" withName:@"" andOperatingUnit:@""];
            //[self saveIACDetailsWithName:@"False"];
            [self saveIsSearchOnSetWithValue:NO];
            [self saveSyncRecordsWithValue:YES];
            [self saveAssetCodingOptionsForCondition:true andOperatorType:true andOperatorClass:true andOperatorSubclass:true andCategory:true andType:true];
            
            [self saveSeletedConnectionDetailsWithName:@"STANDALONE"];
            [self saveLockRecordsWithValue:NO];
            [self savePunchListWithValue:NO];
            [self saveForceOfflineWithValue:NO];

            
            [self addDefaultAuditTypeValuesToDB];
            
            
        } else {
            NSLog(@"Failed to open/create database");
        }
    }
}



- (void) addDefaultAuditTypeValuesToDB {
    
    
    [self saveAuditTypeForId:@"1" andName:@"NAMEPLATE" andOrder:@"1"];
    [self saveAuditTypeForId:@"2" andName:@"TAG" andOrder:@"2"];
    [self saveAuditTypeForId:@"3" andName:@"EQUIPMENT" andOrder:@"3"];
    [self saveAuditTypeForId:@"4" andName:@"SERVICE" andOrder:@"4"];
    [self saveAuditTypeForId:@"5" andName:@"INSPECTION" andOrder:@"5"];
    [self saveAuditTypeForId:@"6" andName:@"VENDOR" andOrder:@"6"];
    
}

- (void) saveAssetData:(AssetData *)assetData withUpdate:(BOOL)update
{
    if (update) {
        [self deleteOnlyAssetWithId:assetData.assetId];
    }
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO ASSETS VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%d\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%d\", \"0\")",
                               assetData.assetId, assetData.assetName,assetData.plantName,assetData.description,assetData.tag,assetData.plantId,assetData.parent,assetData.type,assetData.isNewAsset,assetData.parentId,[self GetCurrentTimeStamp],assetData.condition,assetData.operatorType,assetData.operatorClass,assetData.operatorClassId,assetData.category,assetData.categoryId,assetData.operatorSubclass,assetData.operatorSubclassId,assetData.unableToLocate];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New asset added");
        } else {
            NSLog(@"Failed to add asset");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (void) saveOnlyAssetData:(AssetData *)assetData
{
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM ASSETS WHERE assetId = \"%@\"",assetData.assetId];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"%@ ASSET deleted",assetData.assetId);
        }
        
        sqlite3_close(assetDB);
    }

    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO ASSETS VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%d\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%d\", \"0\")",
                               assetData.assetId, assetData.assetName,assetData.plantName,assetData.description,assetData.tag,assetData.plantId,assetData.parent,assetData.type,assetData.isNewAsset,assetData.parentId,[self GetCurrentTimeStamp],assetData.condition,assetData.operatorType,assetData.operatorClass,assetData.operatorClassId,assetData.category,assetData.categoryId,assetData.operatorSubclass,assetData.operatorSubclassId,assetData.unableToLocate];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New asset added");
        } else {
            NSLog(@"Failed to add asset");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (NSMutableArray *) getAssetData
{
    NSMutableArray* arr  = [[NSMutableArray alloc] init];
    AssetData * assetData;
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM ASSETS WHERE uploaded = 0"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                assetData = [[AssetData alloc] init];
                assetData.assetId = [[NSString alloc]
                                          initWithUTF8String:
                                          (const char *) sqlite3_column_text(
                                                                             statement, 0)];

                assetData.assetName = [[NSString alloc]
                                        initWithUTF8String:(const char *)
                                        sqlite3_column_text(statement, 1)];
                assetData.plantName = [[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 2)];
                assetData.description = [[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 3)];
                assetData.tag = [[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 4)];
                assetData.plantId = [[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 5)];
                assetData.parent = [[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 6)];
                assetData.type = [[NSString alloc]
                                    initWithUTF8String:(const char *)
                                    sqlite3_column_text(statement, 7)];
                assetData.isNewAsset = [[[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 8)] boolValue];
                assetData.parentId = [[NSString alloc]
                                     initWithUTF8String:(const char *)
                                     sqlite3_column_text(statement, 9)];
                
                assetData.condition = [[NSString alloc]
                                      initWithUTF8String:(const char *)
                                      sqlite3_column_text(statement, 11)];
                assetData.operatorType = [[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 12)];
                assetData.operatorClass = [[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 13)];
                assetData.operatorClassId = [[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 14)];
                assetData.category = [[NSString alloc]
                                              initWithUTF8String:(const char *)
                                              sqlite3_column_text(statement, 15)];
                assetData.categoryId = [[NSString alloc]
                                      initWithUTF8String:(const char *)
                                      sqlite3_column_text(statement, 16)];
                assetData.operatorSubclass = [[NSString alloc]
                                      initWithUTF8String:(const char *)
                                      sqlite3_column_text(statement, 17)];
                assetData.operatorSubclassId = [[NSString alloc]
                                      initWithUTF8String:(const char *)
                                      sqlite3_column_text(statement, 18)];
                assetData.unableToLocate = [[[NSString alloc]
                                                initWithUTF8String:(const char *)
                                                sqlite3_column_text(statement, 19)] boolValue];
                [arr addObject:assetData];
                NSLog(@"Asset found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return arr;
}

- (void) saveAuditData:(AuditData *)auditData
{
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO AUDITS VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%f\", \"%f\", \"%f\", \"0\")",
                               auditData.auditId, auditData.assetId,auditData.assetName,auditData.auditType,auditData.imgURL,auditData.dateTime,auditData.latitude, auditData.longitude,auditData.altitude];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New audit added");
        } else {
            NSLog(@"Failed to add audit");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

//- (int) getAuditDataCount
//{
//    int count = 0;
//    const char *dbpath = [databasePath UTF8String];
//    sqlite3_stmt    *statement;
//    sqlite3 *assetDB;
//    
//    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
//    {
//        NSString *querySQL = [NSString stringWithFormat:@"SELECT count(auditId) FROM AUDITS WHERE assetId NOT IN (SELECT assetId from ASSETS)"];
//        
//        const char *query_stmt = [querySQL UTF8String];
//        
//        if (sqlite3_prepare_v2(assetDB,
//                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
//        {
//            if (sqlite3_step(statement) == SQLITE_ROW)
//            {
//                count = [[[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)] intValue];
//                NSLog(@"%d Audits found",count);
//            }
//            sqlite3_finalize(statement);
//        }
//        sqlite3_close(assetDB);
//    }
//    return count;
//}

- (int) getAuditDataCount
{
    int count = 0;
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT count(auditId) FROM AUDITS WHERE uploaded = 0"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                count = [[[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)] intValue];
                NSLog(@"%d Audits found",count);
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return count;
}



- (NSMutableArray *) getAuditDataForAssetId:(NSString *)tmpAssetId
{
    NSMutableArray* arr  = [[NSMutableArray alloc] init];
    AuditData * auditData;
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM AUDITS WHERE assetId = '%@'",tmpAssetId];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                auditData = [[AuditData alloc] init];
                auditData.auditId = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
                
                auditData.assetId = [[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 1)];
                auditData.assetName = [[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 2)];
                auditData.auditType = [[NSString alloc]
                                         initWithUTF8String:(const char *)
                                         sqlite3_column_text(statement, 3)];
                auditData.imgURL = [[NSString alloc]
                                 initWithUTF8String:(const char *)
                                 sqlite3_column_text(statement, 4)];
                auditData.dateTime = [[NSString alloc]
                                     initWithUTF8String:(const char *)
                                     sqlite3_column_text(statement, 5)];
                auditData.latitude = [[[NSString alloc]
                                    initWithUTF8String:(const char *)
                                    sqlite3_column_text(statement, 6)] floatValue];
                auditData.longitude = [[[NSString alloc]
                                         initWithUTF8String:(const char *)
                                         sqlite3_column_text(statement, 7)] floatValue];
                auditData.altitude = [[[NSString alloc]
                                        initWithUTF8String:(const char *)
                                        sqlite3_column_text(statement, 8)] floatValue];
                [arr addObject:auditData];
                NSLog(@"Audit found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return arr;
}

- (AssetData *) getAssetDataForAssetId:(NSString *)tmpAssetId
{
    AssetData * assetData;
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM ASSETS WHERE assetId = '%@'",tmpAssetId];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                assetData = [[AssetData alloc] init];
                assetData.assetId = [[NSString alloc]
                                     initWithUTF8String:
                                     (const char *) sqlite3_column_text(
                                                                        statement, 0)];
                
                assetData.assetName = [[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 1)];
                assetData.plantName = [[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 2)];
                assetData.description = [[NSString alloc]
                                         initWithUTF8String:(const char *)
                                         sqlite3_column_text(statement, 3)];
                assetData.tag = [[NSString alloc]
                                 initWithUTF8String:(const char *)
                                 sqlite3_column_text(statement, 4)];
                assetData.plantId = [[NSString alloc]
                                     initWithUTF8String:(const char *)
                                     sqlite3_column_text(statement, 5)];
                assetData.parent = [[NSString alloc]
                                    initWithUTF8String:(const char *)
                                    sqlite3_column_text(statement, 6)];
                assetData.type = [[NSString alloc]
                                  initWithUTF8String:(const char *)
                                  sqlite3_column_text(statement, 7)];
                assetData.isNewAsset = [[[NSString alloc]
                                         initWithUTF8String:(const char *)
                                         sqlite3_column_text(statement, 8)] boolValue];
                assetData.parentId = [[NSString alloc]
                                      initWithUTF8String:(const char *)
                                      sqlite3_column_text(statement, 9)];
                
                assetData.condition = [[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 11)];
                assetData.operatorType = [[NSString alloc]
                                          initWithUTF8String:(const char *)
                                          sqlite3_column_text(statement, 12)];
                assetData.operatorClass = [[NSString alloc]
                                           initWithUTF8String:(const char *)
                                           sqlite3_column_text(statement, 13)];
                assetData.operatorClassId = [[NSString alloc]
                                              initWithUTF8String:(const char *)
                                              sqlite3_column_text(statement, 14)];
                assetData.category = [[NSString alloc]
                                              initWithUTF8String:(const char *)
                                              sqlite3_column_text(statement, 15)];
                assetData.categoryId = [[NSString alloc]
                                        initWithUTF8String:(const char *)
                                        sqlite3_column_text(statement, 16)];
                assetData.operatorSubclass = [[NSString alloc]
                                              initWithUTF8String:(const char *)
                                              sqlite3_column_text(statement, 17)];
                assetData.operatorSubclassId = [[NSString alloc]
                                                initWithUTF8String:(const char *)
                                                sqlite3_column_text(statement, 18)];
                assetData.unableToLocate = [[[NSString alloc]
                                                initWithUTF8String:(const char *)
                                                sqlite3_column_text(statement, 19)] boolValue];
                NSLog(@"Asset found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return assetData;
}

- (NSMutableArray *) getAllAuditImagePath
{
    NSMutableArray* arr  = [[NSMutableArray alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT imgURL FROM AUDITS"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                [arr addObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)]];
                NSLog(@"Audit Image found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return arr;
}

- (NSMutableArray *) getAllAuditImagePathForAssetId:(NSString *)assetId
{
    NSMutableArray* arr  = [[NSMutableArray alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT imgURL FROM AUDITS WHERE assetId = \"%@\"",assetId];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                [arr addObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)]];
                NSLog(@"Audit Image found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return arr;
}

- (NSMutableArray *) getAllAuditImagePathForAuditId:(NSString *)auditId
{
    NSMutableArray* arr  = [[NSMutableArray alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT imgURL FROM AUDITS WHERE auditId = \"%@\"",auditId];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                [arr addObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)]];
                NSLog(@"Audit Image found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return arr;
}

- (void) saveAuthToken:(NSString *)token withInstanceURL:(NSString *)instanceURL withIdentity:(NSString *)identity withBucket:(NSString *)bucket andUsername:(NSString *)username
{
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO AUTHTOKEN VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",token,instanceURL,identity,bucket,username];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New authToken added");
            [self setIsLoggedIn:true];
        } else {
            NSLog(@"Failed to add authToken");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (NSString *) getAuthToken
{
    NSString * token = [[NSString alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT token FROM AUTHTOKEN"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                token = [[NSString alloc]
                                     initWithUTF8String:
                                     (const char *) sqlite3_column_text(
                                                                        statement, 0)];
                NSLog(@"Token found");
            }
            else
            {
                NSLog(@"No token found in DB");
                return nil;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return token;
}

- (NSString *) getInstanceURL
{
    NSString * token = [[NSString alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT instanceURL FROM AUTHTOKEN"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                token = [[NSString alloc]
                         initWithUTF8String:
                         (const char *) sqlite3_column_text(
                                                            statement, 0)];
                NSLog(@"Instance URL found");
            }
            else
            {
                NSLog(@"No Instance URL found in DB");
                return nil;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return token;
}

- (NSString *) getIdentity
{
    NSString * token = [[NSString alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT identity FROM AUTHTOKEN"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                token = [[NSString alloc]
                         initWithUTF8String:
                         (const char *) sqlite3_column_text(
                                                            statement, 0)];
                NSLog(@"Identity found");
            }
            else
            {
                NSLog(@"No Identity found in DB");
                return nil;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return token;
}

- (NSString *) getBucket
{
    NSString * token = [[NSString alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT bucket FROM AUTHTOKEN"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                token = [[NSString alloc]
                         initWithUTF8String:
                         (const char *) sqlite3_column_text(
                                                            statement, 0)];
                NSLog(@"Bucket found");
            }
            else
            {
                NSLog(@"No Bucket found in DB");
                return nil;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return token;
}

- (NSString *) getUsername
{
    NSString * token = [[NSString alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT username FROM AUTHTOKEN"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                token = [[NSString alloc]
                         initWithUTF8String:
                         (const char *) sqlite3_column_text(
                                                            statement, 0)];
                NSLog(@"username found");
            }
            else
            {
                NSLog(@"No username found in DB");
                return nil;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return token;
}

- (void) deleteAuthToken {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM AUTHTOKEN"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"Token deleted");
            [self setIsLoggedIn:false];
        }
        sqlite3_close(assetDB);
    }

}

- (void) deleteAllAssetsAndAudits {
    [self deleteAllSavedAuditImages];
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM ASSETS"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"ALL ASSETS deleted");
        }
        
        querySQL = [NSString stringWithFormat:@"DELETE FROM AUDITS"];
        
        query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"ALL AUDITS deleted");
        }
        
        sqlite3_close(assetDB);
    }
    
}

- (void) saveDownloadData:(NSMutableDictionary *)downloadDict
{
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        for (int i = 0; i<[downloadDict count] ; i++) {
            NSDictionary* currentAsset = [downloadDict valueForKey:[NSString stringWithFormat:@"%d",i]];
            NSString *insertSQL = [NSString stringWithFormat:
                                   @"INSERT INTO DOWNLOADS VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%d\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
                                   [currentAsset valueForKey:@"ASSETS_id"], [currentAsset valueForKey:@"Name"],[currentAsset valueForKey:@"Plant__name"],[[currentAsset valueForKey:@"SHORT_DESCRIPTION__c"] stringByReplacingOccurrencesOfString:@"\"" withString:@""],[currentAsset valueForKey:@"TAG__c"],[currentAsset valueForKey:@"Plant__id"],[currentAsset valueForKey:@"PARENT_ASSET__c"], [currentAsset valueForKey:@"PARENT_ASSET__Name"],[currentAsset valueForKey:@"AUDIT_COMPLETED__c"],[currentAsset valueForKey:@"MAKE__c"],[currentAsset valueForKey:@"TYPE__c"],[[currentAsset valueForKey:@"UNABLE_TO_LOCATE__c"] boolValue],[currentAsset valueForKey:@"PLANT_SECTION__c"],[currentAsset valueForKey:@"SYSTEM__c"],[currentAsset valueForKey:@"OPERATOR_TYPE__c"],[currentAsset valueForKey:@"CRITICALITY__c"],[currentAsset valueForKey:@"SOURCE_DOCUMENTS__c"],[currentAsset valueForKey:@"CONDITION__c"],[currentAsset valueForKey:@"Class__name"],[currentAsset valueForKey:@"Class__id"],[currentAsset valueForKey:@"Category__name"],[currentAsset valueForKey:@"Category__id"],[currentAsset valueForKey:@"SubClass__name"],[currentAsset valueForKey:@"SubClass__id"],[currentAsset valueForKey:@"PUNCH_LIST__c"], [currentAsset valueForKey:@"LIST__c"], [currentAsset valueForKey:@"SEQUENCE__c"]];
            
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(assetDB, insert_stmt,
                               -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                NSLog(@"New downloaded asset added");
            } else {
                NSLog(@"Failed to add downloaded asset %s",sqlite3_errmsg(assetDB));
            }
            sqlite3_finalize(statement);
        }
        
        sqlite3_close(assetDB);
    }
}

- (void) deleteAllDownloadsData {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM DOWNLOADS"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"ALL DOWNLOADS deleted");
        }
        
        sqlite3_close(assetDB);
    }
    
}

- (NSMutableArray *) getAllAssetsToBeSynced
{
    NSMutableArray* arr  = [[NSMutableArray alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM ASSETS WHERE uploaded = 0 order by createdDate desc"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] forKey:@"id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)] forKey:@"name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)] forKey:@"plantName"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)] forKey:@"description"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)] forKey:@"tag"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)] forKey:@"plantId"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 6)] forKey:@"parent"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 7)] forKey:@"type"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 8)] forKey:@"isNewAsset"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 9)] forKey:@"parentId"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 11)] forKey:@"condition"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 12)] forKey:@"operatorType"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 13)] forKey:@"Class__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 14)] forKey:@"Class__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 15)] forKey:@"Category__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 16)] forKey:@"Category__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 17)] forKey:@"SubClass__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 18)] forKey:@"SubClass__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 19)] forKey:@"UNABLE_TO_LOCATE__c"];
                
                
                [arr addObject:dict];
                NSLog(@"Synced Asset found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return arr;
}

- (NSMutableArray *) getAllAuditsToBeSyncedForAssetId:(NSString* )assetId
{
    NSMutableArray* arr  = [[NSMutableArray alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM AUDITS WHERE assetId = \"%@\"",assetId];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] forKey:@"auditId"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)] forKey:@"assetId"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)] forKey:@"assetName"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)] forKey:@"auditType"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)] forKey:@"imgURL"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)] forKey:@"dateTime"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 6)] forKey:@"latitude"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 7)] forKey:@"longitude"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 8)] forKey:@"altitude"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 9)] forKey:@"uploaded"];
                
                [arr addObject:dict];
                NSLog(@"Synced Audit found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return arr;
}
//assetId TEXT PRIMARY KEY, assetName TEXT, plantName TEXT, description TEXT, tag TEXT, plantId TEXT, parentId TEXT, junctionId TEXT, make TEXT, type TEXT)";

- (NSMutableArray *) getAllAssetsForOfflineTextWithAuditUncompleted:(NSString* )offlineText
{
    NSMutableArray* arr  = [[NSMutableArray alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
//        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM DOWNLOADS WHERE assetName LIKE '%%%@%%'",offlineText];
        NSString* filterString = [self getOfflineFilterQueryString:2];
        
    NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM DOWNLOADS WHERE (isAuditCompleted = '0') and assetId NOT IN (SELECT assetId from ASSETS WHERE uploaded = 0) AND (assetName LIKE '%%%@%%' or plantName LIKE '%%%@%%' or description LIKE '%%%@%%' or tag LIKE '%%%@%%' or plantId LIKE '%%%@%%' or parentId LIKE '%%%@%%' or make LIKE '%%%@%%' or type LIKE '%%%@%%') %@ ORDER BY sequence, assetName COLLATE NOCASE",offlineText,offlineText,offlineText,offlineText,offlineText,offlineText,offlineText,offlineText, filterString];
        
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] forKey:@"Id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)] forKey:@"Name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)] forKey:@"Plant__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)] forKey:@"Short_description__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)] forKey:@"Tag__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)] forKey:@"Plant__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 6)] forKey:@"PARENT_ASSET__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 7)] forKey:@"PARENT_ASSET__Name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 8)] forKey:@"isAuditCompleted"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 9)] forKey:@"Make__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 10)] forKey:@"TYPE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 11)] forKey:@"UNABLE_TO_LOCATE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 14)] forKey:@"OPERATOR_TYPE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 17)] forKey:@"CONDITION__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 18)] forKey:@"Class__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 19)] forKey:@"Class__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 20)] forKey:@"Category__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 21)] forKey:@"Category__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 22)] forKey:@"SubClass__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 23)] forKey:@"SubClass__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 24)] forKey:@"PUNCH_LIST__c"];
                
                
                [arr addObject:dict];
                NSLog(@"Searched Asset found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return arr;
}

- (void) savePlantDetailsWithId:(NSString *)plantId withName:(NSString *)plantName andOperatingUnit:(NSString *)opName
{
    [self deletePlantDetails];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO SELECTEDPLANT VALUES (\"%@\", \"%@\", \"%@\")",plantId,plantName,opName];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New Plant details added");
            [self setSelectedPlantSettings:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:plantId, plantName, nil] forKeys:[NSArray arrayWithObjects:@"Id", @"Name", nil ]]];
        } else {
            NSLog(@"Failed to add Plant Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (NSMutableDictionary *) getSelectedPlantDetails
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM SELECTEDPLANT"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                [dict setObject:[[NSString alloc]
                                initWithUTF8String:
                                 (const char *) sqlite3_column_text(statement, 0)] forKey:@"Id"];
                [dict setObject:[[NSString alloc]
                                 initWithUTF8String:
                                 (const char *) sqlite3_column_text(statement, 1)] forKey:@"Name"];
                [dict setObject:[[NSString alloc]
                                 initWithUTF8String:
                                 (const char *) sqlite3_column_text(statement, 2)] forKey:@"Operating"];
                NSLog(@"Plant details found");
            }
            else
            {
                NSLog(@"No plant details found in DB");
                return nil;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return dict;
}

- (void) deletePlantDetails {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM SELECTEDPLANT"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"Plant details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}

- (void) deleteAssetWithId:(NSString *)assetid {
    
    //[self deleteAllAuditImagesWithAssetId:assetid];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM ASSETS WHERE assetId = \"%@\"",assetid];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"%@ ASSET deleted",assetid);
        }
        
        querySQL = [NSString stringWithFormat:@"DELETE FROM AUDITS WHERE assetId = \"%@\"",assetid];
        query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"%@ AUDIT deleted",assetid);
        }
        
        sqlite3_close(assetDB);
    }
    
}

- (void) deleteOnlyAssetWithId:(NSString *)assetid {
    
    //[self deleteAllAuditImagesWithAssetId:assetid];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM ASSETS WHERE assetId = \"%@\"",assetid];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"%@ ASSET deleted",assetid);
        }
        
        sqlite3_close(assetDB);
    }
    
}

- (void) saveEnvironmentDetailsWithName:(NSString *)name
{
    [self deleteEnvironmentDetails];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO SELECTEDENVIRONMENT VALUES (\"%@\")",name];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New Environment details added");
            [self setSelectedEnvironmentSettings:name];
        } else {
            NSLog(@"Failed to add Environment Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (NSString *) getSelectedEnvironmentDetails
{
    NSString * result = [[NSString alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM SELECTEDENVIRONMENT"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                result = [[NSString alloc]
                          initWithUTF8String:
                          (const char *) sqlite3_column_text(statement, 0)];
                NSLog(@"Environment details found");
            }
            else
            {
                NSLog(@"No Environment details found in DB");
                return nil;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return result;
}

- (void) deleteEnvironmentDetails {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM SELECTEDENVIRONMENT"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"Environment details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}

- (void) deleteAuditWithId:(NSString *)auditId {
    
    //[self deleteAllAuditImagesWithAssetId:assetid];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM AUDITS WHERE auditId = \"%@\"",auditId];
        const char *query_stmt = [querySQL UTF8String];
    
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"%@ AUDIT deleted",auditId);
        }
        
        sqlite3_close(assetDB);
    }
    
}

-(void)saveNoteTypeDetailsWithId:(NSString *)assetId withNote:(NSString *)noteType
{
    [self deleteNoteWithId:assetId];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO NOTETYPE VALUES (\"%@\", \"%@\")",assetId,noteType];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New Note added");
        } else {
            NSLog(@"Failed to add Note for asset %@",assetId);
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (void) deleteNoteWithId:(NSString *)assetid {
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM NOTETYPE WHERE assetId = \"%@\"",assetid];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"Note deleted for asset %@",assetid);
        }
        
        sqlite3_close(assetDB);
    }
    
}

- (NSMutableArray *) getNoteTypeForAssetId:(NSString *)tmpAssetId
{
    NSMutableArray* notetype = [[NSMutableArray alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT notetype FROM NOTETYPE WHERE assetId = '%@'",tmpAssetId];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                [notetype addObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)]];
                NSLog(@"NoteType found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return notetype;
}

- (NSMutableArray *) getAllNoteType
{
    NSMutableArray* notetype = [[NSMutableArray alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT notetype FROM NOTETYPE"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                [notetype addObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)]];
                NSLog(@"NoteType found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return notetype;
}

- (NSMutableArray *) getAllAssetIdForNote
{
    NSMutableArray* notetype = [[NSMutableArray alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT distinct assetId FROM NOTETYPE"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                [notetype addObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)]];
                NSLog(@"AssetId for note found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return notetype;
}

- (void) deleteAllNotes {
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM NOTETYPE"];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"All Notes deleted");
        }
        
        sqlite3_close(assetDB);
    }
    
}

- (void) saveImQualityWithValue:(NSString *)val
{
    [self deleteImgQuality];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO IMGQUALITY VALUES (\"%@\")",val];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New ImgQuality details added");
        } else {
            NSLog(@"Failed to add ImgQuality Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (NSString *) getSelectedImgQuality
{
    NSString * result = [[NSString alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM IMGQUALITY"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                result = [[NSString alloc]
                          initWithUTF8String:
                          (const char *) sqlite3_column_text(statement, 0)];
                NSLog(@"ImgQuality details found");
            }
            else
            {
                NSLog(@"No ImgQuality details found in DB");
                return nil;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return result;
}

- (void) deleteImgQuality {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM IMGQUALITY"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"ImgQuality details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}

- (void) saveTypeDetailsWithName:(NSString *)name
{
    [self deleteTypeDetails];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO SELECTEDTYPE VALUES (\"%@\")",name];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New Type details added");
            [self setSelectedTypeSettings:name];
        } else {
            NSLog(@"Failed to add Type Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (NSString *) getSelectedTypeDetails
{
    NSString * result = [[NSString alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM SELECTEDTYPE"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                result = [[NSString alloc]
                          initWithUTF8String:
                          (const char *) sqlite3_column_text(statement, 0)];
                NSLog(@"Type details found");
            }
            else
            {
                NSLog(@"No Type details found in DB");
                return nil;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return result;
}

- (void) deleteTypeDetails {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM SELECTEDTYPE"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"Type details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}

- (void) savePlantSectionDetailsWithName:(NSString *)name
{
    [self deletePlantSectionDetails];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO PLANTSECTION VALUES (\"%@\")",name];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New PLANTSECTION details added");
            [self setPlantSectionFilter:name];
            
        } else {
            NSLog(@"Failed to add PLANTSECTION Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (NSString *) getSelectedPlantSectionDetails
{
    NSString * result = [[NSString alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM PLANTSECTION"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                result = [[NSString alloc]
                          initWithUTF8String:
                          (const char *) sqlite3_column_text(statement, 0)];
                NSLog(@"PLANTSECTION details found");
            }
            else
            {
                NSLog(@"No PLANTSECTION details found in DB");
                return nil;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return result;
}

- (void) deletePlantSectionDetails {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM PLANTSECTION"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"PLANTSECTION details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}

- (void) saveSystemDetailsWithName:(NSString *)name
{
    [self deleteSystemDetails];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO SYSTEM VALUES (\"%@\")",name];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New SYSTEM details added");
            [self setSystemFilter:name];
            
        } else {
            NSLog(@"Failed to add SYSTEM Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (NSString *) getSelectedSystemDetails
{
    NSString * result = [[NSString alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM SYSTEM"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                result = [[NSString alloc]
                          initWithUTF8String:
                          (const char *) sqlite3_column_text(statement, 0)];
                NSLog(@"SYSTEM details found");
            }
            else
            {
                NSLog(@"No SYSTEM details found in DB");
                return nil;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return result;
}

- (void) deleteSystemDetails {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM SYSTEM"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"SYSTEM details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}

- (NSMutableArray *) getAllChildrenForAssetId:(NSString* )assetId
{
    NSMutableArray* arr  = [[NSMutableArray alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        //        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM DOWNLOADS WHERE assetName LIKE '%%%@%%'",offlineText];
        
        
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM DOWNLOADS WHERE parentId = '%@'",assetId];
        
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] forKey:@"Id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)] forKey:@"Name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)] forKey:@"Plant__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)] forKey:@"SHORT_DESCRIPTION__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)] forKey:@"Tag__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)] forKey:@"Plant__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 6)] forKey:@"PARENT_ASSET__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 7)] forKey:@"PARENT_ASSET__Name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 8)] forKey:@"isAuditCompleted"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 9)] forKey:@"Make__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 10)] forKey:@"TYPE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 11)] forKey:@"UNABLE_TO_LOCATE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 14)] forKey:@"OPERATOR_TYPE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 17)] forKey:@"CONDITION__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 18)] forKey:@"Class__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 19)] forKey:@"Class__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 20)] forKey:@"Category__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 21)] forKey:@"Category__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 22)] forKey:@"SubClass__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 23)] forKey:@"SubClass__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 24)] forKey:@"PUNCH_LIST__c"];
                
                [arr addObject:dict];
                NSLog(@"Searched Children Asset found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return arr;
}

- (NSMutableDictionary *) getAllParentForAssetId:(NSString* )assetId
{
    NSMutableDictionary* dict  = [[NSMutableDictionary alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        //        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM DOWNLOADS WHERE assetName LIKE '%%%@%%'",offlineText];
        
        
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM DOWNLOADS WHERE assetId = '%@'",assetId];
        
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] forKey:@"Id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)] forKey:@"Name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)] forKey:@"Plant__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)] forKey:@"Short_description__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)] forKey:@"Tag__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)] forKey:@"Plant__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 6)] forKey:@"PARENT_ASSET__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 7)] forKey:@"PARENT_ASSET__Name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 8)] forKey:@"isAuditCompleted"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 9)] forKey:@"Make__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 10)] forKey:@"TYPE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 11)] forKey:@"UNABLE_TO_LOCATE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 14)] forKey:@"OPERATOR_TYPE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 17)] forKey:@"CONDITION__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 18)] forKey:@"Class__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 19)] forKey:@"Class__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 20)] forKey:@"Category__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 21)] forKey:@"Category__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 22)] forKey:@"SubClass__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 23)] forKey:@"SubClass__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 24)] forKey:@"PUNCH_LIST__c"];
                
                NSLog(@"Searched Children Asset found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return dict;
}

- (void) saveSelectedSetDetailsWithName:(NSString *)name andSetId:(NSString *)setId
{
    [self deleteSelectedSetDetails];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO SELECTEDSET VALUES (\"%@\", \"%@\")",setId,name];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New SELECTEDSET details added");
        } else {
            NSLog(@"Failed to add SELECTEDSET Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (NSMutableDictionary *) getSelectedSetDetails
{
    NSMutableDictionary * result = [[NSMutableDictionary alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM SELECTEDSET"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                [result setObject:[[NSString alloc]
                                  initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 0)] forKey:@"Id"];
                [result setObject:[[NSString alloc]
                                   initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 1)] forKey:@"Name"];
                NSLog(@"SELECTEDSET details found");
            }
            else
            {
                NSLog(@"No SELECTEDSET details found in DB");
                return nil;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return result;
}

- (void) deleteSelectedSetDetails {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM SELECTEDSET"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"SELECTEDSET details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}

- (NSMutableArray *) getAllDownloadedAssetsWithAuditUncompleted
{
    NSMutableArray* arr  = [[NSMutableArray alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        //        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM DOWNLOADS WHERE assetName LIKE '%%%@%%'",offlineText];
        
        NSString* filterString = [self getOfflineFilterQueryString:2];
        
        
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM DOWNLOADS WHERE TRIM(locationList) > '' AND (isAuditCompleted = '0') and assetId NOT IN (SELECT assetId from ASSETS WHERE uploaded = 0) %@ ORDER BY sequence, assetName COLLATE NOCASE", filterString];
        
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] forKey:@"Id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)] forKey:@"Name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)] forKey:@"Plant__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)] forKey:@"SHORT_DESCRIPTION__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)] forKey:@"Tag__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)] forKey:@"Plant__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 6)] forKey:@"PARENT_ASSET__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 7)] forKey:@"PARENT_ASSET__Name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 8)] forKey:@"isAuditCompleted"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 9)] forKey:@"Make__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 10)] forKey:@"TYPE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 11)] forKey:@"UNABLE_TO_LOCATE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 14)] forKey:@"OPERATOR_TYPE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 17)] forKey:@"CONDITION__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 18)] forKey:@"Class__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 19)] forKey:@"Class__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 20)] forKey:@"Category__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 21)] forKey:@"Category__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 22)] forKey:@"SubClass__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 23)] forKey:@"SubClass__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 24)] forKey:@"PUNCH_LIST__c"];
                
                [arr addObject:dict];
                NSLog(@"Downloaded Asset found");
            }
            sqlite3_finalize(statement);
        }
        else {
            NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(assetDB));
        }
        sqlite3_close(assetDB);
    }
    return arr;
}

- (NSMutableArray *) getAllDownloadedAssetsWithAuditCompleted
{
    NSMutableArray* arr  = [[NSMutableArray alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        //        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM DOWNLOADS WHERE assetName LIKE '%%%@%%'",offlineText];
        
        NSString* filterString = [self getOfflineFilterQueryString:2];
        
        
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM DOWNLOADS WHERE TRIM(locationList) > '' AND (isAuditCompleted = '1') %@ ORDER BY sequence, assetName COLLATE NOCASE", filterString];
        
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] forKey:@"Id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)] forKey:@"Name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)] forKey:@"Plant__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)] forKey:@"SHORT_DESCRIPTION__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)] forKey:@"Tag__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)] forKey:@"Plant__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 6)] forKey:@"PARENT_ASSET__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 7)] forKey:@"PARENT_ASSET__Name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 8)] forKey:@"isAuditCompleted"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 9)] forKey:@"Make__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 10)] forKey:@"TYPE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 11)] forKey:@"UNABLE_TO_LOCATE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 14)] forKey:@"OPERATOR_TYPE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 17)] forKey:@"CONDITION__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 18)] forKey:@"Class__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 19)] forKey:@"Class__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 20)] forKey:@"Category__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 21)] forKey:@"Category__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 22)] forKey:@"SubClass__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 23)] forKey:@"SubClass__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 24)] forKey:@"PUNCH_LIST__c"];
                
                [arr addObject:dict];
                NSLog(@"Downloaded Asset found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return arr;
}

- (NSMutableArray *) getAllAssetsForOfflineTextWithAuditCompleted:(NSString* )offlineText
{
    NSMutableArray* arr  = [[NSMutableArray alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        //        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM DOWNLOADS WHERE assetName LIKE '%%%@%%'",offlineText];
        
        NSString* filterString = [self getOfflineFilterQueryString:2];
        
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM DOWNLOADS WHERE (isAuditCompleted = '1') AND (assetName LIKE '%%%@%%' or plantName LIKE '%%%@%%' or description LIKE '%%%@%%' or tag LIKE '%%%@%%' or plantId LIKE '%%%@%%' or parentId LIKE '%%%@%%' or make LIKE '%%%@%%' or type LIKE '%%%@%%') %@ ORDER BY sequence, assetName COLLATE NOCASE",offlineText,offlineText,offlineText,offlineText,offlineText,offlineText,offlineText,offlineText, filterString];
        
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] forKey:@"Id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)] forKey:@"Name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)] forKey:@"Plant__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)] forKey:@"Short_description__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)] forKey:@"Tag__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)] forKey:@"Plant__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 6)] forKey:@"PARENT_ASSET__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 7)] forKey:@"PARENT_ASSET__Name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 8)] forKey:@"isAuditCompleted"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 9)] forKey:@"Make__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 10)] forKey:@"TYPE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 11)] forKey:@"UNABLE_TO_LOCATE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 14)] forKey:@"OPERATOR_TYPE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 17)] forKey:@"CONDITION__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 18)] forKey:@"Class__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 19)] forKey:@"Class__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 20)] forKey:@"Category__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 21)] forKey:@"Category__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 22)] forKey:@"SubClass__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 23)] forKey:@"SubClass__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 24)] forKey:@"PUNCH_LIST__c"];
                
                [arr addObject:dict];
                NSLog(@"Searched Asset found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return arr;
}

/*- (void) saveIACDetailsWithName:(NSString *)name
{
    [self deleteIACDetails];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO SELECTEDIAC VALUES (\"%@\")",name];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New IAC details added");
        } else {
            NSLog(@"Failed to add IAC Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (NSString *) getSelectedIACDetails
{
    NSString * result = [[NSString alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM SELECTEDIAC"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                result = [[NSString alloc]
                          initWithUTF8String:
                          (const char *) sqlite3_column_text(statement, 0)];
                NSLog(@"IAC details found");
            }
            else
            {
                NSLog(@"No IAC details found in DB");
                return @"False";
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return result;
}

- (void) deleteIACDetails {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM SELECTEDIAC"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"IAC details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}*/

- (void) saveIsSearchOnSetWithValue:(BOOL)val
{
    [self deleteIsSearchOnSetDetails];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO ISSEARCHONSET VALUES (\"%d\")",val];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New IsSearchOnSet details added");
        } else {
            NSLog(@"Failed to add IsSearchOnSet Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (BOOL) getIsSearchOnSetDetails
{
    BOOL result;
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM ISSEARCHONSET"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                result = [[[NSString alloc]
                          initWithUTF8String:
                          (const char *) sqlite3_column_text(statement, 0)] boolValue];
                NSLog(@"IsSearchOnSet details found");
            }
            else
            {
                NSLog(@"No IsSearchOnSet details found in DB");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return result;
}

- (void) deleteIsSearchOnSetDetails {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM ISSEARCHONSET"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"IsSearchOnSet details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}

- (void) saveOperatorTypeDetailsWithValue:(NSString *)value andDescription:(NSString *)desc
{
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO OPERATORTYPE VALUES (\"%@\", \"%@\")",value,desc];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New OPERATORTYPE details added");
            
        } else {
            NSLog(@"Failed to add OPERATORTYPE Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (NSMutableArray *) getSelectedOpearatorTypeDetails
{
    NSMutableArray * result = [[NSMutableArray alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM OPERATORTYPE"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                [dict setObject:[[NSString alloc]
                                 initWithUTF8String:
                                 (const char *) sqlite3_column_text(statement, 0)] forKey:@"value" ];
                
                [dict setObject:[[NSString alloc]
                                 initWithUTF8String:
                                 (const char *) sqlite3_column_text(statement, 1)] forKey:@"description" ];
                [result addObject:dict];
                NSLog(@"OPERATORTYPE details found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return result;
}

- (void) deleteOperatorTypeDetails {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM OPERATORTYPE"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"OPERATORTYPE details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}

- (void) saveCriticalityDetailsWithName:(NSString *)name
{
    [self deleteCriticalityDetails];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO CRITICALITY VALUES (\"%@\")",name];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New CRITICALITY details added");
            [self setCriticalityFilter:name];
        } else {
            NSLog(@"Failed to add CRITICALITY Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (NSString *) getSelectedCriticalityDetails
{
    NSString * result = [[NSString alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM CRITICALITY"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                result = [[NSString alloc]
                          initWithUTF8String:
                          (const char *) sqlite3_column_text(statement, 0)];
                NSLog(@"CRITICALITY details found");
            }
            else
            {
                NSLog(@"No CRITICALITY details found in DB");
                return nil;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return result;
}

- (void) deleteCriticalityDetails {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM CRITICALITY"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"CRITICALITY details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}

- (void) saveSourceDocsDetailsWithName:(NSString *)name
{
    [self deleteSourceDocsDetails];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO SOURCEDOCS VALUES (\"%@\")",name];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New SOURCEDOCS details added");
            [self setSourceDocFilter:name];
        } else {
            NSLog(@"Failed to add SOURCEDOCS Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (NSString *) getSelectedSourceDocsDetails
{
    NSString * result = [[NSString alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM SOURCEDOCS"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                result = [[NSString alloc]
                          initWithUTF8String:
                          (const char *) sqlite3_column_text(statement, 0)];
                NSLog(@"SOURCEDOCS details found");
            }
            else
            {
                NSLog(@"No SOURCEDOCS details found in DB");
                return nil;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return result;
}

- (void) deleteSourceDocsDetails {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM SOURCEDOCS"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"SOURCEDOCS details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}

- (int) getAssetDataCount
{
    int count = 0;
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT count(assetId) FROM ASSETS WHERE uploaded = 0"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                count = [[[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)] intValue];
                NSLog(@"%d Assets found",count);
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return count;
}

//- (NSMutableArray *) getPendingAuditData
//{
//    NSMutableArray* arr  = [[NSMutableArray alloc] init];
//    AuditData * auditData;
//    
//    const char *dbpath = [databasePath UTF8String];
//    sqlite3_stmt    *statement;
//    sqlite3 *assetDB;
//    
//    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
//    {
//        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM AUDITS WHERE assetId NOT IN (SELECT assetId from ASSETS)"];
//        
//        const char *query_stmt = [querySQL UTF8String];
//        
//        if (sqlite3_prepare_v2(assetDB,
//                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
//        {
//            while (sqlite3_step(statement) == SQLITE_ROW)
//            {
//                auditData = [[AuditData alloc] init];
//                auditData.auditId = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
//                
//                auditData.assetId = [[NSString alloc]
//                                     initWithUTF8String:(const char *)
//                                     sqlite3_column_text(statement, 1)];
//                auditData.assetName = [[NSString alloc]
//                                       initWithUTF8String:(const char *)
//                                       sqlite3_column_text(statement, 2)];
//                auditData.auditType = [[NSString alloc]
//                                       initWithUTF8String:(const char *)
//                                       sqlite3_column_text(statement, 3)];
//                auditData.imgURL = [[NSString alloc]
//                                    initWithUTF8String:(const char *)
//                                    sqlite3_column_text(statement, 4)];
//                auditData.dateTime = [[NSString alloc]
//                                      initWithUTF8String:(const char *)
//                                      sqlite3_column_text(statement, 5)];
//                auditData.latitude = [[[NSString alloc]
//                                       initWithUTF8String:(const char *)
//                                       sqlite3_column_text(statement, 6)] floatValue];
//                auditData.longitude = [[[NSString alloc]
//                                        initWithUTF8String:(const char *)
//                                        sqlite3_column_text(statement, 7)] floatValue];
//                auditData.altitude = [[[NSString alloc]
//                                       initWithUTF8String:(const char *)
//                                       sqlite3_column_text(statement, 8)] floatValue];
//                [arr addObject:auditData];
//                NSLog(@"Audit found");
//            }
//            sqlite3_finalize(statement);
//        }
//        sqlite3_close(assetDB);
//    }
//    return arr;
//}


- (NSMutableArray *) getPendingAuditData
{
    NSMutableArray* arr  = [[NSMutableArray alloc] init];
    AuditData * auditData;
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM AUDITS WHERE uploaded = 0"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                auditData = [[AuditData alloc] init];
                auditData.auditId = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
                
                auditData.assetId = [[NSString alloc]
                                     initWithUTF8String:(const char *)
                                     sqlite3_column_text(statement, 1)];
                auditData.assetName = [[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 2)];
                auditData.auditType = [[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 3)];
                auditData.imgURL = [[NSString alloc]
                                    initWithUTF8String:(const char *)
                                    sqlite3_column_text(statement, 4)];
                auditData.dateTime = [[NSString alloc]
                                      initWithUTF8String:(const char *)
                                      sqlite3_column_text(statement, 5)];
                auditData.latitude = [[[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 6)] floatValue];
                auditData.longitude = [[[NSString alloc]
                                        initWithUTF8String:(const char *)
                                        sqlite3_column_text(statement, 7)] floatValue];
                auditData.altitude = [[[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 8)] floatValue];
                [arr addObject:auditData];
                NSLog(@"Audit found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return arr;
}



- (void) saveSyncRecordsWithValue:(BOOL)val
{
    [self deleteSyncRecordsDetails];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO SYNCRECORDS VALUES (\"%d\")",val];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New SYNCRECORDS details added");
        } else {
            NSLog(@"Failed to add SYNCRECORDS Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (BOOL) getSyncRecordsDetails
{
    BOOL result;
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM SYNCRECORDS"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                result = [[[NSString alloc]
                           initWithUTF8String:
                           (const char *) sqlite3_column_text(statement, 0)] boolValue];
                NSLog(@"SYNCRECORDS details found");
            }
            else
            {
                NSLog(@"No SYNCRECORDS details found in DB");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return result;
}

- (void) deleteSyncRecordsDetails {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM SYNCRECORDS"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"SYNCRECORDS details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}



-(NSString *) getOfflineFilterQueryString:(int) type {
    
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    if (![plantSectionFilter isEqualToString:@""]) {
        [arr addObject:[NSString stringWithFormat:@"plantSection LIKE '%%%@%%'",plantSectionFilter]];
    }
    if (![systemFilter isEqualToString:@""]) {
        [arr addObject:[NSString stringWithFormat:@"system LIKE '%%%@%%'",systemFilter]];
    }
    if (![criticalityFilter isEqualToString:@""]) {
        [arr addObject:[NSString stringWithFormat:@"criticality LIKE '%%%@%%'",criticalityFilter]];
    }
    if (![sourceDocFilter isEqualToString:@""]) {
        [arr addObject:[NSString stringWithFormat:@"sourceDocs LIKE '%%%@%%'",sourceDocFilter]];
    }
    
    NSString* queryStr = @"";
    
    if ([arr count]>0) {
        queryStr = [arr componentsJoinedByString:@" AND "];
        if (type == 1 ) {
            NSString* tmp = [NSString stringWithFormat:@"WHERE (%@)",queryStr];
            queryStr = tmp;
        }
        if (type == 2 ) {
            NSString* tmp = [NSString stringWithFormat:@"AND (%@)",queryStr];
            queryStr = tmp;
        }
    }
    
    return queryStr;
    
}


-(NSMutableArray *) getAllTodayAssets {
    
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString* date = [self GetCurrentDate];
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM ASSETS WHERE uploaded = 0 AND createdDate LIKE '%@-%@-%@%%'",[[date componentsSeparatedByString:@"-"] objectAtIndex:0],[[date componentsSeparatedByString:@"-"] objectAtIndex:1],[[date componentsSeparatedByString:@"-"] objectAtIndex:2]];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] forKey:@"Id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)] forKey:@"Name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)] forKey:@"Plant__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)] forKey:@"SHORT_DESCRIPTION__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)] forKey:@"TAG__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)] forKey:@"Plant__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 6)] forKey:@"PARENT_ASSET__Name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 7)] forKey:@"TYPE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 8)] forKey:@"isNewAsset"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 9)] forKey:@"PARENT_ASSET__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 11)] forKey:@"CONDITION__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 12)] forKey:@"OPERATOR_TYPE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 13)] forKey:@"Class__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 14)] forKey:@"Class__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 15)] forKey:@"Category__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 16)] forKey:@"Category__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 17)] forKey:@"SubClass__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 18)] forKey:@"SubClass__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 19)] forKey:@"UNABLE_TO_LOCATE__c"];
                
                
            
                [arr addObject:dict];
                NSLog(@"Asset found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }

    
    return arr;
    
}

- (NSMutableArray *) getAllAuditData
{
    NSMutableArray* arr  = [[NSMutableArray alloc] init];
    AuditData * auditData;
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM AUDITS"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                auditData = [[AuditData alloc] init];
                auditData.auditId = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
                
                auditData.assetId = [[NSString alloc]
                                     initWithUTF8String:(const char *)
                                     sqlite3_column_text(statement, 1)];
                auditData.assetName = [[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 2)];
                auditData.auditType = [[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 3)];
                auditData.imgURL = [[NSString alloc]
                                    initWithUTF8String:(const char *)
                                    sqlite3_column_text(statement, 4)];
                auditData.dateTime = [[NSString alloc]
                                      initWithUTF8String:(const char *)
                                      sqlite3_column_text(statement, 5)];
                auditData.latitude = [[[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 6)] floatValue];
                auditData.longitude = [[[NSString alloc]
                                        initWithUTF8String:(const char *)
                                        sqlite3_column_text(statement, 7)] floatValue];
                auditData.altitude = [[[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 8)] floatValue];
                auditData.isUploaded = [[[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 9)] boolValue];
                [arr addObject:auditData];
                NSLog(@"Audit found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return arr;
}


- (void) saveConditionsWithValue:(NSString *)val andDescription:(NSString *)desc
{
    //[self deleteConditionsDetails];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO CONDITIONS VALUES (\"%@\", \"%@\")",val,desc];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New CONDITIONS details added");
        } else {
            NSLog(@"Failed to add CONDITIONS Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (NSMutableArray *) getConditionsDetails
{
    
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM CONDITIONS"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
                
                [result setObject:[[NSString alloc]
                                    initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 0)] forKey:@"value"] ;
                [result setObject:[[NSString alloc]
                                   initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 1)] forKey:@"description"] ;
                
                [arr addObject:result];
                
                NSLog(@"CONDITIONS details found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return arr;
}

- (void) deleteConditionsDetails {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM CONDITIONS"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"CONDITIONS details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}



- (void) saveTodayAssets:(NSMutableArray *)downloadDict
{
    
    [self deleteTodayDetails];
    
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        for (int i = 0; i<[downloadDict count] ; i++) {
            NSDictionary* currentAsset = [downloadDict objectAtIndex:i];
            NSString *insertSQL = [NSString stringWithFormat:
                                   @"INSERT INTO TODAY VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%d\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
                                   [currentAsset valueForKey:@"Id"], [currentAsset valueForKey:@"Name"],[currentAsset valueForKey:@"Plant__name"],[currentAsset valueForKey:@"SHORT_DESCRIPTION__c"],[currentAsset valueForKey:@"TAG__c"],[currentAsset valueForKey:@"Plant__id"],[currentAsset valueForKey:@"PARENT_ASSET__c"], [currentAsset valueForKey:@"PARENT_ASSET__Name"],[currentAsset valueForKey:@"MAKE__c"],[currentAsset valueForKey:@"TYPE__c"],[[currentAsset valueForKey:@"UNABLE_TO_LOCATE__c"] boolValue],[currentAsset valueForKey:@"CONDITION__c"],[currentAsset valueForKey:@"Iphone_Asset_Id__c"],[currentAsset valueForKey:@"OPERATOR_TYPE__c"],[currentAsset valueForKey:@"Class__name"],[currentAsset valueForKey:@"Class__id"],[currentAsset valueForKey:@"Category__name"],[currentAsset valueForKey:@"Category__id"],[currentAsset valueForKey:@"SubClass__name"],[currentAsset valueForKey:@"SubClass__id"]];
            
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(assetDB, insert_stmt,
                               -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                NSLog(@"New Today asset added");
            } else {
                NSLog(@"Failed to add Today asset");
            }
            sqlite3_finalize(statement);
        }
        
        sqlite3_close(assetDB);
    }
}

- (NSMutableArray *) getOfflineTodayDetails
{
    
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM TODAY"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] forKey:@"Id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)] forKey:@"Name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)] forKey:@"Plant__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)] forKey:@"SHORT_DESCRIPTION__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)] forKey:@"TAG__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)] forKey:@"Plant__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 6)] forKey:@"parentId"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 7)] forKey:@"PARENT_ASSET__Name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 9)] forKey:@"Make__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 9)] forKey:@"TYPE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 10)] forKey:@"UNABLE_TO_LOCATE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 11)] forKey:@"CONDITION__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 12)] forKey:@"Iphone_Asset_Id__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 13)] forKey:@"OPERATOR_TYPE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 14)] forKey:@"Class__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 15)] forKey:@"Class__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 16)] forKey:@"Category__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 17)] forKey:@"Category__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 18)] forKey:@"SubClass__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 19)] forKey:@"SubClass__id"];
                
                
                [arr addObject:dict];
                NSLog(@"Today Asset found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    
    
    return arr;
}

- (void) deleteTodayDetails {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM TODAY"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"TODAY details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}


- (void) saveOperatorClassWithValue:(NSString *)val andDescription:(NSString *)desc andID:(NSString *)ident andClass:(NSString *)class1
{
    //[self deleteConditionsDetails];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO OPERATORCLASS VALUES (\"%@\", \"%@\", \"%@\", \"%@\")",val,desc,class1,ident];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New OPERATORCLASS details added");
        } else {
            NSLog(@"Failed to add OPERATORCLASS Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (NSMutableArray *) getOperatorClassDetails
{
    
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM OPERATORCLASS"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
                
                [result setObject:[[NSString alloc]
                                   initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 0)] forKey:@"value"] ;
                [result setObject:[[NSString alloc]
                                   initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 1)] forKey:@"description"] ;
                [result setObject:[[NSString alloc]
                                   initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 2)] forKey:@"class"] ;
                [result setObject:[[NSString alloc]
                                   initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 3)] forKey:@"id"] ;
                
                [arr addObject:result];
                
                NSLog(@"OPERATORCLASS details found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return arr;
}

- (void) deleteOperatorClassDetails {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM OPERATORCLASS"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"OPERATORCLASS details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}



- (void) saveCategoryWithValue:(NSString *)val andId:(NSString *)ident andCategory:(NSString *)category
{
    //[self deleteConditionsDetails];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO CATEGORY VALUES (\"%@\",\"%@\",\"%@\")",val,category,ident];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New CATEGORY details added");
        } else {
            NSLog(@"Failed to add CATEGORY Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (NSMutableArray *) getCategoryDetails
{
    
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM CATEGORY"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
                
                [result setObject:[[NSString alloc]
                                   initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 0)] forKey:@"value"] ;
                [result setObject:[[NSString alloc]
                                   initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 1)] forKey:@"category"] ;
                [result setObject:[[NSString alloc]
                                   initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 2)] forKey:@"id"] ;
                
                
                [arr addObject:result];
                
                NSLog(@"CATEGORY details found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return arr;
}

- (void) deleteCategoryDetails {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM CATEGORY"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"CATEGORY details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}


- (void) saveOperatorSubclassWithValue:(NSString *)val andDescription:(NSString *)desc andId:(NSString *)ident
{
    //[self deleteConditionsDetails];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO OPERATORSUBCLASS VALUES (\"%@\", \"%@\", \"%@\")",val,desc,ident];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New OPERATORSUBCLASS details added");
        } else {
            NSLog(@"Failed to add OPERATORSUBCLASS Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (NSMutableArray *) getOperatorSubclassDetails
{
    
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM OPERATORSUBCLASS"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
                
                [result setObject:[[NSString alloc]
                                   initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 0)] forKey:@"value"] ;
                [result setObject:[[NSString alloc]
                                   initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 1)] forKey:@"description"] ;
                [result setObject:[[NSString alloc]
                                   initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 2)] forKey:@"id"] ;
                
                [arr addObject:result];
                
                NSLog(@"OPERATORSUBCLASS details found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return arr;
}

- (void) deleteOperatorSubclassDetails {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM OPERATORSUBCLASS"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"OPERATORSUBCLASS details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}

- (void) saveAssetCodingOptionsForCondition:(BOOL)con andOperatorType:(BOOL)opType andOperatorClass:(BOOL)opClass andOperatorSubclass:(BOOL)opSub andCategory:(BOOL)category andType:(BOOL)type
{
    [self deleteAssetCodingData];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO ASSETCODING VALUES (\"%d\", \"%d\", \"%d\", \"%d\", \"%d\", \"%d\")",con, opType, opClass, opSub, category,type];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New ASSETCODING details added");
        } else {
            NSLog(@"Failed to add ASSETCODING Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (NSMutableArray *) getAssetCodingOptions
{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM ASSETCODING"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                [result addObject:[[NSString alloc]
                           initWithUTF8String:
                           (const char *) sqlite3_column_text(statement, 0)]];
                [result addObject:[[NSString alloc]
                                   initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 1)]];
                [result addObject:[[NSString alloc]
                                   initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 2)]];
                [result addObject:[[NSString alloc]
                                   initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 3)]];
                [result addObject:[[NSString alloc]
                                   initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 4)]];
                [result addObject:[[NSString alloc]
                                   initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 5)]];
                
                
                NSLog(@"ASSETCODING details found");
            }
            else
            {
                NSLog(@"No ASSETCODING details found in DB");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return result;
}

- (void) deleteAssetCodingData {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM ASSETCODING"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"ASSETCODING details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}


// ----------------------------------------------------------------------- v5.0 --------------------------------------------------------------------------------


- (void) saveSeletedConnectionDetailsWithName:(NSString *)name
{
    [self deleteSelectedConnectionDetails];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO SELECTEDCONNECTION VALUES (\"%@\")",name];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New Connection details added");
            [self setSelectedTypeSettings:name];
        } else {
            NSLog(@"Failed to add Connection Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (NSString *) getSelectedConnectionDetails
{
    NSString * result = [[NSString alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM SELECTEDCONNECTION"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                result = [[NSString alloc]
                          initWithUTF8String:
                          (const char *) sqlite3_column_text(statement, 0)];
                NSLog(@"Connection details found");
            }
            else
            {
                NSLog(@"No Connection details found in DB");
                return nil;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return result;
}

- (void) deleteSelectedConnectionDetails {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM SELECTEDCONNECTION"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"Conenction details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}


- (NSMutableArray *) getAllAssetsForOfflineTextinStandaloneMode:(NSString* )offlineText
{
    NSMutableArray* arr  = [[NSMutableArray alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        //        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM DOWNLOADS WHERE assetName LIKE '%%%@%%'",offlineText];
        //NSString* filterString = [self getOfflineFilterQueryString:2];
        
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM ASSETS WHERE (assetName LIKE '%%%@%%' or plantName LIKE '%%%@%%' or description LIKE '%%%@%%' or tag LIKE '%%%@%%' or plantId LIKE '%%%@%%' or parentId LIKE '%%%@%%' or type LIKE '%%%@%%') AND uploaded = 0 ORDER BY sequence, assetName COLLATE NOCASE",offlineText,offlineText,offlineText,offlineText,offlineText,offlineText,offlineText];
        
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                
                
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] forKey:@"Id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)] forKey:@"Name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)] forKey:@"Plant__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)] forKey:@"Short_description__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)] forKey:@"Tag__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)] forKey:@"Plant__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 6)] forKey:@"PARENT_ASSET__Name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 7)] forKey:@"TYPE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 8)] forKey:@"isNewAsset"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 9)] forKey:@"PARENT_ASSET__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 11)] forKey:@"CONDITION__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 12)] forKey:@"OPERATOR_TYPE__c"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 13)] forKey:@"Class__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 14)] forKey:@"Class__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 15)] forKey:@"Category__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 16)] forKey:@"Category__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 17)] forKey:@"SubClass__name"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 18)] forKey:@"SubClass__id"];
                [dict setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 19)] forKey:@"UNABLE_TO_LOCATE__c"];
                
                
                [arr addObject:dict];
                NSLog(@"Searched Asset found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return arr;
}


- (int) getDownloadDataCount
{
    int count = 0;
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT count(assetId) FROM DOWNLOADS"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                count = [[[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)] intValue];
                NSLog(@"%d Asset found",count);
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return count;
}


- (int) getDownloadDataCountForPunchList
{
    int count = 0;
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT count(assetId) FROM DOWNLOADS where punchList = 1"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                count = [[[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)] intValue];
                NSLog(@"%d Asset found",count);
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return count;
}




- (void) saveLockRecordsWithValue:(BOOL)val
{
    [self deleteLockcRecordsDetails];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO LOCKRECORDS VALUES (\"%d\")",val];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New LOCKRECORDS details added");
        } else {
            NSLog(@"Failed to add LOCKRECORDS Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (BOOL) getLockRecordsDetails
{
    BOOL result;
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM LOCKRECORDS"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                result = [[[NSString alloc]
                           initWithUTF8String:
                           (const char *) sqlite3_column_text(statement, 0)] boolValue];
                NSLog(@"LOCKRECORDS details found");
            }
            else
            {
                NSLog(@"No LOCKRECORDS details found in DB");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return result;
}

- (void) deleteLockcRecordsDetails {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM LOCKRECORDS"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"LOCKRECORDS details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}





- (void) savePunchListWithValue:(BOOL)val
{
    [self deletePunchListDetails];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO SEARCHPUNCHLIST VALUES (\"%d\")",val];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New SEARCHPUNCHLIST details added");
        } else {
            NSLog(@"Failed to add SEARCHPUNCHLIST Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (BOOL) getPunchListDetails
{
    BOOL result;
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM SEARCHPUNCHLIST"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                result = [[[NSString alloc]
                           initWithUTF8String:
                           (const char *) sqlite3_column_text(statement, 0)] boolValue];
                NSLog(@"SEARCHPUNCHLIST details found");
            }
            else
            {
                NSLog(@"No SEARCHPUNCHLIST details found in DB");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return result;
}

- (void) deletePunchListDetails {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM SEARCHPUNCHLIST"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"SEARCHPUNCHLIST details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}


- (void) saveForceOfflineWithValue:(BOOL)val
{
    [self deleteForceOfflineDetails];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO FORCEOFFLINE VALUES (\"%d\")",val];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New FORCEOFFLINE details added");
        } else {
            NSLog(@"Failed to add FORCEOFFLINE Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (BOOL) getForceOfflineDetails
{
    BOOL result;
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM FORCEOFFLINE"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                result = [[[NSString alloc]
                           initWithUTF8String:
                           (const char *) sqlite3_column_text(statement, 0)] boolValue];
                NSLog(@"FORCEOFFLINE details found");
            }
            else
            {
                NSLog(@"No FORCEOFFLINE details found in DB");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return result;
}

- (void) deleteForceOfflineDetails {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM FORCEOFFLINE"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"FORCEOFFLINE details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}



- (void) saveAssetCountWithToday:(NSString *)today andTODO:(NSString *)todo andDone:(NSString *)done
{
    [self deleteAssetCountDetails];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO ASSETCOUNT VALUES (\"%@\",\"%@\",\"%@\")",today,todo,done];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New ASSETCOUNT details added");
        } else {
            NSLog(@"Failed to add ASSETCOUNT Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (NSMutableDictionary *) getAssetCountDetails
{
    NSMutableDictionary * result = [[NSMutableDictionary alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM ASSETCOUNT"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                [result setObject: [[NSString alloc]
                                   initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 0)] forKey:@"Today"] ;
                [result setObject: [[NSString alloc]
                                    initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 1)] forKey:@"Todo"] ;
                [result setObject: [[NSString alloc]
                                    initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 2)] forKey:@"Done"] ;
                NSLog(@"ASSETCOUNT details found");
            }
            else
            {
                NSLog(@"No ASSETCOUNT details found in DB");
                return nil;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return result;
}

- (void) deleteAssetCountDetails {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM ASSETCOUNT"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"ASSETCOUNT details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}



//AUDITTYPE

- (void) saveAuditTypeForId:(NSString *)auditId andName:(NSString *)name andOrder:(NSString *)order
{
    //[self deleteAuditTypeDetails];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO AUDITTYPE VALUES (\"%@\",\"%@\",\"%@\")",auditId,name,order];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New AUDITTYPE details added");
        } else {
            NSLog(@"Failed to add AUDITTYPE Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (NSMutableArray *) getAllAuditTypes
{
    NSMutableArray* arr  = [[NSMutableArray alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM AUDITTYPE ORDER BY orderNo asc"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableDictionary* auditData = [[NSMutableDictionary alloc] init];
                
                [auditData setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] forKey:@"Id"];
                [auditData setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)] forKey:@"Name"];
                [auditData setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)] forKey:@"ORDER__c"];
                
                
                [arr addObject:auditData];
                
                NSLog(@"AUDITTYPE found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return arr;
}

- (void) deleteAuditTypeDetails {
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM AUDITTYPE"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"AUDITTYPE details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}


//DYNAMICLABELS

- (void) saveDynamicLabelValues:(NSMutableDictionary *)responseDict
{
    [self deleteDynamicLabelValues];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO DYNAMICLABEL VALUES (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",[responseDict valueForKey:@"ASSET_CODING"],[responseDict valueForKey:@"ASSET_NAME"],[responseDict valueForKey:@"CONDITION"],[responseDict valueForKey:@"CRITICALITY"],[responseDict valueForKey:@"FILTER"],[responseDict valueForKey:@"LISTS"],[responseDict valueForKey:@"OPERATOR_TYPE"],[responseDict valueForKey:@"PLANT"],[responseDict valueForKey:@"PLANT_SECTION"],[responseDict valueForKey:@"SOURCE_DOCUMENTS"],[responseDict valueForKey:@"SYSTEM"],[responseDict valueForKey:@"TAG"],[responseDict valueForKey:@"UNABLE_TO_LOCATE"]];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(assetDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"New DYNAMICLABEL details added");
        } else {
            NSLog(@"Failed to add DYNAMICLABEL Details");
        }
        sqlite3_finalize(statement);
        sqlite3_close(assetDB);
    }
}

- (NSMutableDictionary *) getAllDynamicLabelValues
{
    NSMutableDictionary* auditData = [[NSMutableDictionary alloc] init];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM DYNAMICLABEL"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                
                [auditData setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] forKey:@"ASSET_CODING"];
                [auditData setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)] forKey:@"ASSET_NAME"];
                [auditData setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)] forKey:@"CONDITION"];
                [auditData setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)] forKey:@"CRITICALITY"];
                [auditData setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)] forKey:@"FILTER"];
                [auditData setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)] forKey:@"LISTS"];
                [auditData setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 6)] forKey:@"OPERATOR_TYPE"];
                [auditData setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 7)] forKey:@"PLANT"];
                [auditData setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 8)] forKey:@"PLANT_SECTION"];
                [auditData setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 9)] forKey:@"SOURCE_DOCUMENTS"];
                [auditData setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 10)] forKey:@"SYSTEM"];
                [auditData setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 11)] forKey:@"TAG"];
                [auditData setObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 12)] forKey:@"UNABLE_TO_LOCATE"];
                

                
                NSLog(@"DYNAMICLABEL found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(assetDB);
    }
    return auditData;
}

- (void) deleteDynamicLabelValues {
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM DYNAMICLABEL"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"DYNAMICLABEL details deleted");
        }
        sqlite3_close(assetDB);
    }
    
}


- (void) updateUploadStatusForAuditId:(NSString *)auditId {
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"UPDATE AUDITS SET uploaded = 1 WHERE auditId = '%@'",auditId];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"AUDIT UPLOAD STATUS UPDATED");
        }
        sqlite3_close(assetDB);
    }
    
}


- (void) updateUploadStatusForAssetId:(NSString *)assetId {
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    sqlite3 *assetDB;
    
    if (sqlite3_open(dbpath, &assetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"UPDATE ASSETS SET uploaded = 1 WHERE assetId = '%@'",assetId];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(assetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            NSLog(@"ASSET UPLOAD STATUS UPDATED");
        }
        sqlite3_close(assetDB);
    }
    
}

@end
