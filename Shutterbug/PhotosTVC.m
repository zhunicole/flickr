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

@interface PhotosTVC ()

@end

@implementation PhotosTVC


#pragma mark - Table view data source



- (NSString *) titleOfPhoto:(NSDictionary *)photo {
    NSString *title;
    title = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
    if ([title length]) {
        return title;
    } else if ([[photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] length]){
        return [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    } else {
        return @"Unknown";
    }
}

-(NSString *) subtitleOfPhoto:(NSDictionary*)photo {
    NSString *descrip = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];

    if ([descrip length]){
        //if is already used as title then ignore
        if ([descrip isEqualToString:[self titleOfPhoto:photo]]) {
            return @"";
        } else {
            return descrip;
        }
    } else {
        return @"";
    }
}



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
    NSLog(@"%@",ivc.imageURL);
    ivc.imageTitle = photo.title;
    //TODO [RecentViewController addRecentPhoto:photo];
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
