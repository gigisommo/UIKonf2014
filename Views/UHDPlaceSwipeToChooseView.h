//
//  UHDPlaceSwipeToChooseView.h
//  UIKonfHackDay
//
//  Created by Luigi Parpinel on 16/05/14.
//
//

#import "MDCSwipeToChooseView.h"

@class UHDPlace;

@interface UHDPlaceSwipeToChooseView : MDCSwipeToChooseView

@property (nonatomic, strong) UHDPlace *place;

- (instancetype)initWithFrame:(CGRect)frame
                        place:(UHDPlace *)place
                      options:(MDCSwipeToChooseViewOptions *)options;

@end
