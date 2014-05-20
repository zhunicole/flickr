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


@interface AppDelegate() <NSURLSessionDownloadDelegate>
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSURLSession *session;
@property (copy, nonatomic) void (^bgSessionCompletionHandler)();
@property (strong, nonatomic) NSTimer *timer;
@end



@implementation AppDelegate
#define FETCH_DEBUG NO
#define FOREGROUND_FETCH_INTERVAL (FETCH_DEBUG ? 5 : (15*60))
#define BACKGROUND_FETCH_INTERVAL (FETCH_DEBUG ? 5 : (10))
#define FETCH @"Fetch from Flickr"


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //sets the min fetch interval for when we are in background
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    //gettign out managed object context from a UIManagedDoc
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *docLocation = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]firstObject];
    NSString *docName = @"NicolesDoc";
    NSURL *url = [docLocation URLByAppendingPathComponent:docName];
    UIManagedDocument *doc = [[UIManagedDocument alloc] initWithFileURL:url];
    
    BOOL fileExists = [fileManager fileExistsAtPath:[url path]];
    if (fileExists) {
        [doc openWithCompletionHandler:^(BOOL success) {
            if(success)[self docIsReadyAndCreateObject:doc];
            if(!success) NSLog(@"couldn't open doc at %@", url);
        }];
    } else { //create it
        [doc saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) [self docIsReadyAndCreateObject:doc];
            if (!success) NSLog(@"couldn't save doc at %@", url);
        }];
    }
    return YES;
}

- (void) docIsReadyAndCreateObject: (UIManagedDocument*)doc {
    if (doc.documentState == UIDocumentStateNormal) {
        self.context = doc.managedObjectContext;
        [self fetch];
    } else {
        NSLog(@"not ready to go");
    }
}


/*Foreground call
 *non discretionary, non-background-session fetch*/
- (void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (self.context) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        config.allowsCellularAccess = NO;
        config.timeoutIntervalForRequest = BACKGROUND_FETCH_INTERVAL;
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
        NSURLSessionDownloadTask *task;
        task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            [self loadPhotosFromLocalURL:location intoContext:self.context andThenExecuteBlock:^{
                completionHandler(UIBackgroundFetchResultNewData);
            }];
        }];
        [task resume];
    } else {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}


/* Called when we are in background and a background request returns*/
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{
    self.bgSessionCompletionHandler = completionHandler; //saves completionHandler in a callback block
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void) setContext:(NSManagedObjectContext*)photoContext {
    _context = photoContext;
    [self.timer invalidate];
    self.timer = nil;
    if (self.context) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:FOREGROUND_FETCH_INTERVAL target:self selector:@selector(fetch:) userInfo:nil repeats:YES];
    }
    //alert all other listeners
    NSDictionary *info = self.context ? @{ContextKey : self.context} : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification object:self userInfo:info];
}


#pragma mark - Flickr downloads

- (void) fetch {
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if(![downloadTasks count]){
            NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
            task.taskDescription = FETCH;
            [task resume];
        } else {
            for (NSURLSessionDownloadTask *task in downloadTasks)[task resume];
        }
    }];
}

- (void) fetch:(NSTimer*)timer {
    [self fetch];
}


- (NSURLSession*)session {
    if (!_session) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:FETCH];
            urlSessionConfig.allowsCellularAccess = NO;
            _session = [NSURLSession sessionWithConfiguration:urlSessionConfig
                                                                   delegate:self
                                                              delegateQueue:nil];
        });
    }
    return _session;

}

- (void) loadPhotosFromLocalURL:(NSURL *)url intoContext:(NSManagedObjectContext*)context andThenExecuteBlock:(void(^)())whenDone{
    if (context) {
        NSArray *photos = [self photoArrayAtURL:url];
        [context performBlock:^{
            [Photo loadPhotosFromArray:photos intoNSMOC:context];
            if (whenDone) whenDone(); //TODO seee if can refactor this out
        }];
    } else {
        if (whenDone) whenDone();
    }
}

/* Get photo array from local url*/
- (NSArray*) photoArrayAtURL:(NSURL *)url{
    NSArray *photos;
    
    NSDictionary *list;
    NSData *JSONData = [NSData dataWithContentsOfURL:url];
    if (JSONData) {
        list = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:NULL];
    }
    photos = [list valueForKeyPath:FLICKR_RESULTS_PHOTOS];
    return photos;
}

- (void) uponCompletionOfDownloads {
    if (self.bgSessionCompletionHandler) {
        [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if(![downloadTasks count]){
                void (^completionHandler)() = self.bgSessionCompletionHandler;
                self.bgSessionCompletionHandler = nil;
                if (completionHandler)  completionHandler();
            }
        }];
    }
}


#pragma mark - URLSession delegates

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    if ([downloadTask.taskDescription isEqualToString:FETCH]) {
        [self loadPhotosFromLocalURL:location intoContext:self.context andThenExecuteBlock:^{
            [self uponCompletionOfDownloads];
        }];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}


@end
