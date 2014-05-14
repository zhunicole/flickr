//
//  PhotosTVC.m
//  Shutterbug
//
//  Created by Nicole Zhu on 5/12/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "PhotosTVC.h"
#import "PhotoViewController.h"
#import "RecentViewController.h"

@interface PhotosTVC ()

@end

@implementation PhotosTVC

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    [self.tableView reloadData];
    
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.photos count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Photo Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *photo = self.photos[indexPath.row];
    cell.textLabel.text = [self titleOfPhoto:photo];
    cell.detailTextLabel.text = [self subtitleOfPhoto:photo];
    return cell;
}

- (NSString *) titleOfPhoto:(NSDictionary *)photo {
    NSString *title;
    title = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
    if ([title length]) {
        return title;
    } else if ([[photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] length]){
        return [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    } else {
        return @"Unknown";
    }
}

-(NSString *) subtitleOfPhoto:(NSDictionary*)photo {
    NSString *descrip = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];

    if ([descrip length]){
        //if is already used as title then ignore
        if ([descrip isEqualToString:[self titleOfPhoto:photo]]) {
            return @"";
        } else {
            return descrip;
        }
    } else {
        return @"";
    }
}



#pragma mark - UITableViewDelegate

/* For ipad*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if ([detailVC isKindOfClass:[UINavigationController class]]) {
        detailVC = [((UINavigationController *)detailVC).viewControllers firstObject];
    }
    if ([detailVC isKindOfClass:[PhotoViewController class]]) {
        [self prepareVC:detailVC toDisplayPhoto:self.photos[indexPath.row]];
    }
    
}


#pragma mark - Navigation

- (void)prepareVC:(PhotoViewController *)ivc
  toDisplayPhoto:(NSDictionary *)photo
{
    ivc.imageURL = [FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge];
    ivc.imageTitle = [self titleOfPhoto:photo];
    [RecentViewController addRecentPhoto:photo];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Photo"]) {
                if ([segue.destinationViewController isKindOfClass:[PhotoViewController class]]) {
                    [self prepareVC:segue.destinationViewController
                    toDisplayPhoto:self.photos[indexPath.row]];
                }
            }
        }
    }
}

@end
