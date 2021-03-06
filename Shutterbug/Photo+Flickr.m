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
        
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                              inManagedObjectContext:context];
        
        photo.unique = unique;
        photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
        photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        
        if((photo.title ==NULL) || ([photo.title length]<1)){
            if (photo.subtitle){
                photo.title = photo.subtitle;
            }else {
                photo.title = @"Unknown";
            }
        }
        photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary
                                              format:FlickrPhotoFormatLarge] absoluteString];
        
        photo.thumbnailURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
        NSString *photographerName = [photoDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
        photo.whoTook = [Photographer photographerWithName:photographerName
                                    inManagedObjectContext:context];
        NSString *placeID = [photoDictionary valueForKey:FLICKR_PHOTO_PLACE_ID];
        
        dispatch_queue_t fetch = dispatch_queue_create("Flickr fetch", NULL);
        dispatch_async(fetch, ^{
            [self findRegionFromPlaceID:placeID intoContext:context forPhoto:photo];
        });

    } else {
        photo = [matches firstObject];

    }

    return photo;
}

//needs async download, get region dictionary
+ (void) findRegionFromPlaceID:(NSString*)placeID intoContext:(NSManagedObjectContext*)context forPhoto:(Photo*)photo {
   
        NSURL *url = [FlickrFetcher URLforInformationAboutPlace:placeID];
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        NSError *error;
        NSDictionary *placeInfo = [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:&error];
        if (error) {
            NSLog(@"error");
        }
        NSString *regionName = [FlickrFetcher extractRegionNameFromPlaceInformation:placeInfo];
        if (regionName) {
            [context performBlock:^ {
                
                photo.whatRegion = [Region regionWithName:regionName withPhotographer:photo.whoTook inManageObjectContext:context];
                
                            }];
        }
  

}


@end
