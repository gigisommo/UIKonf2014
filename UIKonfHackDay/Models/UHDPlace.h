//
// Created by Simone Civetta on 16/05/14.
//

#import <Foundation/Foundation.h>
#import "MTLJSONAdapter.h"
#import "MTLModel.h"
@import MapKit;

typedef void (^UHDPlacePhotoSuccessBlock)(NSArray *photos);

static NSString *const UHDPlacePhotoSize = @"400x400";

@interface UHDPlace : MTLModel<MTLJSONSerializing, MKAnnotation>

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSDictionary *location;
@property (nonatomic, strong) NSDictionary *contact;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *hereNow;
@property (nonatomic, strong) NSNumber *verified;
@property (nonatomic, strong) NSArray *photoThumbnail;
@property (nonatomic, strong) NSDictionary *photos;
@property (nonatomic, strong) NSURL *photoURL;

- (NSArray *)mergedPhotos;
- (void)retrievePhotosWithSuccess:(UHDPlacePhotoSuccessBlock)success;

@end