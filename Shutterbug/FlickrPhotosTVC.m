//
//  FlickrPhotosTVC.m
//  Shutterbug
//
//  Created by CS193p Instructor on 5/2/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "FlickrPhotosTVC.h"
#import "FlickrFetcher.h"
#import "RenderPhotosTVC.h"
#import "Photo.h"
#import "PhotoViewController.h"
#import "CoreDataTableViewController.h"



@implementation FlickrPhotosTVC




#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"here");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Flickr Photo Cell"];

    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *title = photo.title;
    NSString *subtitle = photo.subtitle;
    
    if ([title length]) {
        //do nothing
    } else if ([subtitle length]) {
        title = subtitle;
        subtitle = @"";
    } else {
        title = @"Unknown";
        subtitle = @"";
    }
    cell.textLabel.text = title;
    cell.detailTextLabel.text = subtitle;
    //TODO set thumbnail here
    
    return cell;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _context = managedObjectContext;
    [self setupFetchedResultsController];
}

- (void)setupFetchedResultsController
{
    if(self.context) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
        request.predicate = nil; //All regions
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"totalPhotographers"
                                                                  ascending:NO],
                                    [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                  ascending:NO
                                                                   selector:@selector(localizedStandardCompare:)]];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.context
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];

    } else {
        self.fetchedResultsController = nil;
    }
    
    NSLog(@"in flickrphotosTVC");

}



#pragma mark - Navigation



//// prepares the given ImageViewController to show the given photo
//// used either when segueing to an ImageViewController
////   or when our UISplitViewController's Detail view controller is an ImageViewController
//- (void)prepareViewController:(id)vc
//                     forSegue:(NSString *)segueIdentifer
//                fromIndexPath:(NSIndexPath *)indexPath
//{
//    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    photo.lastViewed = [NSDate date];
//    if ([vc isKindOfClass:[PhotoViewController class]]) {
//        PhotoViewController *ivc = (PhotoViewController *)vc;
//        ivc.imageURL = [NSURL URLWithString:photo.imageURL];
//        ivc.title = photo.title;
//    }
//}
//
//
//// In a story board-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    NSIndexPath *indexPath = nil;
//    if ([sender isKindOfClass:[UITableViewCell class]]) {
//        indexPath = [self.tableView indexPathForCell:sender];
//    }
//    [self prepareViewController:segue.destinationViewController
//                       forSegue:segue.identifier
//                  fromIndexPath:indexPath];
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    id detailvc = [self.splitViewController.viewControllers lastObject];
//    if ([detailvc isKindOfClass:[UINavigationController class]]) {
//        detailvc = [((UINavigationController *)detailvc).viewControllers firstObject];
//        [self prepareViewController:detailvc
//                           forSegue:nil
//                      fromIndexPath:indexPath];
//    }
//}


@end
