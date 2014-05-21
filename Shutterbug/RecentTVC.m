//
//  RecentTVC.m
//  Shutterbug
//
//  Created by Nicole Zhu on 5/13/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "RecentTVC.h"
#import "Photo.h"
#import "PhotoHelper.h"
#import "RecentViewController.h"
#import "PhotoViewController.h"

@interface RecentTVC ()

@end

@implementation RecentTVC

#define MAX_FETCH_LIMIT 20

-(void)setContext:(NSManagedObjectContext *)context{
    _context = context;
    [self setupFetchedResultsController];
}


- (void)setupFetchedResultsController {
    if (self.context) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"lastViewed != nil"];
        NSSortDescriptor *name = [NSSortDescriptor sortDescriptorWithKey:@"lastViewed"
                                                               ascending:NO
                                                                selector:@selector(localizedStandardCompare:)];
        request.sortDescriptors = @[name];
        [request setFetchLimit:MAX_FETCH_LIMIT];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.context
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Photo Cell"];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    
    if (!photo.thumbnailData){
        [PhotoHelper fetchThumbnailData:photo forCell:cell withIndexPath:indexPath withContext:self.context];
    } else{
        cell.imageView.image = [UIImage imageWithData:photo.thumbnailData];
    }
    return cell;
}


@end
