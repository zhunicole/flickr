//
//  RecentViewController.h
//  Shutterbug
//
//  Created by Nicole Zhu on 5/13/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentViewController : UIViewController

+ (NSArray *) photoArray;
+ (void) addRecentPhoto:(NSDictionary*) photo;

@end
