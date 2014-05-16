//
// Created by Simone Civetta on 16/05/14.
//

#import <Foundation/Foundation.h>

@import MapKit;
@class UHDPlace;

typedef void (^UHDPlaceManagerRetrieveSuccessBlock)(NSArray *places);
typedef void (^UHDPlaceManagerRetrieveFailureBlock)(NSError *error);

static const int UHDPlaceManagerRadius = 3000;

typedef enum {
    UHDPlaceCriticDislike,
    UHDPlaceCriticLike
} UHDPlaceCritic;

@interface UHDPlaceManager : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D lastKnownLocation;

+ (instancetype)sharedManager;

- (void)retrievePlacesInCurrentLocationSuccess:(UHDPlaceManagerRetrieveSuccessBlock)successBlock failure:(UHDPlaceManagerRetrieveFailureBlock)failureBlock;

- (void)place:(UHDPlace *)place didSubmitCritic:(UHDPlaceCritic)critic;

- (NSArray *)placesForCritic:(UHDPlaceCritic)critic;

@end