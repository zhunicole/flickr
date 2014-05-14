//
//  RecentViewController.m
//  Shutterbug
//
//  Created by Nicole Zhu on 5/13/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "RecentViewController.h"
#import "FlickrFetcher.h"

@interface RecentViewController ()

@end

@implementation RecentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

static const int MAX_RECENT_PHOTOS = 20;

+ (NSArray *) photoArray {
    NSArray *photoArray= [[NSUserDefaults standardUserDefaults] objectForKey: @"Recent_Photos_Key"];
    return photoArray;
}

+ (void) addRecentPhoto:(NSDictionary*) photo {
    NSMutableArray *photoArray = [[self photoArray] mutableCopy];
    
    if (!photoArray) photoArray  = [[NSMutableArray alloc] init];
    
    //check if photo is in photos Array
    NSUInteger key = [photoArray indexOfObjectPassingTest:^BOOL(id object, NSUInteger i, BOOL *b) {
        return [[FlickrFetcher photoID:photo] isEqualToString:[FlickrFetcher photoID:object]];
    }];
    if (key != NSNotFound) [photoArray removeObjectAtIndex:key];
    [photoArray insertObject:photo atIndex:0];
    if ([photoArray count] > MAX_RECENT_PHOTOS) {
        [photoArray removeLastObject];
    }
    [[NSUserDefaults standardUserDefaults] setObject:photoArray forKey:@"Recent_Photos_Key"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

@end
