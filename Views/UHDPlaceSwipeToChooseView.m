//
//  UHDPlaceSwipeToChooseView.m
//  UIKonfHackDay
//
//  Created by Luigi Parpinel on 16/05/14.
//
//

#import "UHDPlaceSwipeToChooseView.h"
#import "UHDPlace.h"
#import <AFNetworking/UIKit+AFNetworking.h>
#import <POP/POP.h>

@interface UHDPlaceSwipeToChooseView ()

@property (nonatomic, weak) IBOutlet UIView *informationView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *secondThumbnailImageView;
@property (nonatomic, weak) IBOutlet UIImageView *firstThumbnailImageView;
@property (nonatomic, strong) NSArray *placePhotos;

@property (nonatomic, assign) BOOL animationsCancelled;

@end

@implementation UHDPlaceSwipeToChooseView

- (instancetype)initWithFrame:(CGRect)frame
                        place:(UHDPlace *)place
                      options:(MDCSwipeToChooseViewOptions *)options
{
    self = [super initWithFrame:frame options:options];
    if (!self) {
        return nil;
    }
    
    self.clipsToBounds = YES;
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    [self insertSubview:views[0] atIndex:0];
    
    _place = place;
    self.placePhotos = place.mergedPhotos;
    if ([self.placePhotos count]) {
        NSURL *photoURL = [NSURL URLWithString:self.placePhotos[0]];
        [self.firstThumbnailImageView setImageWithURL:photoURL];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([place.mergedPhotos count] > 1) {
                self.placePhotos = place.mergedPhotos;
            }
            if ([self.placePhotos count] > 1) {
                [self fadeImages:0];
            }
        });
    }
    
    [self constructInformationView];
    
    return self;
}

- (void)preloadSecondImage
{
    NSURL *secondURL = [NSURL URLWithString:self.placePhotos[1]];
    UIImageView *fakeImageView = [[UIImageView alloc] init];
    [fakeImageView setImageWithURL:secondURL];
}

- (void)constructInformationView {
    CGFloat bottomHeight = 60.f;
    CGRect bottomFrame = CGRectMake(0,
                                    CGRectGetHeight(self.bounds) - bottomHeight,
                                    CGRectGetWidth(self.bounds),
                                    bottomHeight);
    _informationView = [[UIView alloc] initWithFrame:bottomFrame];
    _informationView.backgroundColor = [UIColor whiteColor];
    _informationView.clipsToBounds = YES;
    _informationView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:_informationView];
    
    self.nameLabel.text = self.place.name;
    
//    [self constructNameLabel];
}

- (void)fadeImages:(NSUInteger)startIndex
{
    if (self.animationsCancelled) {
        return;
    }
    
    NSURL *firstURL = [NSURL URLWithString:self.placePhotos[startIndex]];
    [self.firstThumbnailImageView setImageWithURL:firstURL];
    self.firstThumbnailImageView.alpha = 1.0;
    
    NSUInteger nextIndex = (startIndex + 1) % [self.placePhotos count];
    self.secondThumbnailImageView.image = [UIImage imageNamed:self.placePhotos[nextIndex]];
    
    NSURL *secondURL = [NSURL URLWithString:self.placePhotos[nextIndex]];
    [self.secondThumbnailImageView setImageWithURL:secondURL];
    
    POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    anim.duration = 1.0f;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.fromValue = @(1.0);
    anim.toValue = @(0.0);
    [self.firstThumbnailImageView pop_addAnimation:anim forKey:@"fade"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self fadeImages:nextIndex];
    });
}

- (void)dealloc
{
    [self cancelAnimations];
}

- (void)cancelAnimations
{
    self.animationsCancelled = YES;
}

@end
