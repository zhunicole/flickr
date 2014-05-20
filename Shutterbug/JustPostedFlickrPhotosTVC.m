//
//  JustPostedFlickrPhotosTVC.m
//  Shutterbug
//
//  Created by CS193p Instructor on 5/2/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//


#import "JustPostedFlickrPhotosTVC.h"
#import "FlickrFetcher.h"
#import "AppDelegate.h"
#import "Region.h"
#import "RenderPhotosTVC.h"

@implementation JustPostedFlickrPhotosTVC


- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:Notification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.managedObjectContext = note.userInfo[ContextKey];
                                                  }];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _context = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"totalPhotographers"
                                                              ascending:NO],
                                [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                              ascending:NO
                                                               selector:@selector(localizedStandardCompare:)]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

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
