//
//  ImageViewController.m
//  Imaginarium
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "RenderPhotosTVC.h"
#import "Photo.h"
#import "FlickrDatabase.h"
#import "PhotoHelper.h"

@interface RenderPhotosTVC () 
@end

@implementation RenderPhotosTVC


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Photo Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    
    if (!photo.thumbnailData){
        [PhotoHelper fetchThumbnailData:photo forCell:cell withIndexPath:indexPath withContext:self.context];
    } else {
        cell.imageView.image = [UIImage imageWithData:photo.thumbnailData];
    }

    
    return cell;
    
}

#pragma mark - View Controller Lifecycle

- (void)setRegion:(Region *)region
{
    _region = region;
    self.title = region.name;
    [self setupFetchedResultsController];
}

- (void)setContext:(NSManagedObjectContext *)context{

    _context = context;

}
#define MAXRESULTS 50

- (void)setupFetchedResultsController
{
    NSManagedObjectContext *context = self.region.managedObjectContext;
    
    if (context) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"whatRegion = %@", self.region];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                  ascending:YES
                                                                   selector:@selector(localizedStandardCompare:)]];
        request.fetchLimit = MAXRESULTS;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:context
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}


@end
