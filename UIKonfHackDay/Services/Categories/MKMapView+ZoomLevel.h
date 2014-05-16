// MKMapView+ZoomLevel.h

//From http://troybrant.net/blog/2010/01/set-the-zoom-level-of-an-mkmapview/
@import MapKit;

@interface MKMapView (ZoomLevel)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;

@end