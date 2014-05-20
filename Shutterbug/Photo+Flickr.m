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
        photo = [matches firstObject];
    } else {
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
        //TODO thumbnail stuff
    }

    return photo;
}

/* Gets places from CoreData
 * then sets relationships of places
 * for the ability to display photos from top regions
 * using photographer.regions as a check for whether count has been incremented*/
+ (void) loadPhotosFromArray:(NSArray*)photos intoNSMOC:(NSManagedObjectContext *)context {
    for (NSDictionary *photo in photos) {
        [self photoWithFlickrInfo:photo inManagedObjectContext:context];
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    request.predicate = [NSPredicate predicateWithFormat:@"whatRegion = %@", nil];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    //TODO why exactly?
    if (error || !matches || ([matches count] > 1)) {
    } else {
        dispatch_queue_t fetch = dispatch_queue_create("Flickr fetch", NULL);
        dispatch_async(fetch, ^{
            for (Place *place in matches) {
                NSLog(@"getting region information");
                NSURL *url = [FlickrFetcher URLforInformationAboutPlace:place.placeID];
                NSData *jsonResults = [NSData dataWithContentsOfURL:url];
                NSDictionary *placeInfo = [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];
                NSString *regionName = [FlickrFetcher extractRegionNameFromPlaceInformation:placeInfo];
                
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [context performBlock:^ {
                        place.whatRegion = [Region regionWithName:regionName inManageObjectContext:context];
                        for (Photo *photo in place.photos) {
                            //if cur photographer doesn't have region
                            photo.whatRegion = place.whatRegion;
                            if (![photo.whoTook.regions containsObject:photo.whatRegion]) {
                                int curCount = [photo.whatRegion.totalPhotographers intValue];
                                photo.whatRegion.totalPhotographers = [NSNumber numberWithInt:(curCount++)];
                                [photo.whoTook addRegionsObject:photo.whatRegion];
                            }
                        }
                    }];
                });
            }
        });
    }
}

@end
