//
//  RecentViewController.m
//  Shutterbug
//
//  Created by Nicole Zhu on 5/13/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "RecentViewController.h"
#import "FlickrFetcher.h"
#import "FlickrDatabase.h"

@interface RecentViewController ()

@end

@implementation RecentViewController


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    FlickrDatabase *flickrdb = [FlickrDatabase sharedDefaultFlickrDatabase];
    if (flickrdb.managedObjectContext) {
        self.context = flickrdb.managedObjectContext;
    } else {
        id observer = [[NSNotificationCenter defaultCenter] addObserverForName:FlickrDatabaseAvailable
                                                                        object:flickrdb
                                                                         queue:[NSOperationQueue mainQueue]
                                                                    usingBlock:^(NSNotification *note) {
                                                                        self.context = flickrdb.managedObjectContext;
                                                                        [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                                                    }];
    }
}


@end
