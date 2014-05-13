//
//  ImageViewController.h
//  Imaginarium
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotosTVC.h"
#import "FlickrFetcher.h"

@interface ImageViewController : PhotosTVC

// Model for this MVC ... URL of an image to display
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSDictionary *place;


@end
