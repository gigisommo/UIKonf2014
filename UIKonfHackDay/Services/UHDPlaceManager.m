//
// Created by Simone Civetta on 16/05/14.
//

#import <CoreLocation/CoreLocation.h>
#import "UHDPlaceManager.h"
#import "AKLocationManager.h"
#import "Foursquare2.h"
#import "UHDPlace.h"
#import "Underscore.h"

@interface UHDPlaceManager()

@property (nonatomic, strong) NSArray *places;

@property (nonatomic, strong) NSMutableArray *likedPlaces;
@property (nonatomic, strong) NSMutableArray *dislikedPlaces;

@end

@implementation UHDPlaceManager

+ (instancetype)sharedManager
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^ {
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.likedPlaces = [NSMutableArray new];
        self.dislikedPlaces = [NSMutableArray new];
    }
    return self;
}

- (void)retrievePlacesInCurrentLocationSuccess:(UHDPlaceManagerRetrieveSuccessBlock)successBlock
                                       failure:(UHDPlaceManagerRetrieveFailureBlock)failureBlock
{

    [AKLocationManager startLocatingWithUpdateBlock:^(CLLocation *location) {

        if (self.places) {
            successBlock(self.places);
            return;
        }
        
        self.lastKnownLocation = location.coordinate;
        
        [Foursquare2 venueExploreRecommendedNearByLatitude:@(location.coordinate.latitude)
                                                 longitude:@(location.coordinate.longitude)
                                                      near:nil
                                                accuracyLL:nil
                                                  altitude:@(location.altitude)
                                               accuracyAlt:nil
                                                     query:nil
                                                     limit:@(50)
                                                    offset:nil
                                                    radius:nil
                                                   section:nil
                                                   novelty:nil
                                            sortByDistance:YES
                                                   openNow:NO
                                               venuePhotos:YES
                                                     price:nil
                                                  callback:^(BOOL success, id result) {
                                                      if (!success) {
                                                          failureBlock(result);
                                                          return;
                                                      }
                                                      NSMutableArray *venues = [NSMutableArray array];
                                                      NSArray *groups = result[@"response"][@"groups"];
                                                      for (NSDictionary *group in groups) {
                                                          NSArray *items = group[@"items"];
                                                          for (NSDictionary *item in items) {
                                                              [venues addObject:item[@"venue"]];
                                                          }
                                                      }
                                                      NSArray *places = Underscore.array(venues).map(^(NSDictionary *venue) {
                                                          UHDPlace *place = [MTLJSONAdapter modelOfClass:UHDPlace.class fromJSONDictionary:venue error:nil];
                                                          return place;
                                                      }).unwrap;
                                                      
                                                      successBlock(places);
                                                  }];
    } failedBlock:^(NSError *error) {
        failureBlock(error);
    }];
}

- (void)place:(UHDPlace *)place didSubmitCritic:(UHDPlaceCritic)critic
{
    switch (critic) {

        case UHDPlaceCriticDislike: {
            [self.dislikedPlaces addObject:place];
            break;
        }
        case UHDPlaceCriticLike: {
            [self.likedPlaces addObject:place];
            break;
        }
        default:
            break;
    }
}

- (NSArray *)placesForCritic:(UHDPlaceCritic)critic
{
    switch (critic) {
        case UHDPlaceCriticDislike:{
            return self.dislikedPlaces;
        }
        case UHDPlaceCriticLike: {
            return self.likedPlaces;
        }
        default:
            break;
    }
    return nil;
}


@end