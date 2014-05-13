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
    [self fetchPlaces];

}

- (IBAction)fetchPlaces
{
    [self.refreshControl beginRefreshing];
    //what does this do?
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    NSURL *url = [FlickrFetcher URLforRecentGeoreferencedPhotos];
    if (url) {
        dispatch_queue_t fetchQueue = dispatch_queue_create("flickr info fetch", NULL);
        dispatch_async(fetchQueue, ^{
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
            NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[FlickrFetcher URLforTopPlaces]
                                                    completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                        NSArray *places;
                                                        if (!error) {
                                                            places = [[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:location]
                                                                                                      options:0
                                                                                                        error:&error] valueForKeyPath:FLICKR_RESULTS_PLACES];
                                                        }
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            self.places = places;
                                                            [self.refreshControl endRefreshing];
                                                        });
                                                    }];
            [task resume];
            });
    }
}


@end
