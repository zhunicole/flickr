//
//  RecentTVC.m
//  Shutterbug
//
//  Created by Nicole Zhu on 5/13/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "RecentTVC.h"
#import "RecentViewController.h"

@interface RecentTVC ()

@end

@implementation RecentTVC


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.photos = [RecentViewController photoArray] ;
}


@end
