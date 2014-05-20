//
//  Place+Create.m
//  TopPlacesPhotos
//
//  Created by Nicole Zhu on 5/19/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "Place+Create.h"
#import "FlickrFetcher.h"


@implementation Place (Create)


+(Place*) placeWithPlaceID: (NSString*)placeID
    inManagedObjectContext:(NSManagedObjectContext *)context {
    
    Place *place = nil;
    
    if ([placeID length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
        request.predicate = [NSPredicate predicateWithFormat:@"placeID = %@", placeID];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (error || !matches || ([matches count] > 1)) {
            // handle error
        } else if (![matches count]) {
            place = [NSEntityDescription insertNewObjectForEntityForName:@"Place"
                                                         inManagedObjectContext:context];
            place.placeID = placeID;
        } else {
            place = [matches lastObject];
        }
    }
    
    return place;

}

@end
