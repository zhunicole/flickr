//
//  Photo+Flickr.m
//  Photomania
//
//  Created by CS193p Instructor on 5/13/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Photographer+Create.h"
#import "Place+Create.h"
#import "Region+Create.h"

@implementation Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSString *unique = [photoDictionary valueForKeyPath:FLICKR_PHOTO_ID];

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (error || !matches || ([matches count] > 1)) {
        // handle error
    } else if (![matches count]) {
//        NSLog(@"hi");
        
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                              inManagedObjectContext:context];
        
        photo.unique = unique;
        photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
        photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary
                                              format:FlickrPhotoFormatLarge] absoluteString];
        NSString *photographerName = [photoDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
        photo.whoTook = [Photographer photographerWithName:photographerName
                                    inManagedObjectContext:context];
        NSString *placeID = [photoDictionary valueForKey:FLICKR_PLACE_ID];
        photo.whatPlace = [Place placeWithPlaceID:placeID
                           inManagedObjectContext:context];
        
        [self findRegionFromPlaceID:placeID intoContext:context forPhoto:photo];
        //TODO thumbnail stuff

    } else {
        photo = [matches firstObject];

    }

    return photo;
}

//needs async download, get region dictionary
+ (void) findRegionFromPlaceID:(NSString*)placeID intoContext:(NSManagedObjectContext*)context forPhoto:(Photo*)photo {
    dispatch_queue_t fetch = dispatch_queue_create("Flickr fetch", NULL);
    dispatch_async(fetch, ^{
    
        NSURL *url = [FlickrFetcher URLforInformationAboutPlace:placeID];
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        NSError *error;
        NSDictionary *placeInfo = [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:&error];
        if (error) {
            NSLog(@"errorr");
        }
        NSString *regionName = [FlickrFetcher extractRegionNameFromPlaceInformation:placeInfo];
        if (regionName) {
            [context performBlock:^ {
                Region *region = [Region regionWithName:regionName inManageObjectContext:context];
                photo.whatRegion = region;
                if (![photo.whoTook.regions containsObject:photo.whatRegion]) {
                    int curCount = [photo.whatRegion.totalPhotographers intValue];
                    photo.whatRegion.totalPhotographers = [NSNumber numberWithInt:(curCount++)];
                    [photo.whoTook addRegionsObject:photo.whatRegion];
                }
            }];
        }
    });

}


@end
