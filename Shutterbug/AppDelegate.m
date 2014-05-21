//
//  AppDelegate.m
//  Shutterbug
//
//  Created by CS193p Instructor on 5/2/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "AppDelegate.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "FlickrDatabase.h"

//@interface AppDelegate //() <NSURLSessionDownloadDelegate>
//@property (strong, nonatomic) NSManagedObjectContext *context;
//@property (strong, nonatomic) NSURLSession *session;
//@property (copy, nonatomic) void (^bgSessionCompletionHandler)();
//@property (strong, nonatomic) NSTimer *timer;
//@end



@implementation AppDelegate
#define FETCH_DEBUG YES
#define FOREGROUND_FETCH_INTERVAL (FETCH_DEBUG ? 5 : (15*60))
#define BACKGROUND_FETCH_INTERVAL (FETCH_DEBUG ? 5 : (10))


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [NSTimer scheduledTimerWithTimeInterval:FOREGROUND_FETCH_INTERVAL
                                     target:self
                                   selector:@selector(processFetchTimer:)
                                   userInfo:nil
                                    repeats:YES];
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    return YES;
}

- (void)processFetchTimer:(NSTimer *)timer
{
    [[FlickrDatabase sharedDefaultFlickrDatabase] fetch];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [[FlickrDatabase sharedDefaultFlickrDatabase] fetchWithCompletionHandler:^(BOOL success) {
        completionHandler(success ? UIBackgroundFetchResultNewData : UIBackgroundFetchResultNoData);
    }];
}



//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//{
//    //sets the min fetch interval for when we are in background
//    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
//    
//    //gettign out managed object context from a UIManagedDoc
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSURL *docLocation = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]firstObject];
//    NSString *docName = @"NicolesDoc";
//    NSURL *url = [docLocation URLByAppendingPathComponent:docName];
//    UIManagedDocument *doc = [[UIManagedDocument alloc] initWithFileURL:url];
//    
//    BOOL fileExists = [fileManager fileExistsAtPath:[url path]];
//    if (fileExists) {
//        [doc openWithCompletionHandler:^(BOOL success) {
//            if(success)[self docIsReadyAndCreateObject:doc];
//            if(!success) NSLog(@"couldn't open doc at %@", url);
//        }];
//    } else { //create it
//        [doc saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
//            if (success) [self docIsReadyAndCreateObject:doc];
//            if (!success) NSLog(@"couldn't save doc at %@", url);
//        }];
//    }
//    NSLog(@"completed didfinishlaunch");
//    return YES;
//}
//
//- (void) docIsReadyAndCreateObject: (UIManagedDocument*)doc {
//    if (doc.documentState == UIDocumentStateNormal) {
//        self.context = doc.managedObjectContext;
//        [self fetch];
//    } else {
//        NSLog(@"not ready to go");
//    }
//}
//
//
///*Foreground call
// *non discretionary, non-background-session fetch*/
//- (void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    if (self.context) {
//        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
//        config.allowsCellularAccess = NO;
//        config.timeoutIntervalForRequest = BACKGROUND_FETCH_INTERVAL;
//        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
//        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
//        NSURLSessionDownloadTask *task;
//        task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
//            [self loadPhotosFromLocalURL:location intoContext:self.context andThenExecuteBlock:^{
//                completionHandler(UIBackgroundFetchResultNewData);
//            }];
//        }];
//        [task resume];
//    } else {
//        completionHandler(UIBackgroundFetchResultNoData);
//    }
//    NSLog(@"in foreground, fetch");
//}
//
//
///* Called when we are in background and a background request returns*/
//- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{
//    self.bgSessionCompletionHandler = completionHandler; //saves completionHandler in a callback block
//}

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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
