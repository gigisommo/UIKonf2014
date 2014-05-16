//
//  UHDSwipeToChooseViewController.m
//  UIKonfHackDay
//
//  Created by Simone Civetta on 16/05/14.
//
//

#import "UHDSwipeToChooseViewController.h"
#import "UHDPlaceSwipeToChooseView.h"
#import "UHDPlaceManager.h"
#import "UHDPlace.h"
#import "UIAlertView+BlocksKit.h"
#import <POP/POP.h>
#import "UIImage+AverageColor.h"

@interface UHDSwipeToChooseViewController ()

@property (nonatomic, strong) NSMutableArray *places;
@property (nonatomic, strong) UHDPlace *currentPlace;
@property (nonatomic, strong) UHDPlaceSwipeToChooseView *frontCardView;
@property (nonatomic, strong) UHDPlaceSwipeToChooseView *backCardView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation UHDSwipeToChooseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self fadeBackgroundImages:0];

    [self startAnimatingActivityIndicator];

    [self loadData];
}

- (void)loadData
{
    void (^alertHandler)(UIAlertView *alertView, NSInteger buttonIndex);
    
    UHDPlaceManagerRetrieveSuccessBlock successBlock = ^(NSArray *places) {
        NSLog(@"%@", places);
        self.places = [places mutableCopy];
        [self populateStack];
        [self fadeStackIn];
        [self stopAnimatingActivityIndicator];
    };
    
    UHDPlaceManagerRetrieveFailureBlock failureBlock = ^(NSError *error) {
        [self stopAnimatingActivityIndicator];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oopsen...", @"Oopsen...")
                                                        message:NSLocalizedString(@"Your weltanschauung does not allow you to download the content. Are you connected?", @"Your weltanschauung does not allow you to download the content. Are you connected?")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:NSLocalizedString(@"Let me try again", @"Let me try again"), nil];
        [alert show];
    };
    
    alertHandler = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [[UHDPlaceManager sharedManager] retrievePlacesInCurrentLocationSuccess:successBlock failure:failureBlock];
        }
    };
    
    [[UHDPlaceManager sharedManager] retrievePlacesInCurrentLocationSuccess:successBlock failure:failureBlock];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self loadData];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)populateStack
{
    self.frontCardView = [self popPlaceViewWithFrame:[self frontCardViewFrame]];
    [self.view addSubview:self.frontCardView];
    self.frontCardView.alpha = 0;
    
    self.backCardView = [self popPlaceViewWithFrame:[self backCardViewFrame]];
    [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
    self.backCardView.alpha = 0;
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped)];
    [self.view addGestureRecognizer:tgr];
}

- (void)screenTapped
{
    [[NSNotificationCenter defaultCenter] postNotificationName:UHDWillShowDetailNotification object:self.frontCardView.place];
}

- (void)setFrontCardView:(UHDPlaceSwipeToChooseView *)frontCardView {
    // Keep track of the person currently being chosen.
    // Quick and dirty, just for the purposes of this sample app.
    _frontCardView = frontCardView;
    self.currentPlace = frontCardView.place;
}

- (UHDPlaceSwipeToChooseView *)popPlaceViewWithFrame:(CGRect)frame
{
    if ([self.places count] == 0) {
        return nil;
    }
    
    // UIView+MDCSwipeToChoose and MDCSwipeToChooseView are heavily customizable.
    // Each take an "options" argument. Here, we specify the view controller as
    // a delegate, and provide a custom callback that moves the back card view
    // based on how far the user has panned the front card view.
    MDCSwipeToChooseViewOptions *options = [[MDCSwipeToChooseViewOptions alloc] init];
    options.delegate = self;
    options.threshold = 160.f;
    options.onPan = ^(MDCPanState *state){
        CGRect frame = [self backCardViewFrame];
        self.backCardView.frame = CGRectMake(frame.origin.x,
                                             frame.origin.y - (state.thresholdRatio * 10.f),
                                             CGRectGetWidth(frame),
                                             CGRectGetHeight(frame));
    };
    
    // Create a personView with the top person in the people array, then pop
    // that person off the stack.
    UHDPlaceSwipeToChooseView *placeView = [[UHDPlaceSwipeToChooseView alloc] initWithFrame:frame
                                                                                       place:[self.places firstObject]
                                                                                     options:options];
    [self.places removeObjectAtIndex:0];
    return placeView;
}

