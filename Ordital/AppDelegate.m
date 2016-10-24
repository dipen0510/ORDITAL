//
//  AppDelegate.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 20/09/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "AppDelegate.h"
#import "DataManager.h"

#import <AWSCore/AWSCore.h>
#import <DropboxSDK/DropboxSDK.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [[DataManager sharedManager] setupDatabase];
    
    if ([[DataManager sharedManager] getAuthToken])
    {
        [[DataManager sharedManager] setIsLoggedIn:true];
    }
    else {
        [[DataManager sharedManager] setIsLoggedIn:false];
    }
    [[DataManager sharedManager] setSelectedPlantSettings:[[DataManager sharedManager] getSelectedPlantDetails]];
    [[DataManager sharedManager] setSelectedEnvironmentSettings:[[DataManager sharedManager] getSelectedEnvironmentDetails]];
    [[DataManager sharedManager] setSelectedTypeSettings:[[DataManager sharedManager] getSelectedTypeDetails]];
    [[DataManager sharedManager] setSelectedConnectionSettings:[[DataManager sharedManager] getSelectedConnectionDetails]];
    [[DataManager sharedManager] setRestEnv:NO];
    
    [[DataManager sharedManager] setPlantSectionFilter:[[DataManager sharedManager] getSelectedPlantSectionDetails]];
    [[DataManager sharedManager] setSystemFilter:[[DataManager sharedManager] getSelectedSystemDetails]];
    [[DataManager sharedManager] setCriticalityFilter:[[DataManager sharedManager] getSelectedCriticalityDetails]];
    [[DataManager sharedManager] setSourceDocFilter:[[DataManager sharedManager] getSelectedSourceDocsDetails]];
    
    
    DBSession *dbSession = [[DBSession alloc]
                            initWithAppKey:@"btd8psgg72qqinn"
                            appSecret:@"e4ihf09x0navev8"
                            root:kDBRootAppFolder]; // either kDBRootAppFolder or kDBRootDropbox
    [DBSession setSharedSession:dbSession];
    
    
    
    /*AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                    identityPoolId:CognitoPoolID];*/
    
    AWSStaticCredentialsProvider* credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:@"AKIAJFHUAOLQR3HQJPUA" secretKey:@"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"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1
                                                                         credentialsProvider:credentialsProvider];
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    return YES;
}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            // At this point you can start making API calls
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ExpotToDropbox" object:nil];
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}


-(void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{
    
    self.backgroundTransferCompletionHandler = completionHandler;
    
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:StartUploadingAuditImages object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
