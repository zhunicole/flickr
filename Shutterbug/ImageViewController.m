//
//  ImageViewController.m
//  Imaginarium
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation ImageViewController

#pragma mark - View Controller Lifecycle

- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
    // see UISplitViewControllerDelegate methods below
}

// add the UIImageView to the MVC's View

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchPhotos];
//    [self.scrollView addSubview:self.imageView];
}

#pragma mark - Properties

// lazy instantiation

//- (UIImageView *)imageView
//{
//    if (!_imageView) _imageView = [[UIImageView alloc] init];
//    return _imageView;
//}
//
//// image property does not use an _image instance variable
//// instead it just reports/sets the image in the imageView property
//// thus we don't need @synthesize even though we implement both setter and getter
//
//- (UIImage *)image
//{
//    return self.imageView.image;
//}
//
//- (void)setImage:(UIImage *)image
//{
//    // self.scrollView could be nil here if outlet-setting has not happened yet
//    self.scrollView.zoomScale = 1;
//    self.scrollView.contentSize = image ? image.size : CGSizeZero;
//
//    self.imageView.image = image; // does not change the frame of the UIImageView
//    [self.imageView sizeToFit];   // update the frame of the UIImageView
//
//    [self.spinner stopAnimating];
//}
//
//- (void)setScrollView:(UIScrollView *)scrollView
//{
//    _scrollView = scrollView;
//    
//    // next three lines are necessary for zooming
//    _scrollView.minimumZoomScale = 0.2;
//    _scrollView.maximumZoomScale = 2.0;
//    _scrollView.delegate = self;
//
//    // next line is necessary in case self.image gets set before self.scrollView does
//    // for example, prepareForSegue:sender: is called before outlet-setting phase
//    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
//}
//
#pragma mark - UIScrollViewDelegate

// mandatory zooming method in UIScrollViewDelegate protocol

//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    return self.imageView;
//}

#pragma mark - Setting the Image from the Image's URL

static const int MAX_PHOTO_RESULTS = 50;

/*similar to fetchPlaces*/
- (IBAction)fetchPhotos {
    [self.refreshControl beginRefreshing];
    //what does this do?
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];

    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[FlickrFetcher URLforPhotosInPlace:[self.place valueForKeyPath:FLICKR_PLACE_ID] maxResults:MAX_PHOTO_RESULTS]
                                                completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                    NSArray *photos;
                                                    if (!error) {
                                                        photos = [[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:location]
                                                                                                  options:0
                                                                                                    error:&error] valueForKeyPath:FLICKR_RESULTS_PHOTOS];
                                                    }
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        self.photos = photos;
                                                        [self.refreshControl endRefreshing];
//                                                        NSLog(@"photos: %@", self.photos);
                                                    });
                                                }];
    [task resume];

}



- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    //    self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageURL]]; // blocks main queue!
}


#pragma mark - UISplitViewControllerDelegate

//- (BOOL)splitViewController:(UISplitViewController *)svc
//   shouldHideViewController:(UIViewController *)vc
//              inOrientation:(UIInterfaceOrientation)orientation
//{
//    return UIInterfaceOrientationIsPortrait(orientation);
//}
//
//- (void)splitViewController:(UISplitViewController *)svc
//     willHideViewController:(UIViewController *)aViewController
//          withBarButtonItem:(UIBarButtonItem *)barButtonItem
//       forPopoverController:(UIPopoverController *)pc
//{
//    self.navigationItem.leftBarButtonItem = barButtonItem;
//    barButtonItem.title = aViewController.title;
//}
//
//- (void)splitViewController:(UISplitViewController *)svc
//     willShowViewController:(UIViewController *)aViewController
//  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
//{
//    self.navigationItem.leftBarButtonItem = nil;
//}

@end