#pragma mark View Contruction

- (CGRect)frontCardViewFrame
{
    CGFloat horizontalPadding = 20.f;
    CGFloat side = CGRectGetWidth(self.view.frame) - (horizontalPadding * 2);
    CGFloat topPadding = (CGRectGetHeight(self.view.frame) - side) / 2.0 + 20.0;
    
    return CGRectMake(horizontalPadding,
                      topPadding,
                      side,
                      side);
}

- (CGRect)backCardViewFrame
{
    CGRect frontFrame = [self frontCardViewFrame];
    return CGRectMake(frontFrame.origin.x,
                      frontFrame.origin.y + 10.f,
                      CGRectGetWidth(frontFrame),
                      CGRectGetHeight(frontFrame));
}

#pragma mark Control Events

// Programmatically "nopes" the front card view.
- (void)nopeFrontCardView
{
    [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
}

// Programmatically "likes" the front card view.
- (void)likeFrontCardView
{
    [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
}

#pragma mark - MDCSwipeToChooseDelegate Protocol Methods

// This is called when a user didn't fully swipe left or right.
- (void)viewDidCancelSwipe:(UIView *)view {
    NSLog(@"You couldn't decide on %@.", self.currentPlace.name);
}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    // MDCSwipeToChooseView shows "NOPE" on swipes to the left,
    // and "LIKED" on swipes to the right.
    UHDPlaceCritic critic = (direction == MDCSwipeDirectionLeft) ? UHDPlaceCriticDislike : UHDPlaceCriticLike;
    [[UHDPlaceManager sharedManager] place:self.currentPlace
                           didSubmitCritic:critic];
    
    // MDCSwipeToChooseView removes the view from the view hierarchy
    // after it is swiped (this behavior can be customized via the
    // MDCSwipeOptions class). Since the front card view is gone, we
    // move the back card to the front, and create a new back card.
    self.frontCardView = self.backCardView;
    if ((self.backCardView = [self popPlaceViewWithFrame:[self backCardViewFrame]])) {
        // Fade the back card into view.
        self.backCardView.alpha = 0.f;
        [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.backCardView.alpha = 1.f;
                         } completion:nil];
    }
}

- (void)fadeBackgroundImages:(NSUInteger)startIndex
{
    UIColor *firstColor = self.firstFadingImageView.image.averageColor;
    //self.tabBarController.tabBar.barTintColor = firstColor;
    NSArray *backgrounds = @[@"01.png", @"02.png", @"03.png", @"04.png"];
    self.firstFadingImageView.image = [UIImage imageNamed:backgrounds[startIndex]];
    self.firstFadingImageView.alpha = 1.0;
    
    NSUInteger nextIndex = (startIndex + 1) % [backgrounds count];
    self.secondFadingImageView.image = [UIImage imageNamed:backgrounds[nextIndex]];

//    UIColor *secondColor = self.secondFadingImageView.image.averageColor;
//    POPBasicAnimation *barTintColorAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPTabBarBarTintColor];
//    barTintColorAnim.duration = 0.4f;
//    barTintColorAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//    barTintColorAnim.toValue = secondColor;
//    [self.tabBarController.tabBar pop_addAnimation:barTintColorAnim forKey:@"tintColorFade"];
//    
    POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    anim.duration = 1.0f;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.fromValue = @(1.0);
    anim.toValue = @(0.0);
    [self.firstFadingImageView pop_addAnimation:anim forKey:@"fade"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self fadeBackgroundImages:nextIndex];
    });
}

- (void)fadeStackIn
{
    [UIView animateKeyframesWithDuration:0.5 delay:0.3 options:0 animations:^{
        self.frontCardView.alpha = 1.0;
        self.backCardView.alpha = 1.0;
    } completion:nil];
}

#pragma mark - Activity indicator

- (void)startAnimatingActivityIndicator
{
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [self.view addSubview:_activityIndicatorView];
        _activityIndicatorView.center = self.view.center;
    }
    [_activityIndicatorView startAnimating];
}

- (void)stopAnimatingActivityIndicator
{
    [self.activityIndicatorView stopAnimating];
}

@end
