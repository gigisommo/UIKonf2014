//
// Created by Simone Civetta on 16/05/14.
//

#import <Foursquare-API-v2/Foursquare2.h>
#import "UHDPlace.h"
#import "Underscore.h"

@interface UHDPlace ()

@property (nonatomic, strong) NSArray *photosArray;

@end

@implementation UHDPlace

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"identifier": @"id",
            @"hereNow": @"hereNow.count",
            @"photoThumbnail": @"photos.groups.items"
    };
}

- (void)retrievePhotosWithSuccess:(UHDPlacePhotoSuccessBlock)successBlock
{
    if (self.photosArray) {

        if (!successBlock) {
            return;
        }

        successBlock(self.photosArray);
        return;
    }

    [Foursquare2 venueGetPhotos:self.identifier
                          limit:@(50)
                         offset:@(0)
                       callback:^(BOOL success, id result) {
                           if (success) {
                               self.photosArray = Underscore.array(result[@"response"][@"photos"][@"items"]).map(^(NSDictionary *dict){
                                   return [NSString stringWithFormat:@"%@%@%@", dict[@"prefix"], UHDPlacePhotoSize, dict[@"suffix"]];
                               }).unwrap ;

                               if (!successBlock) {
                                   return;
                               }

                               successBlock(self.photosArray);
                           }
                       }];
}

- (NSArray *)mergedPhotos
{
    [self retrievePhotosWithSuccess:nil];

    if (self.photosArray) {
        return Underscore.head(self.photosArray, 10);
    }
    
    NSArray *items = Underscore.array(self.photos[@"groups"]).pluck(@"items").flatten.map(^(NSDictionary *photoInfo){
        return [NSString stringWithFormat:@"%@%@%@", photoInfo[@"prefix"], UHDPlacePhotoSize, photoInfo[@"suffix"]];
    }).unwrap;
    return items;
}

#pragma mark - MKAnnotation

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake([self.location[@"lat"] floatValue],
                                      [self.location[@"lng"] floatValue]);
}

- (NSString *)title
{
    return self.name;
}

@end