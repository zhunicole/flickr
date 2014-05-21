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
        [self fetchThumbnailData:photo forCell:cell withIndexPath:indexPath withContext:self.context];
    } else {
        cell.imageView.image = [UIImage imageWithData:photo.thumbnailData];
    }

    
    return cell;
    
}


- (void)fetchThumbnailData:(Photo*)photo forCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath *)indexPath withContext:(NSManagedObjectContext*)mainContext {
    NSURL *url = [NSURL URLWithString:photo.thumbnailURL];
    dispatch_queue_t fetchQueue = dispatch_queue_create("Thumbnail fetch", NULL);
    
    dispatch_async(fetchQueue, ^{
        if (url) {
            UIApplication *application = [UIApplication sharedApplication];
            application.networkActivityIndicatorVisible = YES;
            NSData *data = [NSData dataWithContentsOfURL:url];
            application.networkActivityIndicatorVisible = NO;
            if (data) {
                FlickrDatabase *flickrdb = [FlickrDatabase sharedDefaultFlickrDatabase];
                NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
                [context setPersistentStoreCoordinator:flickrdb.managedObjectContext.persistentStoreCoordinator];
                Photo* newPhoto = [self getPhotoWithUniqueID:photo.unique withContext:context];
                newPhoto.thumbnailData = data;
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.imageView.image = [UIImage imageWithData:data];
                    [cell setNeedsLayout];
                });
            }
        }
    });
}

- (Photo *)getPhotoWithUniqueID:(NSString *)unique withContext:(NSManagedObjectContext *)context {
    Photo* newPhoto = nil;
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"unique=%@",unique]];
    
    newPhoto = [[context executeFetchRequest:request error:nil] lastObject];
    
    return newPhoto;
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
