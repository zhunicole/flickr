//
//  Region+Create.h
//  TopPlacesPhotos
//
//  Created by Nicole Zhu on 5/19/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "Region.h"
@interface Region (Create)

+(Region*) regionWithName:(NSSTring*)name inManageObjectContext:(NSManagedObjectContext*)context;

@end
