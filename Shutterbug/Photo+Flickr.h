//
//  Photo+Flickr.h
//  Photomania
//
//  Created by CS193p Instructor on 5/13/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context;

//+ (void) loadPhoto:(Photo*)photo intoNSMOC:(NSManagedObjectContext *)context;
+ (void) findRegionFromPlaceID:(NSString*)placeID intoContext:(NSManagedObjectContext*)context forPhoto:(Photo*)photo;

@end
