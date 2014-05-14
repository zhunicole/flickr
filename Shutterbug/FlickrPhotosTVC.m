//
//  FlickrPhotosTVC.m
//  Shutterbug
//
//  Created by CS193p Instructor on 5/2/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "FlickrPhotosTVC.h"
#import "FlickrFetcher.h"
#import "RenderPhotosTVC.h"

@interface FlickrPhotosTVC ()

@property (nonatomic, strong) NSDictionary *placesDict;   //by country
@property (nonatomic, strong) NSArray *countries;

@end

@implementation FlickrPhotosTVC

- (void)setPlaces:(NSArray *)places
{
    _places = places;
    _places = [FlickrFetcher sortPlaces:places];
    self.placesDict = [FlickrFetcher sortPlacesByCountries:_places];
    self.countries = [FlickrFetcher getCountriesFromDict:self.placesDict];
    [self.tableView reloadData];

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.countries.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return [self.placesDict[self.countries[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Flickr Photo Cell" forIndexPath:indexPath];

    NSString *country = self.countries[indexPath.section];
    NSDictionary *places = self.placesDict[country][indexPath.row];

    
    cell.textLabel.text = [FlickrFetcher extractTitleFromPlaceInformation:places];
    cell.detailTextLabel.text = [FlickrFetcher extractSubtitleFromPlaceInformation:places];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.countries[section];
}


#pragma mark - Navigation

- (void)preparePhotosTVC:(RenderPhotosTVC *)ivc
                    toDisplayPhotoForPlace:(NSDictionary *)place
{

    ivc.place = place;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Display Photo List"]) {
                if ([segue.destinationViewController isKindOfClass:[PhotosTVC class]]) {
                    [self preparePhotosTVC:segue.destinationViewController
                                      toDisplayPhotoForPlace:self.placesDict[self.countries[indexPath.section]][indexPath.row]];
                }
            }
        }
    }
}


@end
