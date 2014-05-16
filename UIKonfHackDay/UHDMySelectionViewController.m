//
//  UHDMySelectionViewController.m
//  UIKonfHackDay
//
//  Created by Simone Civetta on 16/05/14.
//
//

#import "UHDMySelectionViewController.h"
#import "UHDPlaceManager.h"
#import "UHDPlace.h"
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "MKMapView+ZoomLevel.h"

@interface UHDMySelectionViewController ()

@property (nonatomic, strong) NSArray *places;
@property (nonatomic, strong) NSOperationQueue *imageLoadQueue;
@property (nonatomic, strong) NSMutableDictionary *placesPhoto;

@end

@implementation UHDMySelectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadPlacesData];
}

- (NSOperationQueue *)imageLoadQueue
{
    if (!_imageLoadQueue) {
        _imageLoadQueue = [[NSOperationQueue alloc] init];
    }
    
    return _imageLoadQueue;
}

- (NSMutableDictionary *)placesPhoto
{
    if (!_placesPhoto) {
        _placesPhoto = [NSMutableDictionary dictionary];
    }
    
    return _placesPhoto;
}

- (void)reloadPlacesData
{
    self.places = [[UHDPlaceManager sharedManager] placesForCritic:UHDPlaceCriticLike];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView setCenterCoordinate:[UHDPlaceManager sharedManager].lastKnownLocation
                            zoomLevel:16
                             animated:YES];
    
    for (UHDPlace *place in self.places) {
        [place retrievePhotosWithSuccess:^(NSArray *photos) {
            NSURL *url = [NSURL URLWithString:[photos firstObject]];
            NSURLRequest *imageRequest = [NSURLRequest requestWithURL:url];
            AFHTTPRequestOperation *imageOperation = [[AFHTTPRequestOperation alloc] initWithRequest:imageRequest];
            imageOperation.responseSerializer = [AFImageResponseSerializer serializer];
            [imageOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self.placesPhoto setObject:responseObject forKey:place.identifier];
                [self.mapView addAnnotation:place];
            }
                                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                      NSLog(@"Failed retrieve image with url: %@", url);
                                                  }];
            [self.imageLoadQueue addOperation:imageOperation];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *AnnotationViewID = @"annotationViewID";
    
    MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    NSInteger imageViewTag = 0x8badf00d;

    UIImage *image = nil;
    if ([annotation isKindOfClass:[UHDPlace class]]) {
        NSString *identifier = ((UHDPlace *)annotation).identifier;
        image = self.placesPhoto[identifier];
    }
    
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:AnnotationViewID];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = (CGRect) { CGPointZero, CGSizeMake(44.0, 44.0)};
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.tag = imageViewTag;
        imageView.layer.cornerRadius = 5.0;
        imageView.clipsToBounds = YES;
        annotationView.frame = imageView.frame;
        [annotationView addSubview:imageView];
    }
    else {
        UIImageView *imageView = (UIImageView *)[annotationView viewWithTag:imageViewTag];
        imageView.image = image;
    }
    annotationView.canShowCallout = YES;
    annotationView.annotation = annotation;
    
    return annotationView;
}

@end
