//
//  UHDAppDelegate.m
//  UIKonfHackDay
//
//  Created by Simone Civetta on 16/05/14.
//
//

#import <Foursquare-API-v2/Foursquare2.h>
#import "UHDAppDelegate.h"

@implementation UHDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Foursquare2 setupFoursquareWithClientId:@"DD4LWGSUH1HHBZFLR0WNUCROGMZ4TVUE2TSMZMEPS52PUEX5"
                                      secret:@"15KTAYQ5ZQEYCJQAMEVKK5IBGF5V5YMXCXOTE2FALYESGBSY"
                                 callbackURL:@"uikonf://foursquare"];
    self.window.tintColor = [UIColor colorWithRed:0.016 green:0.161 blue:0.514 alpha:1];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [Foursquare2 handleURL:url];
}

@end
