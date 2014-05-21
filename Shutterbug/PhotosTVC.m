//
//  PhotosTVC.m
//  Shutterbug
//
//  Created by Nicole Zhu on 5/12/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "PhotosTVC.h"
#import "PhotoViewController.h"
#import "RecentViewController.h"
#import "Photo.h"
#import "PhotoHelper.h"

@interface PhotosTVC ()

@end

@implementation PhotosTVC


#pragma mark - Table view data source




#pragma mark - UITableViewDelegate

/* For ipad*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if ([detailVC isKindOfClass:[UINavigationController class]]) {
        detailVC = [((UINavigationController *)detailVC).viewControllers firstObject];
    }
    if ([detailVC isKindOfClass:[PhotoViewController class]]) {
        Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self prepareVC:detailVC toDisplayPhoto:photo];
    }
}


#pragma mark - Navigation

- (void)prepareVC:(PhotoViewController *)ivc
   toDisplayPhoto:(Photo *)photo
{
    ivc.imageURL = (NSURL*)photo.imageURL;
    ivc.imageTitle = photo.title;
    
    [PhotoHelper justViewed:photo];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Photo"]) {
                if ([segue.destinationViewController isKindOfClass:[PhotoViewController class]]) {
                    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
                    [self prepareVC:segue.destinationViewController
                     toDisplayPhoto:photo];
                }
            }
        }
    }
}


@end
