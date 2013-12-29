//
//  MIOAppDelegate.m
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/28.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import "MIOAppDelegate.h"
#import "MIOSummaryViewController.h"

@implementation MIOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    UITabBarController* tabbarController = (UITabBarController*) self.window.rootViewController;
    NSArray* items = tabbarController.tabBar.items;
    void(^setImage)(UITabBarItem*,NSString*) = ^(UITabBarItem* item, NSString* label) {
        item.image = [IonIcons imageWithIcon:label size:30.0f color:UIColor.iOS7lightGrayColor];
        item.selectedImage = [IonIcons imageWithIcon:label size:30.0f color:UIColor.iOS7darkBlueColor];
    };
    setImage(items[0], icon_home);
    setImage(items[1], icon_pie_graph);
    setImage(items[2], icon_stats_bars);
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

@end
