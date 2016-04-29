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
#import "XYSqliteTool.h"
#import "XYEvent.h"
#import "XYComposeController.h"

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
    [self.window makeKeyAndVisible];
    //注册通知
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    [application registerUserNotificationSettings:settings];
    
    //跳转到事件详情
    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
        UILocalNotification *notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
        [self showEventDetailWithLocalNotification:notification];
        application.applicationIconBadgeNumber -= 1;
    }
    return YES;
}

//通过点击通知的时候打开应用，会调用此方法
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
    if (application.applicationState == UIApplicationStateActive) {//处于前台，不做处理
        return;
    }
//    XYLog(@"notification %@", notification);
    application.applicationIconBadgeNumber -= 1;
    //跳转到事件详情
    [self showEventDetailWithLocalNotification:notification];
}

//跳转到事件详情
- (void)showEventDetailWithLocalNotification:(UILocalNotification *)notification{
    
    NSString *notiKey = notification.userInfo[@"key"];

    //跳转到事件详情
    //查询获取数据
    NSArray *selectedEvents = [XYSqliteTool executeTagQuaryWithNotiKey:notiKey];
    if (selectedEvents.count) {
        //            XYLog(@"%ld",selectedEvents.count);
        XYEvent *event = selectedEvents[0];
        NSString *sql;
        if (notification.repeatInterval == 0) {//不重复
            //将事件标记为完成
            sql = [NSString stringWithFormat:@"update t_event set complete = 1 where notiKey = %@", notiKey];
            
        }else{//修改数据库的提醒时间
            //当前的时间
            NSDate *currentRemindDate = [NSDate dateTransformFromStr:event.remindDate format:@"yyyy-MM-dd HH:mm"];
            //下一次提醒的时间字符串
            NSString *nextRemind;
            if (notification.repeatInterval == kCFCalendarUnitDay) {//每天
                nextRemind = [NSDate nextRepeatDaySinceDate:currentRemindDate interval:24 * 60 * 60];
            }else if (notification.repeatInterval == kCFCalendarUnitWeekday){//周一到周五
                nextRemind = [NSDate nextRepeatMonToFirSinceDate:currentRemindDate];
            }else if (notification.repeatInterval == NSCalendarUnitWeekOfMonth){//每周
                nextRemind = [NSDate nextRepeatDaySinceDate:currentRemindDate interval:24 * 60 * 60 * 7];
            }else if (notification.repeatInterval == kCFCalendarUnitMonth){//每月
                
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:currentRemindDate];
                nextRemind = [NSDate nextRepeatDaySinceDate:currentRemindDate interval:24 * 60 * 60 * range.length];
                
            }else if (notification.repeatInterval == kCFCalendarUnitYear){//每年
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:currentRemindDate];
                nextRemind = [NSDate nextRepeatDaySinceDate:currentRemindDate interval:24 * 60 * 60 * range.length];
            }
            sql = [NSString stringWithFormat:@"update t_event set remindDate = '%@' where notiKey = %@", nextRemind, notiKey];
        }
        //更新数据库
        [XYSqliteTool executeUpdate:sql];
        
        XYComposeController *composeVC = [[XYComposeController alloc] init];
        composeVC.event = event;
        composeVC.showEvent = YES;
        XYMainNavigationController *composeNav = [[XYMainNavigationController alloc] initWithRootViewController:composeVC];
        
        
        //跳转到compose
        XYMainNavigationController *mainNav = (XYMainNavigationController *)self.window.rootViewController;
        XYMainViewController *mainVC = mainNav.viewControllers[0];
        [mainVC presentViewController:composeNav animated:YES completion:nil];
        
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[AVAudioSession sharedInstance] setActive:NO error:NULL];
//    if (flag) {
//        XYLog(@"success");
//    }else{
//        XYLog(@"failure");
//    }
//    
  
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[AVAudioSession sharedInstance] setActive:NO error:NULL];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
