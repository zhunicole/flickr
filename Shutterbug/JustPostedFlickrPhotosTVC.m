//
//  JustPostedFlickrPhotosTVC.m
//  Shutterbug
//
//  Created by CS193p Instructor on 5/2/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "JustPostedFlickrPhotosTVC.h"
#import "FlickrFetcher.h"

@implementation JustPostedFlickrPhotosTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchPhotos];
}

- (IBAction)fetchPhotos
{
    NSURL *url = [FlickrFetcher URLforRecentGeoreferencedPhotos];
    
    if (url) {
        dispatch_queue_t fetchQueue = dispatch_queue_create("flickr info fetch", NULL);
        dispatch_async(fetchQueue, ^{
                NSData *jsonResults = [NSData dataWithContentsOfURL:url];
                NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                                    options:0
                                                                                      error:NULL];
        
        // another configuration option is backgroundSessionConfiguration (multitasking API required though)
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
        // create the session without specifying a queue to run completion handler on (thus, not main queue)
        // we also don't specify a delegate (since completion handler is all we need)
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[FlickrFetcher URLforTopPlaces]
                                                    completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                        NSArray *photos;
                                                        if (!error) {
                                                            photos = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
                                                        }
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [self.refreshControl endRefreshing];
                                                            self.photos = photos;
                                                        });
                                                    }];
            [task resume];
            });
    }
}


@end
