//
// Created by Simone Civetta on 16/05/14.
//

#import "UHDTabBarController.h"
#import "ViewController.h"


@implementation UHDTabBarController {

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerForNotifications];
}

- (void)registerForNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(willShowDetail:) name:UHDWillShowDetailNotification object:nil];
}

- (void)willShowDetail:(NSNotification *)notification
{
    ViewController *viewController = [[ViewController alloc] initWithPlace:notification.object];
    [self presentViewController:viewController
                       animated:YES
                     completion:NULL];

}

- (void)dealloc
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

@end