//
//  UHDMySelectionViewController.h
//  UIKonfHackDay
//
//  Created by Simone Civetta on 16/05/14.
//
//

#import <UIKit/UIKit.h>
@import MapKit;

@interface UHDMySelectionViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
