//
//  AppDelegate.m
//  ZhiHuFans_iOS
//
//  Created by bob on 17/3/6.
//  Copyright © 2017年 wenbobao. All rights reserved.
//

#import "AppDelegate.h"
#import "QDUIHelper.h"
#import "QDCommonUI.h"
#import "QDTabBarViewController.h"
#import "QDNavigationController.h"
#import "QMUIConfigurationTemplate.h"
#import "YDCategoryViewController.h"
#import "YDNowHotViewController.h"
#import "YDHistoryHotViewController.h"
#import <Ono/Ono.h>
#import "CellDataModel.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 启动QMUI的配置模板
    [QMUIConfigurationTemplate setupConfigurationTemplate];
    
    // 将全局的控件样式渲染出来
    [QMUIConfigurationManager renderGlobalAppearances];
    
    // QD自定义的全局样式渲染
    [QDCommonUI renderGlobalAppearances];
    
    // 将状态栏设置为希望的样式
    [QMUIHelper renderStatusBarStyleLight];
    
    // 界面
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self createTabBarController];
    
//    [self fetchData];
    return YES;
}

- (void)fetchData {
    NSData *data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:@"http://www.zhihufans.com"]];
    NSError *xmlError;
    ONOXMLDocument *document = [ONOXMLDocument HTMLDocumentWithData:data error:&xmlError];
    if (xmlError) {
        NSLog(@"%@",xmlError);
        return ;
    }
    NSMutableArray *dataArray = [NSMutableArray array];
    [document enumerateElementsWithXPath:@"/html/body/div/div[1]/div/div/div/ul/node()" usingBlock:^(ONOXMLElement *superelement, NSUInteger idx, BOOL *stop) {
        if ([superelement children].count > 0) {
            NSLog(@"AAA%@",superelement);
            ONOXMLElement *childElement = [[superelement children] firstObject];
            NSString *urlLink = [childElement valueForAttribute:@"href"];
            NSString *title = [childElement stringValue];
            [dataArray addObject:[[CellDataModel alloc]initWithTitle:title link:urlLink]];
        }
    }];
}

- (void)createTabBarController {
    QDTabBarViewController *tabBarViewController = [[QDTabBarViewController alloc] init];
    
    // 分类
    YDCategoryViewController *categoryViewController = [[YDCategoryViewController alloc] init];
    categoryViewController.hidesBottomBarWhenPushed = NO;
    QDNavigationController *uikitNavController = [[QDNavigationController alloc] initWithRootViewController:categoryViewController];
    categoryViewController.tabBarItem = [QDUIHelper tabBarItemWithTitle:@"分类" image:[UIImageMake(@"icon_tabbar_uikit") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"icon_tabbar_uikit_selected") tag:0];
    
    // 当前热门
    YDNowHotViewController *nowHotViewController = [[YDNowHotViewController alloc] init];
    nowHotViewController.hidesBottomBarWhenPushed = NO;
    QDNavigationController *componentNavController = [[QDNavigationController alloc] initWithRootViewController:nowHotViewController];
    nowHotViewController.tabBarItem = [QDUIHelper tabBarItemWithTitle:@"当前热门" image:[UIImageMake(@"icon_tabbar_component") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"icon_tabbar_component_selected") tag:1];
    
    // 历史热门
    YDHistoryHotViewController *historyHotViewController = [[YDHistoryHotViewController alloc] init];
    historyHotViewController.hidesBottomBarWhenPushed = NO;
    QDNavigationController *labNavController = [[QDNavigationController alloc] initWithRootViewController:historyHotViewController];
    historyHotViewController.tabBarItem = [QDUIHelper tabBarItemWithTitle:@"历史热门" image:[UIImageMake(@"icon_tabbar_lab") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"icon_tabbar_lab_selected") tag:2];
    
    // window root controller
    tabBarViewController.viewControllers = @[uikitNavController, componentNavController, labNavController];
    self.window.rootViewController = tabBarViewController;
    [self.window makeKeyAndVisible];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
