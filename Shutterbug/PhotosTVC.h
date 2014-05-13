//
//  PhotosTVC.h
//  Shutterbug
//
//  Created by Nicole Zhu on 5/12/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "flickrFetcher.h"

@interface PhotosTVC : UITableViewController

@property (strong, nonatomic) NSArray *photos;
@end
