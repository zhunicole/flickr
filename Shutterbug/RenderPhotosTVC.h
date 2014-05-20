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
#import "Region.h"
#import "FlickrPhotosTVC.h"

@interface RenderPhotosTVC : FlickrPhotosTVC

//@property (nonatomic, strong) NSDictionary *place;
@property (strong, nonatomic)Region *region;

@end
