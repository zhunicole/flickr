//
//  RecentTVC.h
//  Shutterbug
//
//  Created by Nicole Zhu on 5/13/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

//#import "PhotosTVC.h"
#import "CoreDataTableViewController.h"
#import "PhotosTVC.h"
@interface RecentTVC : PhotosTVC

@property (nonatomic, strong) NSManagedObjectContext *context;


@end
