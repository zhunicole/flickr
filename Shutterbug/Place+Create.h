//
//  Place+Create.h
//  TopPlacesPhotos
//
//  Created by Nicole Zhu on 5/19/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "Place.h"

@interface Place (Create)

+(Place*) placeWithPlaceID: (NSString*)placeID
    inManagedObjectContext:(NSManagedObjectContext *)context;

@end

