//
//  PhotoHelper.h
//  TopPlacesPhotos
//
//  Created by Nicole Zhu on 5/21/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHoto.h"

@interface PhotoHelper : NSObject

+ (Photo *)getPhotoWithUniqueID:(NSString *)unique withContext:(NSManagedObjectContext *)context;

+ (void)justViewed:(Photo*)photo;
+ (void)fetchThumbnailData:(Photo*)photo forCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath *)indexPath withContext:(NSManagedObjectContext*)mainContext;
@end
