//
//  UHDSwipeToChooseViewController.h
//  UIKonfHackDay
//
//  Created by Simone Civetta on 16/05/14.
//
//

#import <UIKit/UIKit.h>
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>

@interface UHDSwipeToChooseViewController : UIViewController <MDCSwipeToChooseDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *firstFadingImageView;
@property (nonatomic, weak) IBOutlet UIImageView *secondFadingImageView;

@end
