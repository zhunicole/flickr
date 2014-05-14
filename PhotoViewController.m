//
//  PhotoViewController.m
//  Shutterbug
//
//  Created by Nicole Zhu on 5/12/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "PhotoViewController.h"
#import "JustPostedFlickrPhotosTVC.h"
#import "RenderPhotosTVC.h"

@interface PhotoViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation PhotoViewController

- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
    // see UISplitViewControllerDelegate methods below
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle: self.imageTitle];
    [self.scrollView addSubview: self.imageView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Properties

// lazy instantiation

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] init];
    return _imageView;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{
    self.scrollView.zoomScale = 1;

    self.imageView.image = image; // does not change the frame of the UIImageView
    [self.imageView sizeToFit];   // update the frame of the UIImageView

    double statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    double statusBarWidth = [UIApplication sharedApplication].statusBarFrame.size.width;

    double navBarHeight = self.navigationController.navigationBar.frame.size.height;
    double topClearing = MIN(statusBarHeight, statusBarWidth)+navBarHeight;
    self.imageView.frame = CGRectMake(0, topClearing, image.size.width, image.size.height);
    self.scrollView.contentSize = image ? image.size : CGSizeZero;
    [self.spinner stopAnimating];
    [self autozoomImage];

}

- (void) autozoomImage {
    double tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    double statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    double statusBarWidth = [UIApplication sharedApplication].statusBarFrame.size.width;
    double navBarHeight = self.navigationController.navigationBar.frame.size.height;
    double imageViewHeight = self.imageView.image.size.height;
    double imageViewWidth = self.imageView.image.size.width;
    double scrollViewWidth = self.scrollView.bounds.size.width;
    double scrollViewHeight = self.scrollView.bounds.size.height;
    
    double maxWidth = scrollViewWidth / imageViewWidth;
    double maxHeight = (scrollViewHeight - navBarHeight - tabBarHeight - MIN(statusBarHeight, statusBarWidth) )/ imageViewHeight;
    
    if (maxWidth < maxHeight) {
        self.scrollView.zoomScale = maxWidth;
    } else {
        self.scrollView.zoomScale = maxHeight;
    }
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}


- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;

    self.image = nil;
    if (!self.imageURL) return;
    
    [self.spinner startAnimating];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:self.imageURL
                                                completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                    if (!error) {
                                                        if ([response.URL isEqual:self.imageURL]) {
                                                            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                self.image = image;
                                                            });
                                                        }
                                                    }
                                                }];
    [task resume];
    
}

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    UIViewController *hiddenController = aViewController;
    if ([aViewController isKindOfClass:[UITabBarController class]]) {
        hiddenController = [(UITabBarController*)hiddenController selectedViewController];
    }
    if ([aViewController isKindOfClass:[UINavigationController class]]){
        hiddenController = [(UINavigationController*)hiddenController topViewController];
    }
    if (hiddenController) barButtonItem.title = hiddenController.title;
    else barButtonItem.title = @"Top Places";
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{

    self.navigationItem.leftBarButtonItem = nil;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
