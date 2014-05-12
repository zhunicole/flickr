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

    [self.refreshControl beginRefreshing];
    dispatch_queue_t fetchQueue = dispatch_queue_create("flickr info fetch", NULL);
    dispatch_async(fetchQueue, ^{
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                            options:0
                                                                              error:NULL];
        NSArray *photos = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            self.photos = photos;
        });
    });
}

@end
