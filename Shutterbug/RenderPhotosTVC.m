//
//  ImageViewController.m
//  Imaginarium
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "RenderPhotosTVC.h"

@interface RenderPhotosTVC () 
@end

@implementation RenderPhotosTVC

#pragma mark - View Controller Lifecycle


// add the UIImageView to the MVC's View

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchPhotos];
}


#pragma mark - Setting the Image from the Image's URL

static const int MAX_PHOTO_RESULTS = 50;

/*similar to fetchPlaces*/
- (IBAction)fetchPhotos {
    [self.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[FlickrFetcher URLforPhotosInPlace:[self.place valueForKeyPath:FLICKR_PLACE_ID] maxResults:MAX_PHOTO_RESULTS]
                                                completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                    NSArray *photos;
                                                    if (!error) {
                                                        photos = [[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:location]
                                                                                                  options:0
                                                                                                    error:&error] valueForKeyPath:FLICKR_RESULTS_PHOTOS];
                                                    }
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        self.photos = photos;
                                                        [self.refreshControl endRefreshing];
                                                    });
                                                }];
    [task resume];

}



@end