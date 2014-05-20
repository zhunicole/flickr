//
//  Region+Create.m
//  TopPlacesPhotos
//
//  Created by Nicole Zhu on 5/19/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "Region+Create.h"

@implementation Region (Create)


+(Region*) regionWithName:(NSString *)name inManageObjectContext:(NSManagedObjectContext*)context {
    
    Region *region = nil;
    
    if ([name length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (error || !matches || ([matches count] > 1)) {
            // handle error
        } else if (![matches count]) {
            region = [NSEntityDescription insertNewObjectForEntityForName:@"Region"
                                                         inManagedObjectContext:context];
            region.name = name;
        } else {
            region = [matches lastObject];
        }
    }
    
    return region;

}
@end
