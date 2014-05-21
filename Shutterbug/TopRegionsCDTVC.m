//
//  TopRegionsCDTVC.m
//  Shutterbug
//
//  Created by CS193p Instructor on 5/2/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//


#import "TopRegionsCDTVC.h"
#import "FlickrFetcher.h"
#import "AppDelegate.h"
#import "Region.h"
#import "RenderPhotosTVC.h"
#import "FlickrDatabase.h"

@implementation TopRegionsCDTVC

- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    [[FlickrDatabase sharedDefaultFlickrDatabase] fetchWithCompletionHandler:^(BOOL success) {
        [self.refreshControl endRefreshing];
    }];
    NSLog(@"refreshing");
}


- (void)viewDidAppear:(BOOL)animated
{
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
    NSLog(@"view did appear");
}

//- (void)awakeFromNib
//{
//    [[NSNotificationCenter defaultCenter] addObserverForName:Notification
//                                                      object:nil
//                                                       queue:nil
//                                                  usingBlock:^(NSNotification *note) {
//                                                      self.managedObjectContext = note.userInfo[ContextKey];
//                                                  }];
//}
/*

- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    [[FlickrDatabase sharedDefaultFlickrDatabase] fetchWithCompletionHandler:^(BOOL success) {
        [self.refreshControl endRefreshing];
    }];
}
*/
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    
//    FlickrDatabase *flickrdb = [FlickrDatabase sharedDefaultFlickrDatabase];
//    if (flickrdb.managedObjectContext) {
//        self.context = flickrdb.managedObjectContext;
//    } else {
//        id observer = [[NSNotificationCenter defaultCenter] addObserverForName:FlickrDatabaseAvailable
//                                                                        object:flickrdb
//                                                                         queue:[NSOperationQueue mainQueue]
//                                                                    usingBlock:^(NSNotification *note) {
//                                                                        self.context = flickrdb.managedObjectContext;
//                                                                        [[NSNotificationCenter defaultCenter] removeObserver:observer];
//                                                                    }];
//    }
//}



#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Flickr Photo Cell"];
    
    Region *region= [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = region.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", region.totalPhotographers];
    
    NSLog(@"here");
    return cell;
}

#pragma mark - Navigation

- (void)prepareViewController:(id)vc forSegue:(NSString *)segueIdentifer fromIndexPath:(NSIndexPath *)indexPath
{
        Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if ([vc isKindOfClass:[RenderPhotosTVC class]]) {
            RenderPhotosTVC *lfptvc = (RenderPhotosTVC *)vc;
            lfptvc.region = region;
        }
}

// boilerplate
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    [self prepareViewController:segue.destinationViewController
                       forSegue:segue.identifier
                  fromIndexPath:indexPath];
}

// boilerplate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detailvc = [self.splitViewController.viewControllers lastObject];
    if ([detailvc isKindOfClass:[UINavigationController class]]) {
        detailvc = [((UINavigationController *)detailvc).viewControllers firstObject];
        [self prepareViewController:detailvc
                           forSegue:nil
                      fromIndexPath:indexPath];
    }
}



@end




//@end
