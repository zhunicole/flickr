//
//  FlickrPhotosTVC.m
//  Shutterbug
//
//  Created by CS193p Instructor on 5/2/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "FlickrPhotosTVC.h"
#import "Region.h"
#import "RenderPhotosTVC.h"

@implementation FlickrPhotosTVC



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Region"];

    Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];

    
    cell.textLabel.text = region.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",region.totalPhotographers];
    
    return cell;
}

- (void)setContext:(NSManagedObjectContext *)managedObjectContext
{
    _context = managedObjectContext;
    [self setupFetchedResultsController];
}

#define MAX_FETCH 50
- (void)setupFetchedResultsController
{
    if(self.context) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
        request.predicate = nil; //All regions
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"totalPhotographers"
                                                                  ascending:NO],
                                    [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                  ascending:NO
                                                                   selector:@selector(localizedStandardCompare:)]];
        request.fetchLimit = MAX_FETCH;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.context
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];

    } else {
        self.fetchedResultsController = nil;
    }
}



#pragma mark - Navigation


- (void)prepareRenderPhotosTVC:(RenderPhotosTVC *)ivc
  toDisplayPhotosForRegion:(Region *)region
{
    ivc.region = region;
    ivc.context = self.context;
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Display Photo List"]) {
                if ([segue.destinationViewController isKindOfClass:[RenderPhotosTVC class]]) {
                    Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath]; //impt function
                    [self prepareRenderPhotosTVC:segue.destinationViewController toDisplayPhotosForRegion:region];

                }
            }
        }
    }
}



@end
