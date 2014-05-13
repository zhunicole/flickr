//
//  PhotoViewController.h
//  Shutterbug
//
//  Created by Nicole Zhu on 5/12/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSString *imageTitle;

@end
