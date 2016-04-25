//
//  AppDelegate.m
//  Footprint
//
//  Created by 李小亚 on 16/3/30.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "AppDelegate.h"
#import "XYMainViewController.h"
#import "XYMainNavigationController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AVFoundation/AVFoundation.h>
#import "XYRootVC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (void)configureAPIKey
{
    [MAMapServices sharedServices].apiKey = @"e737da7e930e0986fb06a4830ce9a07e";
    [AMapLocationServices sharedServices].apiKey = @"e737da7e930e0986fb06a4830ce9a07e";
    [AMapSearchServices sharedServices].apiKey = @"e737da7e930e0986fb06a4830ce9a07e";
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
   
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self configureAPIKey];
    
    //设置根视图
    [XYRootVC setRootVCWithWindow:_window];
    //设置根控制器
//    XYMainViewController *mainVc = [[XYMainViewController alloc] init];
//    XYMainNavigationController *mainNav = [[XYMainNavigationController alloc] initWithRootViewController:mainVc];
//    
//    self.window.rootViewController = mainNav;
    
    [self.window makeKeyAndVisible];
    
#warning debug
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    //注册通知
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    [application registerUserNotificationSettings:settings];
    
    return YES;
}

//通过点击通知的时候打开应用，会调用此方法
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
    
    //取消特定的本地通知
    for (UILocalNotification *locNoti in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        XYLog(@"%@", locNoti);
//        NSString *notiID = locNoti.userInfo[kLocalNotificationID];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    BOOL flag = [[AVAudioSession sharedInstance] setActive:NO error:NULL];
    if (flag) {
        XYLog(@"success");
    }else{
        XYLog(@"failure");
    }
    
  
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[AVAudioSession sharedInstance] setActive:NO error:NULL];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
