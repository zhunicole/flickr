//
//  FlickrPhotosTVC.h
//  Shutterbug
//
//  Created by CS193p Instructor on 5/2/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface FlickrPhotosTVC : CoreDataTableViewController
//@property (strong, nonatomic) NSArray *places; // of Flickr photo NSDictionary
@property (nonatomic, strong) NSManagedObjectContext *context;

//TODO something missing here
@end
