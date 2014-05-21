//
//  PhotoHelper.m
//  TopPlacesPhotos
//
//  Created by Nicole Zhu on 5/21/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "FlickrDatabase.h"
#import "PhotoHelper.h"

@implementation PhotoHelper

+ (Photo *)getPhotoWithUniqueID:(NSString *)unique withContext:(NSManagedObjectContext *)context {
    Photo* newPhoto = nil;
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"unique=%@",unique]];
    newPhoto = [[context executeFetchRequest:request error:nil] lastObject];
    return newPhoto;
}

+ (void)justViewed:(Photo*)photo {
    NSLog(@"justviewed");
    dispatch_queue_t fetchQueue = dispatch_queue_create("update Photo's lastViewed", NULL);
    
    dispatch_async(fetchQueue, ^{
        FlickrDatabase *flickrdb = [FlickrDatabase sharedDefaultFlickrDatabase];
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:flickrdb.managedObjectContext.persistentStoreCoordinator];
        NSError *error = nil;
        Photo* newPhoto = [self getPhotoWithUniqueID:photo.unique withContext:context];
        newPhoto.lastViewed = [NSDate date];
        error = nil;
        if (![context save:nil]) {
        }
    });
}


+ (void)fetchThumbnailData:(Photo*)photo forCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath *)indexPath withContext:(NSManagedObjectContext*)mainContext {
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
                Photo* newPhoto = [PhotoHelper getPhotoWithUniqueID:photo.unique withContext:context];
                newPhoto.thumbnailData = data;
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.imageView.image = [UIImage imageWithData:data];
                    [cell setNeedsLayout];
                });
            }
        }
    });
}


@end
